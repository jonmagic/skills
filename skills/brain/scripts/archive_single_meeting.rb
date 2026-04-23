#!/usr/bin/env ruby
# frozen_string_literal: true

# Archive a single meeting: transcript → executive summary → meeting notes.
#
# This is the main orchestration script. The agent's only job is to:
# 1. Identify the source transcript (VTT or Zoom folder)
# 2. Identify the Meeting Notes target file
# 3. Call this script
#
# This script handles:
# - Determining the next available file number (no overwrites)
# - Converting VTT to markdown (if needed)
# - Calling `llm` CLI to generate executive summary
# - Calling `llm` CLI to generate meeting notes
# - Updating the Meeting Notes file
# - Checking off the meeting in Weekly Notes (if found)
#
# Usage:
#     ruby archive_single_meeting.rb \
#         --brain-dir ~/Brain \
#         --input "/path/to/transcript.vtt" \
#         --meeting-notes-target "yoodan" \
#         [--date 2026-01-12]  # optional, defaults to file mtime
#
# Prerequisites:
#     - `llm` CLI installed and configured (uses system default model)

require "optparse"
require "fileutils"
require "date"
require "open3"

SCRIPTS_DIR = File.expand_path(__dir__)
ASSETS_DIR = File.expand_path("../assets", SCRIPTS_DIR)

EXEC_SUMMARY_PROMPT = File.join(ASSETS_DIR, "zoom-transcript-executive-summary.prompt.md")
MEETING_NOTES_PROMPT = File.join(ASSETS_DIR, "transcript-meeting-notes.prompt.md")

def expand_path(path)
  File.expand_path(path)
end

def get_existing_numbers(directory)
  return Set.new unless File.directory?(directory)

  numbers = Set.new
  Dir.glob(File.join(directory, "*.md")).each do |file|
    basename = File.basename(file)
    if basename.match?(/^\d+\.md$/)
      numbers.add(basename.to_i)
    end
  end
  numbers
end

def find_next_number(brain_dir, date)
  transcripts_dir = File.join(brain_dir, "Transcripts", date)
  exec_summaries_dir = File.join(brain_dir, "Executive Summaries", date)

  transcript_nums = get_existing_numbers(transcripts_dir)
  exec_summary_nums = get_existing_numbers(exec_summaries_dir)

  all_nums = transcript_nums | exec_summary_nums

  return 1 if all_nums.empty?

  all_nums.max + 1
end

def get_date_from_file(path)
  mtime = File.mtime(path)
  mtime.strftime("%Y-%m-%d")
end

def convert_vtt_to_markdown(vtt_path)
  script = File.join(SCRIPTS_DIR, "vtt_to_markdown.rb")
  stdout, stderr, status = Open3.capture3("ruby", script, vtt_path)
  raise "VTT conversion failed: #{stderr}" unless status.success?

  stdout
end

def process_zoom_folder(zoom_path)
  parts = []

  patterns = ["*.vtt", "*.txt"]
  patterns.each do |pattern|
    Dir.glob(File.join(zoom_path, pattern)).sort.each do |file|
      next if File.basename(file).start_with?(".")

      content = File.read(file, encoding: "utf-8")

      # If it's a VTT, convert it
      if file.downcase.end_with?(".vtt")
        content = convert_vtt_to_markdown(file)
      end

      parts << "<!-- START: #{File.basename(file)} -->\n#{content}\n<!-- END: #{File.basename(file)} -->"
    end
  end

  raise "No transcript files found in #{zoom_path}" if parts.empty?

  parts.join("\n\n")
end

def call_llm(transcript, prompt_file)
  raise "Prompt file not found: #{prompt_file}" unless File.exist?(prompt_file)

  system_prompt = File.read(prompt_file, encoding: "utf-8")

  cmd = ["llm", "-s", system_prompt]

  stdout, stderr, status = Open3.capture3(*cmd, stdin_data: transcript)
  raise "llm command failed: #{stderr}" unless status.success?

  stdout.strip
end

def update_meeting_notes(brain_dir:, target:, date:, transcript_link:, summary_link:, detailed_notes:)
  script = File.join(SCRIPTS_DIR, "update_meeting_notes.rb")
  stdout, stderr, status = Open3.capture3(
    "ruby", script,
    "--brain-dir", brain_dir,
    "--target", target,
    "--date", date,
    "--transcript-link", transcript_link,
    "--summary-link", summary_link,
    "--detailed-notes", detailed_notes
  )
  raise "update_meeting_notes failed: #{stderr}" unless status.success?

  stdout.strip
end

def check_off_weekly_note(brain_dir, target, meeting_date)
  script = File.join(SCRIPTS_DIR, "check_off_weekly_note.rb")
  stdout, stderr, status = Open3.capture3(
    "ruby", script,
    "--brain-dir", brain_dir,
    "--target", target,
    "--date", meeting_date
  )
  raise "check_off_weekly_note failed: #{stderr}" unless status.success?

  stdout.strip
end

# Main execution
options = {
  brain_dir: "~/Brain",
  dry_run: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby archive_single_meeting.rb [options]"

  opts.on("--brain-dir DIR", "Path to Brain directory (default: ~/Brain)") do |v|
    options[:brain_dir] = v
  end

  opts.on("--input PATH", "Path to input (VTT file or Zoom folder)") do |v|
    options[:input] = v
  end

  opts.on("--meeting-notes-target TARGET", "Meeting Notes target basename") do |v|
    options[:meeting_notes_target] = v
  end

  opts.on("--date DATE", "Meeting date YYYY-MM-DD (defaults to input file mtime)") do |v|
    options[:date] = v
  end

  opts.on("--dry-run", "Show what would be done without writing files") do
    options[:dry_run] = true
  end
end.parse!

unless options[:input]
  warn "error: --input is required"
  exit 1
end

unless options[:meeting_notes_target]
  warn "error: --meeting-notes-target is required"
  exit 1
end

brain_dir = expand_path(options[:brain_dir])
input_path = expand_path(options[:input])

unless File.exist?(brain_dir)
  warn "error: brain directory does not exist: #{brain_dir}"
  exit 1
end

unless File.exist?(input_path)
  warn "error: input path does not exist: #{input_path}"
  exit 1
end

# Determine date
if options[:date]
  unless options[:date].match?(/^\d{4}-\d{2}-\d{2}$/)
    warn "error: invalid date format '#{options[:date]}', expected YYYY-MM-DD"
    exit 1
  end
  meeting_date = options[:date]
else
  meeting_date = get_date_from_file(input_path)
end

puts "Processing: #{input_path}"
puts "Date: #{meeting_date}"
puts "Target: Meeting Notes/#{options[:meeting_notes_target]}.md"

# Step 1: Get next file number
next_num = find_next_number(brain_dir, meeting_date)
next_num_str = format("%02d", next_num)
puts "File number: #{next_num_str}"

transcripts_dir = File.join(brain_dir, "Transcripts", meeting_date)
exec_summaries_dir = File.join(brain_dir, "Executive Summaries", meeting_date)
transcript_path = File.join(transcripts_dir, "#{next_num_str}.md")
exec_summary_path = File.join(exec_summaries_dir, "#{next_num_str}.md")

if options[:dry_run]
  puts "\n[DRY RUN] Would create:"
  puts "  - #{transcript_path}"
  puts "  - #{exec_summary_path}"
  puts "  - Update Meeting Notes/#{options[:meeting_notes_target]}.md"
  exit 0
end

# Step 2: Convert input to markdown transcript
puts "\nConverting transcript..."
if File.directory?(input_path)
  transcript_md = process_zoom_folder(input_path)
elsif input_path.downcase.end_with?(".vtt")
  transcript_md = convert_vtt_to_markdown(input_path)
else
  # Assume it's already markdown or plain text
  transcript_md = File.read(input_path, encoding: "utf-8")
end

# Step 3: Write transcript
FileUtils.mkdir_p(transcripts_dir)
File.write(transcript_path, transcript_md, encoding: "utf-8")
puts "Created: #{transcript_path}"

# Step 4: Generate executive summary via llm
puts "\nGenerating executive summary..."
begin
  exec_summary = call_llm(transcript_md, EXEC_SUMMARY_PROMPT)
rescue => e
  warn "error: #{e.message}"
  exit 1
end

FileUtils.mkdir_p(exec_summaries_dir)
File.write(exec_summary_path, exec_summary + "\n", encoding: "utf-8")
puts "Created: #{exec_summary_path}"

# Step 5: Generate meeting notes via llm
puts "\nGenerating meeting notes..."
begin
  meeting_notes = call_llm(transcript_md, MEETING_NOTES_PROMPT)
rescue => e
  warn "error: #{e.message}"
  exit 1
end

# Step 6: Update meeting notes file
puts "\nUpdating meeting notes..."
transcript_link = "[[Transcripts/#{meeting_date}/#{next_num_str}|Transcript]]"
summary_link = "[[Executive Summaries/#{meeting_date}/#{next_num_str}|Executive Summary]]"

result = update_meeting_notes(
  brain_dir: brain_dir,
  target: options[:meeting_notes_target],
  date: meeting_date,
  transcript_link: transcript_link,
  summary_link: summary_link,
  detailed_notes: meeting_notes
)
puts result

# Step 7: Check off in weekly notes
weekly_result = check_off_weekly_note(brain_dir, options[:meeting_notes_target], meeting_date)
puts "\n#{weekly_result}" unless weekly_result.empty?

# Output summary
puts "\n" + ("=" * 60)
puts "Archive complete!"
puts "  Transcript:        #{transcript_path}"
puts "  Executive Summary: #{exec_summary_path}"
puts "  Meeting Notes:     Meeting Notes/#{options[:meeting_notes_target]}.md"
