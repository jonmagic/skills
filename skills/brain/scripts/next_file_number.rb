#!/usr/bin/env ruby
# frozen_string_literal: true

# Determine the next available file number for a dated directory.
#
# Purpose
# - Given a brain directory and a date, find the next available sequential number
#   for both Transcripts and Executive Summaries directories.
# - Ensures we never overwrite existing files.
#
# Usage:
#     ruby next_file_number.rb --brain-dir ~/Brain --date 2026-01-12
#
# Output:
# - JSON to stdout with the next available number and full paths.
#
# Example output:
# {
#   "date": "2026-01-12",
#   "next_number": "05",
#   "transcript_path": "/Users/jonmagic/Brain/Transcripts/2026-01-12/05.md",
#   "executive_summary_path": "/Users/jonmagic/Brain/Executive Summaries/2026-01-12/05.md",
#   "transcripts_dir": "/Users/jonmagic/Brain/Transcripts/2026-01-12",
#   "executive_summaries_dir": "/Users/jonmagic/Brain/Executive Summaries/2026-01-12"
# }

require "optparse"
require "json"
require "fileutils"

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

  # Union of all existing numbers
  all_nums = transcript_nums | exec_summary_nums

  return 1 if all_nums.empty?

  all_nums.max + 1
end

# Main execution
options = {
  brain_dir: "~/Brain",
  create_dirs: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby next_file_number.rb [options]"

  opts.on("--brain-dir DIR", "Path to Brain directory (default: ~/Brain)") do |v|
    options[:brain_dir] = v
  end

  opts.on("--date DATE", "Date in YYYY-MM-DD format") do |v|
    options[:date] = v
  end

  opts.on("--create-dirs", "Create the directories if they don't exist") do
    options[:create_dirs] = true
  end
end.parse!

unless options[:date]
  warn "error: --date is required"
  exit 1
end

# Validate date format
unless options[:date].match?(/^\d{4}-\d{2}-\d{2}$/)
  warn "error: invalid date format '#{options[:date]}', expected YYYY-MM-DD"
  exit 1
end

brain_dir = expand_path(options[:brain_dir])

unless File.exist?(brain_dir)
  warn "error: brain directory does not exist: #{brain_dir}"
  exit 1
end

next_num = find_next_number(brain_dir, options[:date])
next_num_str = format("%02d", next_num)

transcripts_dir = File.join(brain_dir, "Transcripts", options[:date])
exec_summaries_dir = File.join(brain_dir, "Executive Summaries", options[:date])

if options[:create_dirs]
  FileUtils.mkdir_p(transcripts_dir)
  FileUtils.mkdir_p(exec_summaries_dir)
end

result = {
  date: options[:date],
  next_number: next_num_str,
  transcript_path: File.join(transcripts_dir, "#{next_num_str}.md"),
  executive_summary_path: File.join(exec_summaries_dir, "#{next_num_str}.md"),
  transcripts_dir: transcripts_dir,
  executive_summaries_dir: exec_summaries_dir
}

puts JSON.pretty_generate(result)
