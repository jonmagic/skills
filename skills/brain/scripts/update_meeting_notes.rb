#!/usr/bin/env ruby
# frozen_string_literal: true

# Update a `Meeting Notes/*.md` file with links + detailed notes.
#
# Behavior (matches jonmagic brain norms)
# - Meeting Notes files are reverse chronological: newest `## YYYY-MM-DD` at top.
# - If the target date section exists, append the new content block to that section.
# - Otherwise, prepend a new date section at the top.
#
# The content block format is:
# - Transcript wikilink
# - Executive Summary wikilink
# - detailed notes bullets
#
# This script is deterministic and does not try to guess the target file; it only
# applies the update once a target is chosen.

require "optparse"
require "fileutils"

DATE_HEADER_RE = /^##\s+(\d{4}-\d{2}-\d{2})\s*$/

def expand_path(path)
  File.expand_path(path)
end

def ensure_bullets(text)
  lines = text.lines.map(&:rstrip)
  items = []
  lines.each do |ln|
    next if ln.strip.empty?

    if ln.lstrip.start_with?("-")
      items << ln.rstrip
    else
      items << "- #{ln.strip}"
    end
  end
  items.join("\n").rstrip
end

def build_block(transcript_link, summary_link, detailed_notes)
  detailed = ensure_bullets(detailed_notes)
  block = "- #{transcript_link}\n- #{summary_link}\n"
  block += "#{detailed}\n" unless detailed.empty?
  block + "\n"
end

def update_file(file_path:, meeting_date:, content_block:)
  # Returns true if updated, false if created
  header = "## #{meeting_date}"

  unless File.exist?(file_path)
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, "#{header}\n\n#{content_block}", encoding: "utf-8")
    return false
  end

  text = File.read(file_path, encoding: "utf-8")

  # Find all date headers with positions
  matches = []
  text.scan(DATE_HEADER_RE) do
    matches << { date: $1, start: $~.begin(0), end_pos: $~.end(0) }
  end

  target_idx = matches.find_index { |m| m[:date] == meeting_date }

  if target_idx.nil?
    # Prepend a new section
    new_text = "#{header}\n\n#{content_block}" + text
    File.write(file_path, new_text, encoding: "utf-8")
    return true
  end

  # Insert at end of the target section (before the next date header, if any)
  next_header_start = if target_idx + 1 < matches.length
                        matches[target_idx + 1][:start]
                      else
                        text.length
                      end

  before = text[0...next_header_start]
  after = text[next_header_start..]

  # Ensure the section ends with a newline before appending
  before += "\n" unless before.end_with?("\n")

  new_before = before + content_block
  File.write(file_path, new_before + after, encoding: "utf-8")
  true
end

# Main execution
options = {
  brain_dir: "~/Dropbox/brain",
  detailed_notes: ""
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby update_meeting_notes.rb [options]"

  opts.on("--brain-dir DIR", "Path to brain repo root") do |v|
    options[:brain_dir] = v
  end

  opts.on("--target TARGET", "Meeting Notes target basename") do |v|
    options[:target] = v
  end

  opts.on("--date DATE", "Meeting date YYYY-MM-DD") do |v|
    options[:date] = v
  end

  opts.on("--transcript-link LINK", "Wikilink to transcript") do |v|
    options[:transcript_link] = v
  end

  opts.on("--summary-link LINK", "Wikilink to executive summary") do |v|
    options[:summary_link] = v
  end

  opts.on("--detailed-notes NOTES", "Detailed notes text") do |v|
    options[:detailed_notes] = v
  end
end.parse!

%i[target date transcript_link summary_link].each do |key|
  unless options[key]
    warn "error: --#{key.to_s.tr('_', '-')} is required"
    exit 1
  end
end

brain_dir = expand_path(options[:brain_dir])
meeting_notes_file = File.join(brain_dir, "Meeting Notes", "#{options[:target]}.md")

block = build_block(options[:transcript_link], options[:summary_link], options[:detailed_notes])
updated = update_file(file_path: meeting_notes_file, meeting_date: options[:date], content_block: block)

action = updated ? "Updated" : "Created"
puts "#{action}: #{meeting_notes_file}"
