#!/usr/bin/env ruby
# frozen_string_literal: true

# Add YAML frontmatter to a Brain markdown file.
#
# Usage:
#   ruby add-frontmatter.rb <file>
#   ruby add-frontmatter.rb <file> --dry-run
#   ruby add-frontmatter.rb <file> --type daily.project
#   ruby add-frontmatter.rb <file> --created "2026-01-24"

require_relative 'generate-tid'

# Collection type detection based on file path
COLLECTION_PATTERNS = [
  { type: 'daily.project', pattern: %r{Daily Projects/\d{4}-\d{2}-\d{2}/} },
  { type: 'weekly.note', pattern: %r{Weekly Notes/Week of \d{4}-\d{2}-\d{2}\.md$} },
  { type: 'meeting.note', pattern: %r{Meeting Notes/} },
  { type: 'project', pattern: %r{Projects/} },
  { type: 'snippet', pattern: %r{Snippets/} },
  { type: 'transcript', pattern: %r{Transcripts/\d{4}-\d{2}-\d{2}/} },
  { type: 'executive.summary', pattern: %r{Executive Summaries/\d{4}-\d{2}-\d{2}/} },
  { type: 'archive', pattern: %r{Archive/} }
].freeze

# Date extraction patterns from file paths
DATE_PATTERNS = [
  /(\d{4}-\d{2}-\d{2})/,                        # YYYY-MM-DD anywhere in path
  /Week of (\d{4}-\d{2}-\d{2})/,                # Weekly notes
  /(\d{4}-\d{2}-\d{2})-to-\d{4}-\d{2}-\d{2}/ # Snippet date ranges (use start)
].freeze

def detect_collection_type(file_path)
  COLLECTION_PATTERNS.each do |entry|
    return entry[:type] if entry[:pattern].match?(file_path)
  end
  'unknown'
end

def extract_date_from_path(file_path)
  DATE_PATTERNS.each do |pattern|
    match = file_path.match(pattern)
    return Time.new(match[1] + 'T00:00:00') if match
  end
  nil
end

def detect_created_date(file_path)
  # First try: extract from path
  path_date = extract_date_from_path(file_path)
  return path_date if path_date

  # Fallback: use file mtime
  File.mtime(file_path)
end

def has_frontmatter?(content)
  content.start_with?("---\n")
end

def parse_existing_frontmatter(content)
  return [nil, content] unless has_frontmatter?(content)

  lines = content.split("\n")
  end_index = -1

  (1...lines.length).each do |i|
    if lines[i].strip == '---'
      end_index = i
      break
    end
  end

  return [nil, content] if end_index == -1

  frontmatter_lines = lines[1...end_index]
  body = lines[(end_index + 1)..].join("\n").sub(/\A\n+/, '')

  # Simple YAML parsing for our use case
  frontmatter = {}
  frontmatter_lines.each do |line|
    colon_index = line.index(':')
    next unless colon_index

    key = line[0...colon_index].strip
    value = line[(colon_index + 1)..].strip
    # Remove quotes if present
    if (value.start_with?('"') && value.end_with?('"')) ||
       (value.start_with?("'") && value.end_with?("'"))
      value = value[1..-2]
    end
    frontmatter[key] = value
  end

  [frontmatter, body]
end

def build_frontmatter(file_path, options = {})
  type = options[:type] || detect_collection_type(file_path)
  created = options[:created] || detect_created_date(file_path)

  {
    'uid' => generate_tid(created.iso8601),
    'type' => type,
    'created' => created.utc.iso8601(3)
  }
end

def format_frontmatter(fm)
  lines = ['---']
  lines << "uid: #{fm['uid']}"
  lines << "type: #{fm['type']}"
  lines << "created: #{fm['created']}"
  lines << "updated: #{fm['updated']}" if fm['updated']
  if fm['tags'] && !fm['tags'].empty?
    tags = fm['tags'].is_a?(Array) ? fm['tags'] : [fm['tags']]
    lines << "tags: [#{tags.join(', ')}]"
  end
  if fm['links']
    lines << 'links:'
    fm['links'].each do |key, values|
      if values && !values.empty?
        vals = values.is_a?(Array) ? values : [values]
        lines << "  #{key}: [#{vals.join(', ')}]"
      end
    end
  end
  lines << '---'
  lines.join("\n")
end

def add_frontmatter(file_path, options = {})
  unless File.exist?(file_path)
    warn "Error: File not found: #{file_path}"
    return false
  end

  content = File.read(file_path)

  if has_frontmatter?(content) && !options[:force]
    warn "Skipping: #{file_path} (already has frontmatter)" if options[:verbose]
    return true
  end

  frontmatter = build_frontmatter(file_path, options)
  body = content

  # If file has frontmatter and --force, merge with existing
  if has_frontmatter?(content) && options[:force]
    existing, existing_body = parse_existing_frontmatter(content)
    frontmatter = frontmatter.merge(existing) if existing
    body = existing_body
  end

  new_content = format_frontmatter(frontmatter) + "\n\n" + body

  if options[:dry_run]
    puts "=== Would add to: #{file_path} ==="
    puts format_frontmatter(frontmatter)
    puts
    return true
  end

  File.write(file_path, new_content)
  puts "Added frontmatter to: #{file_path}" if options[:verbose]
  true
end

# CLI interface
if __FILE__ == $0
  require 'time'

  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    puts <<~HELP
      Usage: add-frontmatter.rb <file> [OPTIONS]

      Add YAML frontmatter to a Brain markdown file.

      Options:
        --dry-run          Print what would be added without modifying
        --force            Update existing frontmatter (add missing fields)
        --type TYPE        Override auto-detected collection type
        --created DATE     Override auto-detected creation date (ISO 8601)
        --verbose          Print status messages
        -h, --help         Show this help message

      Collection Types:
        daily.project, weekly.note, meeting.note, project,
        snippet, transcript, executive.summary, archive

      Examples:
        ruby add-frontmatter.rb "Daily Projects/2026-01-24/01 notes.md"
        ruby add-frontmatter.rb "Meeting Notes/tgthorley.md" --dry-run
        ruby add-frontmatter.rb "Projects/foo/README.md" --type project
    HELP
    exit 0
  end

  file_path = ARGV[0]
  options = {
    dry_run: ARGV.include?('--dry-run'),
    force: ARGV.include?('--force'),
    verbose: ARGV.include?('--verbose') || ARGV.include?('--dry-run')
  }

  type_index = ARGV.index('--type')
  options[:type] = ARGV[type_index + 1] if type_index && ARGV[type_index + 1]

  created_index = ARGV.index('--created')
  options[:created] = Time.parse(ARGV[created_index + 1]) if created_index && ARGV[created_index + 1]

  success = add_frontmatter(file_path, options)
  exit(success ? 0 : 1)
end
