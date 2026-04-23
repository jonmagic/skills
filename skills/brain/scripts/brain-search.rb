#!/usr/bin/env ruby
# frozen_string_literal: true

# Search the Brain index.
#
# Usage:
#   ruby brain-search.rb "proxima"                      # Full-text search
#   ruby brain-search.rb --tag proxima                   # Search by tag
#   ruby brain-search.rb --type daily.project --tag hamzo # Combined query
#   ruby brain-search.rb --linked-to <uid>               # Find records linking to UID
#   ruby brain-search.rb --timeline proxima              # Chronological view of a topic
#   ruby brain-search.rb --recent 7                      # Files modified in last N days
#   ruby brain-search.rb --stats                         # Show index statistics

require 'json'
require 'time'

DEFAULT_INDEX = File.join(Dir.home, 'Brain', '.brain', 'index.json')

def load_index(index_path)
  unless File.exist?(index_path)
    warn "Error: Index not found at #{index_path}"
    warn 'Run: ruby brain-index.rb ~/Brain'
    exit 1
  end
  JSON.parse(File.read(index_path))
end

def search_full_text(records, query)
  terms = query.downcase.split(/\s+/)
  records
    .map do |r|
      searchable = [
        r['title'] || '',
        r['summary'] || '',
        r['path'] || '',
        *(r['tags'] || [])
      ].join(' ').downcase

      score = 0
      terms.each do |term|
        next unless searchable.include?(term)

        score += 1
        # Boost for title matches
        score += 2 if (r['title'] || '').downcase.include?(term)
        # Boost for tag matches
        score += 2 if (r['tags'] || []).any? { |t| t.include?(term) }
        # Boost for path matches
        score += 1 if (r['path'] || '').downcase.include?(term)
      end
      { record: r, score: score }
    end
    .select { |r| r[:score] > 0 }
    .sort_by { |r| -r[:score] }
end

def search_by_tag(records, tag)
  records.select { |r| (r['tags'] || []).include?(tag) }
end

def search_by_type(records, type)
  records.select { |r| r['type'] == type }
end

def search_linked_to(records, uid)
  records.select do |r|
    next false unless r['links']

    r['links'].values.any? { |values| values.include?(uid) }
  end
end

def search_recent(records, days)
  cutoff = Time.now - days * 24 * 60 * 60
  records
    .select { |r| Time.parse(r['mtime']) >= cutoff }
    .sort_by { |r| Time.parse(r['mtime']) }
    .reverse
end

def timeline_view(records, query)
  terms = query.downcase.split(/\s+/)
  matches = records.select do |r|
    searchable = [
      r['title'] || '',
      r['summary'] || '',
      r['path'] || '',
      *(r['tags'] || [])
    ].join(' ').downcase
    terms.all? { |t| searchable.include?(t) }
  end

  matches.sort_by do |r|
    date = r['created'] || r['mtime']
    date || ''
  end
end

def format_record(r, options = {})
  lines = []
  date_str = (r['created'] || r['mtime'] || '')[0, 10]
  tags = (r['tags'] || []).map { |t| "##{t}" }.join(' ')

  if options[:timeline]
    lines << "#{date_str}  #{r['title'] || r['path']}"
    lines << "          #{r['summary'][0, 120]}" if r['summary']
    lines << "          #{r['path']}"
  elsif options[:compact]
    lines << "#{r['path']}#{tags.empty? ? '' : " #{tags}"}"
  else
    lines << (r['title'] || '(untitled)')
    lines << "  Path: #{r['path']}"
    lines << "  UID:  #{r['uid']}" if r['uid']
    lines << "  Type: #{r['type']}" if r['type']
    lines << "  Date: #{date_str}" if date_str && !date_str.empty?
    lines << "  Tags: #{tags}" if tags && !tags.empty?
    lines << "  #{r['summary'][0, 200]}" if r['summary']
  end

  lines.join("\n")
end

def show_stats(index)
  records = index['records']
  puts 'Brain Index Statistics'
  puts '======================'
  puts "Generated: #{index['generated']}"
  puts "Total records: #{records.length}"

  # Type distribution
  types = Hash.new(0)
  tag_counts = Hash.new(0)
  with_tags = 0
  with_uid = 0
  with_links = 0

  records.each do |r|
    types[r['type'] || 'no-type'] += 1
    with_uid += 1 if r['uid']
    with_links += 1 if r['links']
    if r['tags'].is_a?(Array) && !r['tags'].empty?
      with_tags += 1
      r['tags'].each { |tag| tag_counts[tag] += 1 }
    end
  end

  puts "\nCoverage:"
  puts "  With UID:  #{with_uid} (#{(with_uid.to_f / records.length * 100).round}%)"
  puts "  With tags: #{with_tags} (#{(with_tags.to_f / records.length * 100).round}%)"
  puts "  With links: #{with_links}"

  puts "\nBy type:"
  types.sort_by { |_, count| -count }.each do |type, count|
    puts "  #{type}: #{count}"
  end

  puts "\nAll tags (#{tag_counts.length} unique):"
  tag_counts.sort_by { |_, count| -count }.each do |tag, count|
    puts "  #{tag}: #{count}"
  end
end

def main
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    puts <<~HELP
      Usage: brain-search.rb [OPTIONS] [QUERY]

      Search the Brain index.

      Search modes:
        brain-search "query"              Full-text search across titles, summaries, paths, tags
        brain-search --tag <tag>          Find files with specific tag
        brain-search --type <type>        Find files of specific type
        brain-search --linked-to <uid>    Find files linking to a UID
        brain-search --timeline <query>   Chronological view of a topic
        brain-search --recent <days>      Files modified in last N days
        brain-search --stats              Show index statistics

      Options:
        --tag <tag>          Filter by tag (can combine with other filters)
        --type <type>        Filter by collection type
        --linked-to <uid>    Find records linking to this UID
        --timeline <query>   Show chronological timeline for topic
        --recent <days>      Show files modified in last N days
        --limit <n>          Max results (default: 20)
        --compact            Compact output (paths only)
        --index <path>       Custom index path (default: ~/Brain/.brain/index.json)
        --stats              Show index statistics
        -h, --help           Show this help message

      Types: daily.project, weekly.note, meeting.note, project, snippet,
             transcript, executive.summary, archive, reference

      Examples:
        brain-search "proxima abuse"
        brain-search --tag hamzo --type daily.project
        brain-search --timeline "nuanced-enforcement"
        brain-search --recent 7
        brain-search --linked-to 3lz7nwvh4zc2u
    HELP
    exit 0
  end

  # Parse arguments
  index_path = DEFAULT_INDEX
  query = nil
  tag_filter = nil
  type_filter = nil
  linked_to = nil
  timeline = nil
  recent = nil
  limit = 20
  compact = ARGV.include?('--compact')
  show_stats_flag = ARGV.include?('--stats')

  i = 0
  while i < ARGV.length
    case ARGV[i]
    when '--index'
      i += 1
      index_path = ARGV[i]
    when '--tag'
      i += 1
      tag_filter = ARGV[i]
    when '--type'
      i += 1
      type_filter = ARGV[i]
    when '--linked-to'
      i += 1
      linked_to = ARGV[i]
    when '--timeline'
      i += 1
      timeline = ARGV[i]
    when '--recent'
      i += 1
      recent = ARGV[i].to_i
    when '--limit'
      i += 1
      limit = ARGV[i].to_i
    when '--compact', '--stats', '--help', '-h'
      # already handled
    else
      query = ARGV[i] unless ARGV[i].start_with?('--')
    end
    i += 1
  end

  index = load_index(index_path)

  if show_stats_flag
    show_stats(index)
    return
  end

  results = index['records']

  # Apply filters
  results = search_by_type(results, type_filter) if type_filter
  results = search_by_tag(results, tag_filter) if tag_filter
  results = search_linked_to(results, linked_to) if linked_to
  results = search_recent(results, recent) if recent

  if timeline
    results = timeline_view(results, timeline)
    puts "Timeline: \"#{timeline}\" (#{results.length} records)\n\n"
    results.first(limit).each do |r|
      puts format_record(r, timeline: true)
      puts
    end
    puts "... and #{results.length - limit} more (use --limit to show more)" if results.length > limit
    return
  end

  if query
    scored = search_full_text(results, query)
    puts "Search: \"#{query}\" (#{scored.length} results)\n\n"
    scored.first(limit).each do |item|
      puts format_record(item[:record], compact: compact)
      puts unless compact
    end
    puts "... and #{scored.length - limit} more (use --limit to show more)" if scored.length > limit
    return
  end

  # No query, just filters
  if type_filter || tag_filter || linked_to || recent
    # Sort by date descending
    results.sort_by! do |r|
      date = r['created'] || r['mtime'] || ''
      date
    end.reverse!

    puts "Filter results: #{results.length} records\n\n"
    results.first(limit).each do |r|
      puts format_record(r, compact: compact)
      puts unless compact
    end
    puts "... and #{results.length - limit} more (use --limit to show more)" if results.length > limit
    return
  end

  warn 'No search query or filter specified. Use --help for usage.'
  exit 1
end

main
