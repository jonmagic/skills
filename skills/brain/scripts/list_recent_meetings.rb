#!/usr/bin/env ruby
# frozen_string_literal: true

# List recent meeting inputs from Zoom and Teams.
#
# Purpose
# - Zoom: enumerate most-recent meeting folders under ~/Documents/Zoom
# - Teams: enumerate most-recent downloaded .vtt files under ~/Downloads
#
# This script is intentionally deterministic and non-interactive; it prints JSON so
# an agent (or a human) can quickly pick "the most recent" or "the last N".
#
# Output
# - JSON array to stdout.
#
# Fields
# - type: "zoom" | "teams_vtt"
# - path: absolute filesystem path
# - mtime_iso: ISO-8601 modified time
# - date: YYYY-MM-DD derived from mtime (good enough for filing)
# - hint: folder/file name (useful for routing)

require "optparse"
require "json"
require "time"

def expand_path(path)
  File.expand_path(path)
end

def iso_time(time)
  time.utc.iso8601
end

def date_str(time)
  time.strftime("%Y-%m-%d")
end

def iter_zoom_folders(zoom_dir)
  return [] unless File.directory?(zoom_dir)

  candidates = []
  begin
    Dir.entries(zoom_dir).each do |entry|
      next if entry.start_with?(".")

      path = File.join(zoom_dir, entry)
      next unless File.directory?(path)

      begin
        stat = File.stat(path)
        candidates << {
          type: "zoom",
          path: path,
          mtime_iso: iso_time(stat.mtime),
          date: date_str(stat.mtime),
          hint: entry
        }
      rescue Errno::EACCES
        next
      end
    end
  rescue Errno::EACCES, Errno::EPERM => e
    warn "warning: cannot read zoom dir #{zoom_dir}: #{e.message}"
    return []
  end

  candidates.sort_by { |c| c[:mtime_iso] }.reverse
end

def iter_teams_vtts(downloads_dir)
  return [] unless File.directory?(downloads_dir)

  candidates = []
  begin
    Dir.glob(File.join(downloads_dir, "*.vtt")).each do |path|
      next unless File.file?(path)
      next if File.basename(path).start_with?(".")

      begin
        stat = File.stat(path)
        candidates << {
          type: "teams_vtt",
          path: File.expand_path(path),
          mtime_iso: iso_time(stat.mtime),
          date: date_str(stat.mtime),
          hint: File.basename(path)
        }
      rescue Errno::EACCES
        next
      end
    end
  rescue Errno::EACCES => e
    warn "warning: cannot read downloads dir #{downloads_dir}: #{e.message}"
    return []
  end

  candidates.sort_by { |c| c[:mtime_iso] }.reverse
end

# Main execution
options = {
  zoom_dir: "~/Documents/Zoom",
  downloads_dir: "~/Downloads",
  limit: 10,
  merge: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby list_recent_meetings.rb [options]"

  opts.on("--zoom-dir DIR", "Zoom meetings directory") do |v|
    options[:zoom_dir] = v
  end

  opts.on("--downloads-dir DIR", "Downloads directory (Teams .vtt)") do |v|
    options[:downloads_dir] = v
  end

  opts.on("--limit N", Integer, "Max items per source (Zoom + Teams)") do |v|
    options[:limit] = v
  end

  opts.on("--merge", "Merge both sources and sort globally by mtime desc") do
    options[:merge] = true
  end
end.parse!

zoom_dir = expand_path(options[:zoom_dir])
downloads_dir = expand_path(options[:downloads_dir])

zoom = iter_zoom_folders(zoom_dir).first(options[:limit])
teams = iter_teams_vtts(downloads_dir).first(options[:limit])

if options[:merge]
  merged = (zoom + teams).sort_by { |c| c[:mtime_iso] }.reverse
  puts JSON.pretty_generate(merged)
else
  puts JSON.pretty_generate({ zoom: zoom, teams_vtt: teams })
end
