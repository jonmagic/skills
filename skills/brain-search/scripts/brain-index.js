#!/usr/bin/env node
// Build a JSON index of all Brain markdown files.
//
// Scans all markdown files, parses frontmatter (uid, type, created, tags, links),
// extracts the first heading (title) and first paragraph (summary),
// and outputs a JSON index file.
//
// Usage:
//   node brain-index.js ~/Brain                    # Output to ~/.brain-index.json
//   node brain-index.js ~/Brain -o /path/to/out    # Custom output path
//   node brain-index.js ~/Brain --stats            # Print stats after indexing

const fs = require('fs');
const path = require('path');

function parseFrontmatter(content) {
  if (!content.startsWith('---\n')) {
    return [null, content];
  }

  const lines = content.split('\n');
  let endIndex = -1;
  for (let i = 1; i < lines.length; i++) {
    if (lines[i].trim() === '---') {
      endIndex = i;
      break;
    }
  }

  if (endIndex === -1) {
    return [null, content];
  }

  const fm = {};
  let currentKey = null;
  let currentSubKey = null;

  for (let i = 1; i < endIndex; i++) {
    const line = lines[i];

    // Sub-key (indented, like links.parent)
    if (line.match(/^\s{2}\w+:/)) {
      const colonIdx = line.indexOf(':');
      const key = line.slice(0, colonIdx).trim();
      let value = line.slice(colonIdx + 1).trim();
      if (currentKey && value) {
        if (!fm[currentKey]) fm[currentKey] = {};
        fm[currentKey][key] = parseArrayValue(value);
      }
      continue;
    }

    const colonIdx = line.indexOf(':');
    if (colonIdx !== -1) {
      const key = line.slice(0, colonIdx).trim();
      let value = line.slice(colonIdx + 1).trim();

      // Remove quotes
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      }

      if (key === 'tags') {
        fm[key] = parseArrayValue(value);
      } else if (key === 'links') {
        fm[key] = {};
        currentKey = 'links';
      } else {
        fm[key] = value;
        currentKey = key;
      }
    }
  }

  const body = lines.slice(endIndex + 1).join('\n').replace(/^\n+/, '');
  return [fm, body];
}

function parseArrayValue(value) {
  if (!value || value === '[]') return [];
  // Parse [item1, item2] format
  const match = value.match(/^\[(.*)\]$/);
  if (match) {
    return match[1].split(',').map(s => s.trim()).filter(s => s.length > 0);
  }
  return [value];
}

function extractTitle(body) {
  const lines = body.split('\n');
  for (const line of lines) {
    const match = line.match(/^#+\s+(.+)/);
    if (match) {
      return match[1].trim();
    }
  }
  // Fallback: first non-empty line
  for (const line of lines) {
    if (line.trim()) {
      return line.trim().slice(0, 100);
    }
  }
  return '';
}

function extractSummary(body, maxLength = 300) {
  const lines = body.split('\n');
  let foundHeading = false;
  const paragraphLines = [];

  for (const line of lines) {
    if (line.match(/^#+\s/)) {
      if (foundHeading && paragraphLines.length > 0) break;
      foundHeading = true;
      continue;
    }
    if (foundHeading && line.trim()) {
      paragraphLines.push(line.trim());
    } else if (foundHeading && !line.trim() && paragraphLines.length > 0) {
      break;
    }
  }

  const summary = paragraphLines.join(' ');
  if (summary.length > maxLength) {
    return summary.slice(0, maxLength) + '...';
  }
  return summary;
}

function findMarkdownFiles(dir) {
  const results = [];
  function walk(currentDir) {
    const entries = fs.readdirSync(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        if (!entry.name.startsWith('.') && entry.name !== 'node_modules') {
          walk(fullPath);
        }
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        results.push(fullPath);
      }
    }
  }
  walk(dir);
  return results;
}

function indexFile(filePath, brainDir) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const [fm, body] = parseFrontmatter(content);
  const relativePath = path.relative(brainDir, filePath);
  const stats = fs.statSync(filePath);

  const record = {
    path: relativePath,
    title: extractTitle(body),
    summary: extractSummary(body),
    size: stats.size,
    mtime: stats.mtime.toISOString(),
  };

  if (fm) {
    if (fm.uid) record.uid = fm.uid;
    if (fm.type) record.type = fm.type;
    if (fm.created) record.created = fm.created;
    if (fm.updated) record.updated = fm.updated;
    if (fm.tags && fm.tags.length > 0) record.tags = fm.tags;
    if (fm.links) {
      const links = {};
      for (const [key, values] of Object.entries(fm.links)) {
        if (values && values.length > 0) {
          links[key] = values;
        }
      }
      if (Object.keys(links).length > 0) record.links = links;
    }
  }

  return record;
}

function buildIndex(brainDir) {
  const files = findMarkdownFiles(brainDir);
  const records = [];
  let errors = 0;

  for (const filePath of files) {
    try {
      records.push(indexFile(filePath, brainDir));
    } catch (err) {
      console.error(`Error indexing ${filePath}: ${err.message}`);
      errors++;
    }
  }

  return {
    version: 1,
    brainDir: brainDir,
    generated: new Date().toISOString(),
    count: records.length,
    errors: errors,
    records: records,
  };
}

function printStats(index) {
  console.log(`\nIndex Stats:`);
  console.log(`  Total records: ${index.count}`);
  console.log(`  Errors: ${index.errors}`);
  console.log(`  Generated: ${index.generated}`);

  // Type distribution
  const types = {};
  const tagCounts = {};
  let withTags = 0;
  let withUid = 0;

  for (const record of index.records) {
    const type = record.type || 'no-type';
    types[type] = (types[type] || 0) + 1;
    if (record.uid) withUid++;
    if (record.tags && record.tags.length > 0) {
      withTags++;
      for (const tag of record.tags) {
        tagCounts[tag] = (tagCounts[tag] || 0) + 1;
      }
    }
  }

  console.log(`  With UID: ${withUid}`);
  console.log(`  With tags: ${withTags}`);

  console.log(`\n  By type:`);
  for (const [type, count] of Object.entries(types).sort((a, b) => b[1] - a[1])) {
    console.log(`    ${type}: ${count}`);
  }

  console.log(`\n  Top 10 tags:`);
  const sortedTags = Object.entries(tagCounts).sort((a, b) => b[1] - a[1]).slice(0, 10);
  for (const [tag, count] of sortedTags) {
    console.log(`    ${tag}: ${count}`);
  }
}

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`Usage: brain-index.js <brain-dir> [OPTIONS]

Build a JSON index of all Brain markdown files.

Options:
  -o, --output PATH   Output file path (default: ~/.brain-index.json)
  --stats             Print index statistics
  -h, --help          Show this help message`);
    process.exit(0);
  }

  const brainDir = path.resolve(args[0]);
  const showStats = args.includes('--stats');

  let outputPath = path.join(process.env.HOME, '.brain-index.json');
  const outIdx = args.indexOf('-o') !== -1 ? args.indexOf('-o') : args.indexOf('--output');
  if (outIdx !== -1 && args[outIdx + 1]) {
    outputPath = path.resolve(args[outIdx + 1]);
  }

  if (!fs.existsSync(brainDir)) {
    console.error(`Error: Directory not found: ${brainDir}`);
    process.exit(1);
  }

  console.log(`Indexing ${brainDir}...`);
  const index = buildIndex(brainDir);

  fs.writeFileSync(outputPath, JSON.stringify(index, null, 2));
  console.log(`Index written to ${outputPath} (${index.count} records)`);

  if (showStats) {
    printStats(index);
  }
}

main();
