#!/usr/bin/env ruby
# frozen_string_literal: true

# Detect the current agent session and output the resume command.
#
# Usage: detect-session.rb [--json] [--project-dir DIR]
#
# Detects which agent tool is running (opencode, copilot, claude) by checking
# environment variables, then resolves the current session ID by finding the
# most recently active session.
#
# Output (default): the resume command string, e.g. "opencode -s ses_abc123"
# Output (--json):  { "tool": "opencode", "sessionId": "ses_abc123", "resume": "opencode -s ses_abc123" }
#
# Exit code 0 if a session was detected, 1 if not.

require 'json'
require 'digest'

json_output = ARGV.include?('--json')
project_dir_idx = ARGV.index('--project-dir')
project_dir = if project_dir_idx && ARGV[project_dir_idx + 1]
                ARGV[project_dir_idx + 1]
              else
                Dir.pwd
              end

def detect_tool
  return 'opencode' if ENV['OPENCODE'] == '1'
  return 'copilot' if ENV['COPILOT_PROXY_TOKEN_CMD']
  # Claude doesn't set a known env var, but check common indicators
  return 'claude' if ENV['CLAUDE_CODE'] == '1' || ENV['CLAUDE'] == '1'

  nil
end

def resolve_opencode_session(project_dir)
  # OpenCode stores sessions in ~/.local/share/opencode/storage/session/<project-hash>/
  # The project hash is SHA-1 of the absolute project directory path.
  abs_dir = File.expand_path(project_dir)
  project_hash = Digest::SHA1.hexdigest(abs_dir)

  session_dir = File.join(Dir.home, '.local/share/opencode/storage/session', project_hash)
  return nil unless File.exist?(session_dir)

  # Find the most recently modified session file (by mtime on the message dir,
  # which is more reliable than the session JSON's internal timestamps since
  # the session JSON may not be flushed as frequently).
  message_dir = File.join(Dir.home, '.local/share/opencode/storage/message')

  # Read all session files to get their IDs
  session_files = Dir.children(session_dir)
                     .select { |f| f.start_with?('ses_') && f.end_with?('.json') }

  return nil if session_files.empty?

  # Find the session with the most recently modified message directory
  best_session = nil
  best_mtime = 0

  session_files.each do |file|
    session_id = file.sub('.json', '')
    msg_dir = File.join(message_dir, session_id)

    mtime = if File.exist?(msg_dir)
              File.stat(msg_dir).mtime.to_f
            else
              # Fall back to session file mtime
              File.stat(File.join(session_dir, file)).mtime.to_f
            end

    if mtime > best_mtime
      best_mtime = mtime
      best_session = session_id
    end
  end

  best_session
end

def resolve_copilot_session
  # Copilot stores sessions in ~/.copilot/session-state/<UUID>/
  session_state_dir = File.join(Dir.home, '.copilot/session-state')
  return nil unless File.exist?(session_state_dir)

  # Find the most recently modified session directory (by events.jsonl mtime)
  entries = Dir.children(session_state_dir).select do |name|
    # UUID pattern: 8-4-4-4-12 hex chars
    name.match?(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)
  end

  return nil if entries.empty?

  best_session = nil
  best_mtime = 0

  entries.each do |uuid|
    events_file = File.join(session_state_dir, uuid, 'events.jsonl')
    next unless File.exist?(events_file)

    mtime = File.stat(events_file).mtime.to_f
    if mtime > best_mtime
      best_mtime = mtime
      best_session = uuid
    end
  end

  best_session
end

def build_resume_command(tool, session_id)
  case tool
  when 'opencode'
    "opencode -s #{session_id}"
  when 'copilot'
    "copilot --resume=#{session_id}"
  when 'claude'
    "claude --resume #{session_id}"
  end
end

# Main
tool = detect_tool
unless tool
  $stderr.write("No agent tool detected (checked OPENCODE, COPILOT_PROXY_TOKEN_CMD, CLAUDE_CODE)\n")
  exit 1
end

session_id = case tool
             when 'opencode'
               resolve_opencode_session(project_dir)
             when 'copilot'
               resolve_copilot_session
             when 'claude'
               # No known reliable detection mechanism for Claude sessions yet
               $stderr.write("Claude session detection not yet supported\n")
               exit 1
             end

unless session_id
  $stderr.write("Could not resolve session ID for #{tool}\n")
  exit 1
end

resume = build_resume_command(tool, session_id)

if json_output
  puts JSON.generate({ tool: tool, sessionId: session_id, resume: resume })
else
  puts resume
end
