#!/usr/bin/env ruby
# frozen_string_literal: true

# Auto-tag Brain files based on content keyword matching against the tag vocabulary.
#
# Usage:
#   ruby auto-tag.rb ~/Brain --dry-run
#   ruby auto-tag.rb ~/Brain
#   ruby auto-tag.rb ~/Brain --verbose
#   ruby auto-tag.rb ~/Brain --max-tags 4

# Tag -> keyword patterns (case-insensitive).
# Each tag has an array of patterns. A file gets a tag if ANY pattern matches.
# Patterns are tested against the full file content (minus frontmatter).
TAG_RULES = {
  # Work Projects
  'proxima' => [/\bproxima\b/i, /\bazure.*github enterprise\b/i, /\bGHES\b/],
  'nuanced-enforcement' => [/\bnuanced.?enforcement\b/i, /\bbeyond the spammy flag\b/i, /\bprogressive access\b/i,
                            /\btrust tier/i],
  'rate-limiting' => [/\brate.?limit/i, /\bDDoS\b/i, /\brate limiting committee\b/i],
  'tech-debt' => [/\btech.?debt\b/i, /\blegacy.*deprecat/i, /\bSpamConsole\b/i, /\bSpamQueue\b/i,
                  /\bmonolith.*extract/i],
  'spiral-funnel' => [/\bspiral.?funnel\b/i],
  'hamzo' => [/\bhamzo\b/i, /\brules?.engine.*abuse\b/i],
  'spamurai' => [/\bspamurai/i, /\bspam-slam\b/i],
  'spam-slam' => [/\bspam.?slam\b/i, /\bkusto.*cron/i],
  'copilot-abuse' => [/\bcopilot.*abuse\b/i, /\btrial.*farm/i, /\bcopilot.*fraud\b/i, /\bcopilot.*resale\b/i],
  'octocaptcha' => [/\boctocaptcha\b/i, /\bcaptcha.*system\b/i, /\bcaptcha.*SLO\b/i],
  'datadome' => [/\bdatadome\b/i],
  'compliance' => [/\bdatabank\b/i, /\bwindbeam\b/i, /\bDSR processing\b/i, /\bMSIA\b/i, /\bdata catalog/i,
                   /\bauto.?classif/i],
  'vibe' => [/\bvibe\b.*\b(vm|session|sandbox|worker)\b/i, /\bvibe-session\b/i, /\bvibe-worker\b/i,
             /\bApple Virtualization\b/i],

  # Technical Domains
  'abuse-detection' => [/\babuse.*detect/i, /\banti.?abuse\b/i, /\bspam.*detect/i, /\bfraud.*detect/i,
                        /\bscraping.*detect/i],
  'machine-learning' => [/\bAI reviewer\b/i, /\bmodel.*train/i, /\brules?.to.?signals?\b/i, /\bmachine learning\b/i],
  'llm' => [/\bLLM\b/, /\bAzure OpenAI\b/i, /\blarge language model/i, /\bGPT-?4\b/i, /\bsource routing\b/i],
  'stream-processing' => [/\bKafka\b/, /\bFlink\b/i, /\bphlink/i, /\bHydro\b/, /\bAqueduct\b/i, /\bstream.*process/i],
  'data-governance' => [/\bdata.*governance\b/i, /\bprivacy.*engineer/i],
  'agent-skills' => [/\bagent.?skill/i, /\bMCP\b/, /\bskill.*regist/i, /\bcopilot.*skill/i, /\bSKILL\.md\b/],
  'billing' => [/\bAzure.*billing\b/i, /\bPRU\b/, /\bmetered.*billing\b/i, /\bZuora\b/i],
  'enforcement' => [/\btrust.*tier/i, /\bprogressive.*access\b/i, /\breputation.*system/i, /\benforcement.*action/i],
  'infrastructure' => [/\bKubernetes\b/i, /\bk8s\b/i, /\bSLO\b/, /\bobservability\b/i, /\bdeployment.*pipeline/i],

  # Activities
  'architecture' => [/\bADR\b/, /\barchitecture.*proposal\b/i, /\bsystem.*design\b/i, /\barchitectural.*decision/i],
  'research' => [/\bdeep.*dive\b/i, /\blandscape.*analysis\b/i, /\bresearch.*session\b/i, /\bcompetitive.*research\b/i],
  'interview' => [/\binterview\b/i, /\bstakeholder.*interview/i, /\buser.*research\b/i],
  'proposal' => [/\bRFC\b/, /\bproposal\b/i, /\bdecision.*document/i],
  'retrospective' => [/\bretro(?:spective)?\b/i, /\bsemester.*reflect/i, /\blessons.*learned\b/i],
  'planning' => [/\bOKR/i, /\broadmap\b/i, /\bsprint.*plan/i, /\bproject.*plan/i],
  'workshop' => [/\bworkshop\b/i, /\bbrown.*bag\b/i, /\btraining.*session\b/i],
  'mentoring' => [/\b1:1 with\b/i, /\bone.on.one meeting\b/i, /\bcareer.*develop/i, /\bcoaching session\b/i],
  'blog' => [/\bblog.*post\b/i, /\bblog.*draft\b/i, /\bwriting.*publication\b/i],
  'incident' => [/\bincident.*response\b/i, /\bpostmortem\b/i],

  # Teams
  'safety-engineering' => [/\bPlatform Health Engineering\b/i, /\bRachel Cohen\b/i, /\bsafety.*engineering\b/i],
  'safety-operations' => [/\bPlatform Health Operations\b/i, /\bMelissa McDonough\b/i, /\bsafety.*operations\b/i],
  'compliance-engineering' => [/\bCompliance Engineering\b/i, /\bRobb Tvorik\b/i],
  'identity' => [/\bIdentity.*team\b/i, /\bUsers D team\b/i],
  'actions-compute' => [/\bActions Compute\b/i],

  # Personal
  'gardening' => [/\bgarden/i, /\bplant.*care\b/i, /\bvolunteer.*hour/i],
  'cocktails' => [/\bcocktail/i, /\bmixolog/i],
  'home-network' => [/\bNAS\b/, /\bnetwork.*security\b/i, /\bhome.*infra/i],
  'how-i-work' => [/\bworkflow.*design\b/i, /\bhow.?i.?work\b/i],

  # Meta
  'brain-architecture' => [/\bbrain.*architecture\b/i, /\bfrontmatter.*schema\b/i, /\bTID\b/, /\bprojection/i,
                           /\bsecond.?brain\b/i],
  'pkm' => [/\bpersonal.*knowledge\b/i, /\bPKM\b/, /\bknowledge.*management\b/i, /\bObsidian\b/i]
}.freeze

# Some tags are too broad -- they need a minimum score (multiple pattern matches)
# or we only apply them when other more specific tags aren't present
BROAD_TAGS = Set.new(%w[
                       abuse-detection enforcement infrastructure planning
                       interview proposal research architecture
                     ]).freeze

# Maximum tags per file
DEFAULT_MAX_TAGS = 4

def parse_frontmatter(content)
  return [nil, content, nil] unless content.start_with?("---\n")

  lines = content.split("\n")
  end_index = -1
  (1...lines.length).each do |i|
    if lines[i].strip == '---'
      end_index = i
      break
    end
  end

  return [nil, content, nil] if end_index == -1

  fm_lines = lines[0..end_index]
  body = lines[(end_index + 1)..].join("\n")

  # Parse simple fields
  fm = {}
  (1...end_index).each do |i|
    line = lines[i]
    colon_idx = line.index(':')
    next unless colon_idx

    key = line[0...colon_idx].strip
    value = line[(colon_idx + 1)..].strip
    fm[key] = value
  end

  [fm, body, fm_lines]
end

def compute_tags(content, max_tags)
  tag_scores = {}

  TAG_RULES.each do |tag, patterns|
    match_count = patterns.count { |p| p.match?(content) }
    tag_scores[tag] = match_count if match_count > 0
  end

  # Sort by score descending
  sorted_tags = tag_scores.sort_by { |_, score| -score }

  # If we have specific tags, deprioritize broad tags
  specific_tags = sorted_tags.reject { |t, _| BROAD_TAGS.include?(t) }
  if specific_tags.any?
    # Keep broad tags only if they have high scores (2+ matches)
    sorted_tags = sorted_tags.reject { |t, score| BROAD_TAGS.include?(t) && score < 2 }
  end

  sorted_tags.first(max_tags).map(&:first)
end

def add_tags_to_frontmatter(fm_lines, tags)
  new_lines = fm_lines.dup

  # Find existing tags line
  existing_tag_idx = new_lines.index { |l| l.start_with?('tags:') }
  if existing_tag_idx
    # Replace existing
    new_lines[existing_tag_idx] = "tags: [#{tags.join(', ')}]"
  else
    # Insert before links or closing ---
    insert_idx = new_lines.length - 1 # Before closing ---
    links_idx = new_lines.index { |l| l.start_with?('links:') }
    insert_idx = links_idx if links_idx
    new_lines.insert(insert_idx, "tags: [#{tags.join(', ')}]")
  end

  new_lines
end

def process_file(file_path, options = {})
  content = File.read(file_path)
  fm, body, fm_lines = parse_frontmatter(content)

  unless fm
    # No frontmatter, skip
    return { status: 'skip-no-fm', tags: [] }
  end

  # If already has tags, skip unless --force
  return { status: 'skip-has-tags', tags: [] } if fm['tags'] && fm['tags'] != '[]' && !options[:force]

  tags = compute_tags(body, options[:max_tags] || DEFAULT_MAX_TAGS)

  return { status: 'no-match', tags: [] } if tags.empty?

  return { status: 'would-tag', tags: tags } if options[:dry_run]

  # Write tags
  new_fm_lines = add_tags_to_frontmatter(fm_lines, tags)
  new_content = new_fm_lines.join("\n") + body
  File.write(file_path, new_content)

  { status: 'tagged', tags: tags }
end

def find_markdown_files_for_tagging(dir)
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

def main
  if ARGV.empty? || ARGV.include?('--help') || ARGV.include?('-h')
    puts <<~HELP
      Usage: auto-tag.rb <brain-dir> [OPTIONS]

      Auto-tag Brain files based on content keyword matching.

      Options:
        --dry-run       Preview tags without modifying files
        --verbose       Print status for each file
        --force         Re-tag files that already have tags
        --max-tags N    Maximum tags per file (default: 4)
        -h, --help      Show this help message
    HELP
    exit 0
  end

  brain_dir = File.expand_path(ARGV[0])
  dry_run = ARGV.include?('--dry-run')
  verbose = ARGV.include?('--verbose')
  force = ARGV.include?('--force')
  max_tags_idx = ARGV.index('--max-tags')
  max_tags = max_tags_idx ? ARGV[max_tags_idx + 1].to_i : DEFAULT_MAX_TAGS

  puts "#{dry_run ? '[DRY RUN] ' : ''}Auto-tagging files in #{brain_dir}..."

  files = find_markdown_files_for_tagging(brain_dir)
  puts "Found #{files.length} markdown files"

  stats = Hash.new(0)
  tag_counts = Hash.new(0)

  files.each do |file_path|
    result = process_file(file_path, { dry_run: dry_run, force: force, max_tags: max_tags })
    stats[result[:status]] += 1

    result[:tags].each { |tag| tag_counts[tag] += 1 }

    if verbose || (dry_run && !result[:tags].empty?)
      rel = file_path.sub("#{brain_dir}/", '')
      if !result[:tags].empty?
        puts "  #{result[:status].upcase}: #{rel} -> [#{result[:tags].join(', ')}]"
      elsif verbose
        puts "  #{result[:status].upcase}: #{rel}"
      end
    end

    if !dry_run && !verbose && result[:status] == 'tagged'
      $stdout.write('.')
      $stdout.write("\n") if (stats['tagged'] % 80).zero?
    end
  rescue StandardError => e
    warn "  ERROR: #{file_path.sub("#{brain_dir}/", '')}: #{e.message}"
    stats['errors'] += 1
  end

  $stdout.write("\n") if !dry_run && !verbose && stats['tagged'] > 0

  puts "\nResults:"
  puts "  Tagged:          #{[stats['tagged'], stats['would-tag']].max}"
  puts "  No frontmatter:  #{stats['skip-no-fm']}"
  puts "  Already tagged:  #{stats['skip-has-tags']}"
  puts "  No tag match:    #{stats['no-match']}"
  puts "  Errors:          #{stats['errors']}"

  return if tag_counts.empty?

  puts "\nTag distribution:"
  tag_counts.sort_by { |_, count| -count }.each do |tag, count|
    puts "  #{tag}: #{count}"
  end
end

main
