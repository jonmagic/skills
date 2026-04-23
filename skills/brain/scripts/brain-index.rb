#!/usr/bin/env ruby
# frozen_string_literal: true

# Build a JSON index of all Brain markdown files.
#
# Scans all markdown files, parses frontmatter (uid, type, created, tags, links),
# extracts the first heading (title) and first paragraph (summary),
# and outputs a JSON index file.
#
# Usage:
#   ruby brain-index.rb ~/Brain                    # Output to ~/Brain/.brain/index.json
#   ruby brain-index.rb ~/Brain -o /path/to/out    # Custom output path
#   ruby brain-index.rb ~/Brain --stats            # Print stats after indexing

require 'json'

def parse_frontmatter(content)
  return [nil, content] unless content.start_with?("---\n")

  lines = content.split("\n")
  end_index = -1
  (1...lines.length).each do |i|
    if lines[i].strip == '---'
      end_index = i
      break
    end
  end

  return [nil, content] if end_index == -1

  fm = {}
  current_key = nil

  (1...end_index).each do |i|
    line = lines[i]

    # Sub-key (indented, like links.parent)
    if line.match?(/^\s{2}\w+:/)
      colon_idx = line.index(':')
      key = line[0...colon_idx].strip
      value = line[(colon_idx + 1)..].strip
      if current_key && !value.empty?
        fm[current_key] ||= {}
        fm[current_key][key] = parse_array_value(value)
      end
      next
    end

    colon_idx = line.index(':')
    next unless colon_idx

    key = line[0...colon_idx].strip
    value = line[(colon_idx + 1)..].strip

    # Remove quotes
    if (value.start_with?('"') && value.end_with?('"')) ||
       (value.start_with?("'") && value.end_with?("'"))
      value = value[1..-2]
    end

    if key == 'tags'
      fm[key] = parse_array_value(value)
    elsif key == 'links'
      fm[key] = {}
      current_key = 'links'
    else
      fm[key] = value
      current_key = key
    end
  end

  body = lines[(end_index + 1)..].join("\n").sub(/\A\n+/, '')
  [fm, body]
end

def parse_array_value(value)
  return [] if !value || value == '[]'

  # Parse [item1, item2] format
  match = value.match(/^\[(.*)\]$/)
  return match[1].split(',').map(&:strip).reject(&:empty?) if match

  [value]
end

def extract_title(body)
  lines = body.split("\n")
  lines.each do |line|
    match = line.match(/^#+\s+(.+)/)
    return match[1].strip if match
  end
  # Fallback: first non-empty line
  lines.each do |line|
    return line.strip[0, 100] if line.strip.length > 0
  end
  ''
end

def extract_summary(body, max_length = 300)
  lines = body.split("\n")
  found_heading = false
  paragraph_lines = []

  lines.each do |line|
    if line.match?(/^#+\s/)
      break if found_heading && !paragraph_lines.empty?

      found_heading = true
      next
    end
    if found_heading && line.strip.length > 0
      paragraph_lines << line.strip
    elsif found_heading && line.strip.empty? && !paragraph_lines.empty?
      break
    end
  end

  summary = paragraph_lines.join(' ')
  if summary.length > max_length
    summary[0, max_length] + '...'
  else
    summary
  end
end

def find_markdown_files(dir)
  results = []

  walk = lambda do |current_dir|
    Dir.children(current_dir).sort.each do |name|
      full_path = File.join(current_dir, name)
      if File.directory?(full_path)
        walk.call(full_path) unless name.start_with?('.') || name == 'node_modules'
      elsif File.file?(full_path) && name.end_with?('.md')
        results << full_path
      end
    end
  end

  walk.call(dir)
  results
end

def index_file(file_path, brain_dir)
  content = File.read(file_path)
  fm, body = parse_frontmatter(content)
  relative_path = file_path.sub("#{brain_dir}/", '')
  stats = File.stat(file_path)

  record = {
    'path' => relative_path,
    'title' => extract_title(body),
    'summary' => extract_summary(body),
    'size' => stats.size,
    'mtime' => stats.mtime.utc.iso8601(3)
  }

  if fm
    record['uid'] = fm['uid'] if fm['uid']
    record['type'] = fm['type'] if fm['type']
    record['created'] = fm['created'] if fm['created']
    record['updated'] = fm['updated'] if fm['updated']
    record['tags'] = fm['tags'] if fm['tags'].is_a?(Array) && !fm['tags'].empty?
    if fm['links'].is_a?(Hash)
      links = {}
      fm['links'].each do |key, values|
        links[key] = values if values.is_a?(Array) && !values.empty?
      end
      record['links'] = links unless links.empty?
    end
  end

  record
end

def build_index(brain_dir)
  files = find_markdown_files(brain_dir)
  records = []
  errors = 0

  files.each do |file_path|
    records << index_file(file_path, brain_dir)
  rescue StandardError => e
    warn "Error indexing #{file_path}: #{e.message}"
    errors += 1
  end

  {
    'version' => 1,
    'brainDir' => brain_dir,
    'generated' => Time.now.utc.iso8601(3),
    'count' => records.length,
    'errors' => errors,
    'records' => records
  }
end

def print_stats(index)
  puts "\nIndex Stats:"
  puts "  Total records: #{index['count']}"
  puts "  Errors: #{index['errors']}"
  puts "  Generated: #{index['generated']}"

  # Type distribution
  types = Hash.new(0)
  tag_counts = Hash.new(0)
  with_tags = 0
  with_uid = 0

  index['records'].each do |record|
    type = record['type'] || 'no-type'
    types[type] += 1
    with_uid += 1 if record['uid']
    if record['tags'].is_a?(Array) && !record['tags'].empty?
      with_tags += 1
      record['tags'].each { |tag| tag_counts[tag] += 1 }
    end
  end

  puts "  With UID: #{with_uid}"
  puts "  With tags: #{with_tags}"

  puts "\n  By type:"
  types.sort_by { |_, count| -count }.each do |type, count|
    puts "    #{type}: #{count}"
  end

  puts "\n  Top 10 tags:"
  tag_counts.sort_by { |_, count| -count }.first(10).each do |tag, count|
    puts "    #{tag}: #{count}"
  end
end

def main
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    puts <<~HELP
      Usage: brain-index.rb <brain-dir> [OPTIONS]

      Build a JSON index of all Brain markdown files.

      Options:
        -o, --output PATH   Output file path (default: <brain-dir>/.brain/index.json)
        --stats             Print index statistics
        -h, --help          Show this help message
    HELP
    exit 0
  end

  brain_dir = File.expand_path(ARGV[0])
  show_stats = ARGV.include?('--stats')

  output_path = File.join(brain_dir, '.brain', 'index.json')
  out_idx = ARGV.index('-o') || ARGV.index('--output')
  output_path = File.expand_path(ARGV[out_idx + 1]) if out_idx && ARGV[out_idx + 1]

  unless File.exist?(brain_dir)
    warn "Error: Directory not found: #{brain_dir}"
    exit 1
  end

  puts "Indexing #{brain_dir}..."
  index = build_index(brain_dir)

  File.write(output_path, JSON.pretty_generate(index))
  puts "Index written to #{output_path} (#{index['count']} records)"

  print_stats(index) if show_stats
end

main
