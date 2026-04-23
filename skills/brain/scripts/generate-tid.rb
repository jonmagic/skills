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

def generate_tid(timestamp = nil)
  ts = if timestamp
         Time.parse(timestamp)
       else
         Time.now
       end

  # Microseconds since Unix epoch (53 bits max)
  micros = (ts.to_f * 1_000_000).floor

  # Clock ID: random 10-bit value for collision avoidance
  clock_id = rand(1024)

  # Encode timestamp (11 chars = 55 bits, we use 53)
  timestamp_encoded = encode_base32_sortable(micros, 11)

  # Encode clock ID (2 chars = 10 bits)
  clock_encoded = encode_base32_sortable(clock_id, 2)

  timestamp_encoded + clock_encoded
end

# CLI interface
if __FILE__ == $0
  require 'time'

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
