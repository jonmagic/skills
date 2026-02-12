#!/usr/bin/env node
// Search the Brain index.
//
// Usage:
//   node brain-search.js "proxima"                      # Full-text search
//   node brain-search.js --tag proxima                   # Search by tag
//   node brain-search.js --type daily.project --tag hamzo # Combined query
//   node brain-search.js --linked-to <uid>               # Find records linking to UID
//   node brain-search.js --timeline proxima              # Chronological view of a topic
//   node brain-search.js --recent 7                      # Files modified in last N days
//   node brain-search.js --stats                         # Show index statistics

const fs = require('fs');
const path = require('path');

const DEFAULT_INDEX = path.join(process.env.HOME, '.brain-index.json');

function loadIndex(indexPath) {
  if (!fs.existsSync(indexPath)) {
    console.error(`Error: Index not found at ${indexPath}`);
    console.error(`Run: node brain-index.js ~/Brain`);
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(indexPath, 'utf-8'));
}

function searchFullText(records, query) {
  const terms = query.toLowerCase().split(/\s+/);
  return records
    .map(r => {
      const searchable = [
        r.title || '',
        r.summary || '',
        r.path || '',
        ...(r.tags || []),
      ].join(' ').toLowerCase();

      let score = 0;
      for (const term of terms) {
        if (searchable.includes(term)) {
          score++;
          // Boost for title matches
          if ((r.title || '').toLowerCase().includes(term)) score += 2;
          // Boost for tag matches
          if ((r.tags || []).some(t => t.includes(term))) score += 2;
          // Boost for path matches
          if ((r.path || '').toLowerCase().includes(term)) score += 1;
        }
      }
      return { record: r, score };
    })
    .filter(r => r.score > 0)
    .sort((a, b) => b.score - a.score);
}

function searchByTag(records, tag) {
  return records.filter(r => (r.tags || []).includes(tag));
}

function searchByType(records, type) {
  return records.filter(r => r.type === type);
}

function searchLinkedTo(records, uid) {
  return records.filter(r => {
    if (!r.links) return false;
    for (const values of Object.values(r.links)) {
      if (values.includes(uid)) return true;
    }
    return false;
  });
}

function searchRecent(records, days) {
  const cutoff = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
  return records.filter(r => new Date(r.mtime) >= cutoff)
    .sort((a, b) => new Date(b.mtime) - new Date(a.mtime));
}

function timelineView(records, query) {
  const terms = query.toLowerCase().split(/\s+/);
  const matches = records.filter(r => {
    const searchable = [
      r.title || '',
      r.summary || '',
      r.path || '',
      ...(r.tags || []),
    ].join(' ').toLowerCase();
    return terms.every(t => searchable.includes(t));
  });

  return matches.sort((a, b) => {
    const dateA = a.created || a.mtime;
    const dateB = b.created || b.mtime;
    return new Date(dateA) - new Date(dateB);
  });
}

function formatRecord(r, options = {}) {
  const lines = [];
  const dateStr = (r.created || r.mtime || '').slice(0, 10);
  const tags = (r.tags || []).map(t => `#${t}`).join(' ');

  if (options.timeline) {
    lines.push(`${dateStr}  ${r.title || r.path}`);
    if (r.summary) {
      lines.push(`          ${r.summary.slice(0, 120)}`);
    }
    lines.push(`          ${r.path}`);
  } else if (options.compact) {
    lines.push(`${r.path}${tags ? ' ' + tags : ''}`);
  } else {
    lines.push(`${r.title || '(untitled)'}`);
    lines.push(`  Path: ${r.path}`);
    if (r.uid) lines.push(`  UID:  ${r.uid}`);
    if (r.type) lines.push(`  Type: ${r.type}`);
    if (dateStr) lines.push(`  Date: ${dateStr}`);
    if (tags) lines.push(`  Tags: ${tags}`);
    if (r.summary) lines.push(`  ${r.summary.slice(0, 200)}`);
  }

  return lines.join('\n');
}

function showStats(index) {
  const records = index.records;
  console.log(`Brain Index Statistics`);
  console.log(`======================`);
  console.log(`Generated: ${index.generated}`);
  console.log(`Total records: ${records.length}`);

  // Type distribution
  const types = {};
  const tagCounts = {};
  let withTags = 0;
  let withUid = 0;
  let withLinks = 0;

  for (const r of records) {
    types[r.type || 'no-type'] = (types[r.type || 'no-type'] || 0) + 1;
    if (r.uid) withUid++;
    if (r.links) withLinks++;
    if (r.tags && r.tags.length > 0) {
      withTags++;
      for (const tag of r.tags) {
        tagCounts[tag] = (tagCounts[tag] || 0) + 1;
      }
    }
  }

  console.log(`\nCoverage:`);
  console.log(`  With UID:  ${withUid} (${Math.round(withUid/records.length*100)}%)`);
  console.log(`  With tags: ${withTags} (${Math.round(withTags/records.length*100)}%)`);
  console.log(`  With links: ${withLinks}`);

  console.log(`\nBy type:`);
  for (const [type, count] of Object.entries(types).sort((a, b) => b[1] - a[1])) {
    console.log(`  ${type}: ${count}`);
  }

  console.log(`\nAll tags (${Object.keys(tagCounts).length} unique):`);
  for (const [tag, count] of Object.entries(tagCounts).sort((a, b) => b[1] - a[1])) {
    console.log(`  ${tag}: ${count}`);
  }
}

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`Usage: brain-search.js [OPTIONS] [QUERY]

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
  --index <path>       Custom index path (default: ~/.brain-index.json)
  --stats              Show index statistics
  -h, --help           Show this help message

Types: daily.project, weekly.note, meeting.note, project, snippet,
       transcript, executive.summary, archive, reference

Examples:
  brain-search "proxima abuse"
  brain-search --tag hamzo --type daily.project
  brain-search --timeline "nuanced-enforcement"
  brain-search --recent 7
  brain-search --linked-to 3lz7nwvh4zc2u`);
    process.exit(0);
  }

  // Parse arguments
  let indexPath = DEFAULT_INDEX;
  let query = null;
  let tagFilter = null;
  let typeFilter = null;
  let linkedTo = null;
  let timeline = null;
  let recent = null;
  let limit = 20;
  let compact = args.includes('--compact');
  let showStatsFlag = args.includes('--stats');

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--index': indexPath = args[++i]; break;
      case '--tag': tagFilter = args[++i]; break;
      case '--type': typeFilter = args[++i]; break;
      case '--linked-to': linkedTo = args[++i]; break;
      case '--timeline': timeline = args[++i]; break;
      case '--recent': recent = parseInt(args[++i]); break;
      case '--limit': limit = parseInt(args[++i]); break;
      case '--compact': break; // already handled
      case '--stats': break; // already handled
      case '--help': case '-h': break;
      default:
        if (!args[i].startsWith('--')) {
          query = args[i];
        }
    }
  }

  const index = loadIndex(indexPath);

  if (showStatsFlag) {
    showStats(index);
    return;
  }

  let results = index.records;

  // Apply filters
  if (typeFilter) {
    results = searchByType(results, typeFilter);
  }

  if (tagFilter) {
    results = searchByTag(results, tagFilter);
  }

  if (linkedTo) {
    results = searchLinkedTo(results, linkedTo);
  }

  if (recent) {
    results = searchRecent(results, recent);
  }

  if (timeline) {
    results = timelineView(results, timeline);
    console.log(`Timeline: "${timeline}" (${results.length} records)\n`);
    for (const r of results.slice(0, limit)) {
      console.log(formatRecord(r, { timeline: true }));
      console.log('');
    }
    if (results.length > limit) {
      console.log(`... and ${results.length - limit} more (use --limit to show more)`);
    }
    return;
  }

  if (query) {
    const scored = searchFullText(results, query);
    console.log(`Search: "${query}" (${scored.length} results)\n`);
    for (const { record, score } of scored.slice(0, limit)) {
      console.log(formatRecord(record, { compact }));
      if (!compact) console.log('');
    }
    if (scored.length > limit) {
      console.log(`... and ${scored.length - limit} more (use --limit to show more)`);
    }
    return;
  }

  // No query, just filters
  if (typeFilter || tagFilter || linkedTo || recent) {
    // Sort by date descending
    results.sort((a, b) => {
      const dateA = a.created || a.mtime || '';
      const dateB = b.created || b.mtime || '';
      return dateB.localeCompare(dateA);
    });

    console.log(`Filter results: ${results.length} records\n`);
    for (const r of results.slice(0, limit)) {
      console.log(formatRecord(r, { compact }));
      if (!compact) console.log('');
    }
    if (results.length > limit) {
      console.log(`... and ${results.length - limit} more (use --limit to show more)`);
    }
    return;
  }

  console.error('No search query or filter specified. Use --help for usage.');
  process.exit(1);
}

main();
