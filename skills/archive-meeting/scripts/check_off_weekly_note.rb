#!/usr/bin/env ruby
# frozen_string_literal: true

# Check off a meeting in Weekly Notes for a given date + meeting notes target.
#
# Usage:
#   ruby check_off_weekly_note.rb --brain-dir ~/Brain --target "ph-ts-eng mob" --date 2026-01-14

require "optparse"
require "date"

WEEKLY_NOTE_RE = /^Week of (\d{4}-\d{2}-\d{2})\.md$/

options = {
  brain_dir: "~/Brain"
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby check_off_weekly_note.rb [options]"

  opts.on("--brain-dir DIR", "Path to Brain directory (default: ~/Brain)") do |v|
    options[:brain_dir] = v
  end

  opts.on("--target TARGET", "Meeting Notes target basename") do |v|
    options[:target] = v
  end

  opts.on("--date DATE", "Meeting date YYYY-MM-DD") do |v|
    options[:date] = v
  end
end.parse!

%i[target date].each do |key|
  unless options[key]
    warn "error: --#{key.to_s.tr('_', '-')} is required"
    exit 1
  end
end

brain_dir = File.expand_path(options[:brain_dir])
weekly_notes_dir = File.join(brain_dir, "Weekly Notes")

unless Dir.exist?(weekly_notes_dir)
  puts "Weekly Notes directory not found: #{weekly_notes_dir}"
  exit 0
end

meeting_dt = Date.parse(options[:date])

candidates = []
Dir.entries(weekly_notes_dir).each do |entry|
  next if entry.start_with?(".")

  match = entry.match(WEEKLY_NOTE_RE)
  next unless match

  week_start = Date.parse(match[1])
  candidates << [week_start, File.join(weekly_notes_dir, entry)]
end

if candidates.empty?
  puts "No Weekly Notes found"
  exit 0
end

candidates.sort_by! { |ws, _| ws }.reverse!
weekly_note = nil

candidates.each do |week_start, path|
  week_end = week_start + 6
  if meeting_dt >= week_start && meeting_dt <= week_end
    weekly_note = path
    break
  end
end

unless weekly_note
  puts "No Weekly Note found containing date #{options[:date]}"
  exit 0
end

content = File.read(weekly_note, encoding: "utf-8")
escaped_target = Regexp.escape(options[:target])

pattern = /^(\s*- \[) (\] \d{4} \[\[Meeting Notes\/#{escaped_target}(?:\|[^\]]+)?\]\].*?)$/i

count = 0
new_content = content.gsub(pattern) do
  count += 1
  "#{$1}x#{$2}"
end

if count > 0
  File.write(weekly_note, new_content, encoding: "utf-8")
  puts "Checked off #{count} item(s) in #{File.basename(weekly_note)}"
else
  puts "No matching checklist item found in #{File.basename(weekly_note)}"
end
