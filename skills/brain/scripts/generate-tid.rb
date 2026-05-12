#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate a TID (Timestamp ID) following the AT Protocol specification.
# TIDs are sortable, timestamp-based identifiers.
#
# Format: 13 characters, base32-sortable encoding
# - First 11 chars: microseconds since Unix epoch (53 bits)
# - Last 2 chars: clock ID (10 bits) for collision avoidance
#
# Usage:
#   ruby generate-tid.rb
#   ruby generate-tid.rb --timestamp "2026-01-24T00:00:00Z"

require 'set'
require 'time'

# Base32-sortable alphabet (same as AT Protocol)
# Chosen so alphabetic sort = numeric sort
BASE32_SORTABLE = '234567abcdefghijklmnopqrstuvwxyz'

def encode_base32_sortable(value, length)
  result = ''
  v = value
  length.times do
    result = BASE32_SORTABLE[v & 0x1f] + result
    v >>= 5
  end
  result
end

def parse_tid_timestamp(timestamp)
  return Time.now unless timestamp
  return timestamp if timestamp.is_a?(Time)

  Time.parse(timestamp.to_s)
end

def clock_id_for_seed(seed)
  hash = 0x811c9dc5
  seed.to_s.each_codepoint do |codepoint|
    hash ^= codepoint
    hash = (hash * 0x01000193) & 0xffffffff
  end
  hash & 0x3ff
end

def generate_tid(timestamp = nil, clock_id = nil)
  ts = parse_tid_timestamp(timestamp)

  # Microseconds since Unix epoch (53 bits max)
  micros = (ts.to_f * 1_000_000).floor

  # Clock ID: random 10-bit value for collision avoidance
  clock_id ||= rand(1024)

  # Encode timestamp (11 chars = 55 bits, we use 53)
  timestamp_encoded = encode_base32_sortable(micros, 11)

  # Encode clock ID (2 chars = 10 bits)
  clock_encoded = encode_base32_sortable(clock_id, 2)

  timestamp_encoded + clock_encoded
end

def generate_unique_tid(existing_uids, timestamp = nil, seed = nil)
  existing = existing_uids.is_a?(Set) ? existing_uids : existing_uids.to_set
  base_time = parse_tid_timestamp(timestamp)
  initial_clock_id = seed && !seed.to_s.empty? ? clock_id_for_seed(seed) : rand(1024)
  attempt = 0

  loop do
    timestamp_offset_ms = attempt / 1024
    candidate_time = base_time + Rational(timestamp_offset_ms, 1000)
    clock_id = (initial_clock_id + attempt) % 1024
    candidate = generate_tid(candidate_time, clock_id)
    return candidate unless existing.include?(candidate)

    attempt += 1
  end
end

# CLI interface
if __FILE__ == $0
  if ARGV.include?('--help') || ARGV.include?('-h')
    puts <<~HELP
      Usage: generate-tid.rb [OPTIONS]

      Generate a TID (Timestamp ID) for Brain frontmatter.

      Options:
        --timestamp DATE   Use specific timestamp (ISO 8601 format)
        -h, --help         Show this help message

      Examples:
        ruby generate-tid.rb
        ruby generate-tid.rb --timestamp "2026-01-24T12:00:00Z"
    HELP
    exit 0
  end

  timestamp = nil
  ts_index = ARGV.index('--timestamp')
  timestamp = ARGV[ts_index + 1] if ts_index && ARGV[ts_index + 1]

  puts generate_tid(timestamp)
end
