#!/usr/bin/env ruby
# frozen_string_literal: true

# Batch add frontmatter to all Brain markdown files that don't have it yet.
#
# Usage:
#   ruby backfill-frontmatter.rb ~/Brain --dry-run
#   ruby backfill-frontmatter.rb ~/Brain
#   ruby backfill-frontmatter.rb ~/Brain --verbose

require_relative 'add-frontmatter'

IGNORE_PATTERNS = [
  %r{/\.}, # Hidden directories
  /node_modules/,
  /\.obsidian/
].freeze

def should_ignore?(file_path)
  IGNORE_PATTERNS.any? { |p| p.match?(file_path) }
end

def find_markdown_files(dir)
  results = []

  walk = lambda do |current_dir|
    Dir.children(current_dir).sort.each do |name|
      full_path = File.join(current_dir, name)
      if File.directory?(full_path)
        walk.call(full_path) unless should_ignore?(full_path)
      elsif File.file?(full_path) && name.end_with?('.md')
        results << full_path unless should_ignore?(full_path)
      end
    end
  end

  walk.call(dir)
  results
end

def main
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    puts <<~HELP
      Usage: backfill-frontmatter.rb <brain-dir> [OPTIONS]

      Batch add frontmatter to all Brain markdown files.

      Options:
        --dry-run    Preview changes without modifying files
        --verbose    Print status for each file
        -h, --help   Show this help message

      Examples:
        ruby backfill-frontmatter.rb ~/Brain --dry-run
        ruby backfill-frontmatter.rb ~/Brain --verbose
    HELP
    exit 0
  end

  brain_dir = File.expand_path(ARGV[0])
  dry_run = ARGV.include?('--dry-run')
  verbose = ARGV.include?('--verbose')

  unless File.exist?(brain_dir)
    warn "Error: Directory not found: #{brain_dir}"
    exit 1
  end

  puts "#{dry_run ? '[DRY RUN] ' : ''}Scanning #{brain_dir} for markdown files..."

  files = find_markdown_files(brain_dir)
  puts "Found #{files.length} markdown files"

  added = 0
  skipped = 0
  errors = 0
  existing_uids = collect_existing_uids(brain_dir)

  files.each do |file_path|
    content = File.read(file_path)
    if has_frontmatter?(content)
      skipped += 1
      puts "  SKIP: #{file_path.sub("#{brain_dir}/", '')}" if verbose
      next
    end

    success = add_frontmatter(
      file_path,
      {
        dry_run: dry_run,
        verbose: verbose,
        brain_dir: brain_dir,
        existing_uids: existing_uids
      }
    )
    if success
      added += 1
      if !dry_run && !verbose
        # Print a dot for progress
        $stdout.write('.')
        $stdout.write("\n") if (added % 80).zero?
      end
    else
      errors += 1
    end
  rescue StandardError => e
    warn "  ERROR: #{file_path.sub("#{brain_dir}/", '')}: #{e.message}"
    errors += 1
  end

  $stdout.write("\n") if !dry_run && !verbose && added > 0

  puts "\nResults:"
  puts "  Added:   #{added}"
  puts "  Skipped: #{skipped} (already had frontmatter)"
  puts "  Errors:  #{errors}"
end

main
