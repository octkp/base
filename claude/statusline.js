#!/usr/bin/env node

const fs = require('fs');
const { execSync } = require('child_process');

function getGitBranch(cwd) {
  try {
    return execSync('git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null', {
      encoding: 'utf-8',
      cwd: cwd
    }).trim();
  } catch {
    return null;
  }
}

function getGitChanges(cwd) {
  try {
    const status = execSync('git --no-optional-locks status --porcelain 2>/dev/null', {
      encoding: 'utf-8',
      cwd: cwd
    });
    const lines = status.trim().split('\n').filter(l => l);
    return lines.length > 0 ? lines.length : null;
  } catch {
    return null;
  }
}

function getGitDiffStats(cwd) {
  try {
    // staged + unstaged の両方を取得
    const diff = execSync('git --no-optional-locks diff --numstat HEAD 2>/dev/null', {
      encoding: 'utf-8',
      cwd: cwd
    });
    let added = 0, deleted = 0;
    diff.trim().split('\n').filter(l => l).forEach(line => {
      const [a, d] = line.split('\t');
      if (a !== '-') added += parseInt(a, 10) || 0;
      if (d !== '-') deleted += parseInt(d, 10) || 0;
    });
    return (added || deleted) ? { added, deleted } : null;
  } catch {
    return null;
  }
}

function getLanguage() {
  try {
    const settingsPath = require('path').join(require('os').homedir(), '.claude', 'settings.json');
    const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf-8'));
    return settings.language || null;
  } catch {
    return null;
  }
}

function main() {
  try {
    const input = fs.readFileSync(0, 'utf-8');
    const data = JSON.parse(input);

    const parts = [];

    // Model name
    if (data.model?.display_name) {
      parts.push(data.model.display_name);
    }

    // Language
    const lang = getLanguage();
    if (lang) {
      parts.push(`lang: ${lang}`);
    }

    // Git branch (cwdから取得)
    const cwd = data.cwd || process.cwd();
    const branch = getGitBranch(cwd);
    if (branch) {
      const changes = getGitChanges(cwd);
      const diffStats = getGitDiffStats(cwd);
      let branchInfo = branch;
      if (changes) {
        branchInfo += ` (${changes} files`;
        if (diffStats) {
          branchInfo += ` +${diffStats.added} -${diffStats.deleted}`;
        }
        branchInfo += ')';
      }
      parts.push(`branch: ${branchInfo}`);
    }

    // Context window usage
    const ctx = data.context_window;
    if (ctx) {
      const usage = ctx.current_usage || {};
      const used = (usage.input_tokens || 0) +
                   (usage.output_tokens || 0) +
                   (usage.cache_creation_input_tokens || 0) +
                   (usage.cache_read_input_tokens || 0);
      const total = ctx.context_window_size || 200000;
      const percent = Math.round((used / total) * 100);
      const formatK = (n) => n >= 1000 ? Math.round(n / 1000) + 'k' : n.toString();
      parts.push(`context: ${formatK(used)}/${formatK(total)} (${percent}%)`);
    }

    console.log(parts.join(' | ') || data.model?.display_name || 'Claude Code');
  } catch (e) {
    console.log('Claude Code');
  }
}

main();
