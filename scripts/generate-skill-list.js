#!/usr/bin/env node
/*
  Scans for Agent Skills and updates the skills/README.md list between markers.
  - Looks in `skills/` and `.github/skills/` for subfolders containing SKILL.md
  - Extracts `name` and `description` from YAML frontmatter (best-effort)
  - Renders a Markdown list with links relative to skills/README.md
*/
const fs = require('fs');
const path = require('path');

const repoRoot = process.cwd();
const skillsReadmePath = path.join(repoRoot, 'README.md');
const searchRoots = [
  path.join(repoRoot, 'skills'),
  path.join(repoRoot, '.github', 'skills'),
];

function safeRead(p) {
  try { return fs.readFileSync(p, 'utf8'); } catch { return null; }
}

function parseFrontmatter(md) {
  if (!md) return {};
  // crude YAML frontmatter parser
  const fmStart = md.indexOf('---');
  if (fmStart !== 0) return {};
  const fmEnd = md.indexOf('\n---', 3);
  if (fmEnd === -1) return {};
  const fm = md.slice(3, fmEnd).split('\n');
  const out = {};
  for (const line of fm) {
    const m = line.match(/^\s*([A-Za-z0-9_-]+)\s*:\s*(.*)\s*$/);
    if (m) {
      const key = m[1].trim();
      let val = m[2].trim();
      // strip wrapping quotes
      if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
        val = val.slice(1, -1);
      }
      out[key] = val;
    }
  }
  return out;
}

function listSkillDirs(rootDir) {
  const result = [];
  if (!fs.existsSync(rootDir)) return result;
  for (const entry of fs.readdirSync(rootDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    if (entry.name.startsWith('.')) continue;
    const dir = path.join(rootDir, entry.name);
    const skillMd = path.join(dir, 'SKILL.md');
    if (fs.existsSync(skillMd)) {
      result.push(dir);
    }
  }
  return result;
}

function collectSkills() {
  const allDirs = new Set();
  for (const root of searchRoots) {
    for (const d of listSkillDirs(root)) allDirs.add(d);
  }
  const skills = [];
  for (const absDir of Array.from(allDirs)) {
    const mdPath = path.join(absDir, 'SKILL.md');
    const md = safeRead(mdPath) || '';
    const fm = parseFrontmatter(md);
    const name = (fm.name && String(fm.name)) || path.basename(absDir);
    const description = (fm.description && String(fm.description)) || '';
    skills.push({ absDir, name, description });
  }
  // sort by name, case-insensitive
  skills.sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
  return skills;
}

function renderList(skills) {
  if (!skills.length) {
    return '_No skills yet. Add a folder with a SKILL.md to appear here._';
  }
  const readmeDir = path.dirname(skillsReadmePath);
  return skills.map(s => {
    const rel = path.relative(readmeDir, s.absDir).replace(/\\/g, '/');
    const link = rel.endsWith('/') ? rel : rel + '/';
    const desc = s.description ? ` — ${s.description}` : '';
    return `- [${s.name}](${link})${desc}`;
  }).join('\n');
}

function updateReadme(content) {
  const START = '<!-- SKILLS-LIST:START -->';
  const END = '<!-- SKILLS-LIST:END -->';
  const readme = safeRead(skillsReadmePath) || '';
  if (!readme.includes(START) || !readme.includes(END)) {
    // Append a section if markers are missing
    const section = `\n\n## Skills\n\n${START}\n${content}\n${END}\n`;
    return readme + section;
  }
  const before = readme.split(START)[0];
  const after = readme.split(END)[1] ?? '';
  return `${before}${START}\n${content}\n${END}${after}`;
}

(function main() {
  const skills = collectSkills();
  const listMd = renderList(skills);
  const updated = updateReadme(listMd);
  fs.mkdirSync(path.dirname(skillsReadmePath), { recursive: true });
  fs.writeFileSync(skillsReadmePath, updated);
  console.log(`Updated skills list with ${skills.length} item(s).`);
})();
