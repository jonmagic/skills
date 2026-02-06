#!/usr/bin/env ruby
# frozen_string_literal: true

# Convert a WebVTT transcript to readable Markdown.
#
# This is a "good enough" converter for Teams downloads. Teams VTTs vary; this
# script handles the common patterns:
# - cue timestamps: `HH:MM:SS.mmm --> HH:MM:SS.mmm`
# - speaker via `<v Speaker Name>` tags
# - inline text without explicit speaker tags
#
# Output format (Markdown):
# - `- [HH:MM:SS] Speaker: text`
#
# If speaker is unknown, omit it.
#
# Note: We do not attempt perfect deduping, punctuation repair, or diarization.
# That's better handled at the LLM summarization stage.

require "optparse"

CUE_RE = /^(?<start>\d{2}:\d{2}:\d{2}(?:\.\d{3})?)\s+-->\s+(?<end>\d{2}:\d{2}:\d{2}(?:\.\d{3})?)/
VOICE_TAG_RE = /<v\s+(?<speaker>[^>]+)>(?<text>.*)<\/v>/

def expand_path(path)
  File.expand_path(path)
end

def normalize_ts(ts)
  # Keep HH:MM:SS, drop milliseconds if present
  ts.split(".").first
end

def convert(vtt_text)
  lines = vtt_text.lines.map { |ln| ln.chomp }

  out = []
  i = 0
  while i < lines.length
    line = lines[i].strip

    # Skip headers and blank lines
    if line.empty? || line.upcase.start_with?("WEBVTT") || line.start_with?("NOTE")
      i += 1
      next
    end

    m = CUE_RE.match(line)
    unless m
      i += 1
      next
    end

    start = normalize_ts(m[:start])

    # Consume cue payload lines until blank
    i += 1
    payload = []
    while i < lines.length && !lines[i].strip.empty?
      payload << lines[i].strip
      i += 1
    end

    speaker = nil
    text_parts = []

    payload.each do |p|
      vm = VOICE_TAG_RE.match(p)
      if vm
        speaker = (vm[:speaker] || "").strip
        text = (vm[:text] || "").strip
        text_parts << text unless text.empty?
      else
        # Heuristic: `Speaker: text` prefix
        if p.include?(":") && p.split(":", 2).first.length <= 60
          maybe_speaker, rest = p.split(":", 2)
          if maybe_speaker && !rest.strip.empty?
            speaker ||= maybe_speaker.strip
            text_parts << rest.strip
          else
            text_parts << p
          end
        else
          text_parts << p
        end
      end
    end

    text = text_parts.reject(&:empty?).join(" ").strip
    if text.empty?
      i += 1
      next
    end

    if speaker
      out << "- [#{start}] #{speaker}: #{text}"
    else
      out << "- [#{start}] #{text}"
    end

    i += 1
  end

  out.join("\n").rstrip + "\n"
end

# Main execution
options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby vtt_to_markdown.rb INPUT [options]"

  opts.on("--output PATH", "Path to write .md (defaults to stdout)") do |v|
    options[:output] = v
  end
end.parse!

input_path = ARGV[0]

unless input_path
  warn "error: input path required"
  exit 1
end

input_path = expand_path(input_path)
text = File.read(input_path, encoding: "utf-8")
md = convert(text)

if options[:output]
  output_path = expand_path(options[:output])
  File.write(output_path, md, encoding: "utf-8")
else
  print md
end
