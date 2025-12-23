#!/usr/bin/env ruby

require 'base64'
require 'fileutils'
require 'net/http'
require 'optparse'
require 'pathname'
require 'tempfile'
require 'uri'

IMG_MD_RE = /!\[[^\]]*\]\(([^)]+)\)/
IMG_HTML_RE = /<img[^>]+src=["']([^"']+)["']/i

def die(msg, code = 1)
  warn msg
  exit code
end

def ensure_tool(name)
  unless system("which #{name} > /dev/null 2>&1")
    die("Required tool not found on PATH: #{name}\nInstall it and re-run.", 2)
  end
end

def run_pandoc(md_path)
  ensure_tool('pandoc')
  output = `pandoc #{Shellwords.escape(md_path)} 2>&1`
  unless $?.success?
    die(output, $?.exitstatus)
  end
  output
end

def process_github_alerts(html)
  # Convert blockquotes with [!TYPE] into GitHub-style alert divs
  # Pattern: <blockquote><p>[!NOTE] content</p></blockquote>

  html.gsub(%r{<blockquote>\s*<p>\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*(.+?)</p>(\s*<p>.*?</p>)*\s*</blockquote>}m) do |match|
    alert_type = $1.downcase
    title = $1.capitalize

    # Extract all paragraphs within the blockquote
    blockquote_content = match.match(%r{<blockquote>(.*)</blockquote>}m)[1]

    # Remove the [!TYPE] marker from the first paragraph
    content = blockquote_content.sub(%r{\[!#{alert_type.upcase}\]\s*}, '')

    # Create the alert div with title
    %{<div class="markdown-alert markdown-alert-#{alert_type}"><p class="markdown-alert-title">#{title}</p>#{content}</div>}
  end
end

def guess_mime(path)
  ext = File.extname(path).downcase
  case ext
  when '.jpg', '.jpeg' then 'image/jpeg'
  when '.png' then 'image/png'
  when '.gif' then 'image/gif'
  when '.webp' then 'image/webp'
  when '.svg' then 'image/svg+xml'
  when '.bmp' then 'image/bmp'
  when '.ico' then 'image/x-icon'
  else 'application/octet-stream'
  end
end

def to_data_uri(path)
  mime = guess_mime(path)
  data = Base64.strict_encode64(File.binread(path))
  "data:#{mime};base64,#{data}"
end

def url?(str)
  str.start_with?('http://', 'https://')
end

def url_filename(url)
  uri = URI.parse(url)
  name = File.basename(uri.path)
  name.empty? ? 'image' : name
end

def download_to_temp(url, temp_dir)
  FileUtils.mkdir_p(temp_dir)
  dest = File.join(temp_dir, url_filename(url))

  # Prevent collisions
  i = 1
  while File.exist?(dest)
    base = File.basename(dest, '.*')
    ext = File.extname(dest)
    dest = File.join(temp_dir, "#{base}-#{i}#{ext}")
    i += 1
  end

  uri = URI.parse(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    response = http.get(uri.path.empty? ? '/' : uri.path)
    File.binwrite(dest, response.body)
  end

  dest
end

def resolve_image(src, md_dir, temp_dir)
  src = src.strip.gsub(/^["']|["']$/, '')

  die('Internal error: asked to resolve a data: URI') if src.start_with?('data:')

  # 1) Relative to markdown
  rel = File.expand_path(src, md_dir)
  return rel if File.exist?(rel)

  # 2) Absolute local path
  abs_path = File.expand_path(src)
  return abs_path if File.exist?(abs_path)

  # 3) URL
  if url?(src)
    puts "[img] downloading #{src}"
    return download_to_temp(src, temp_dir)
  end

  # 4) Prompt
  puts "[img] cannot find locally: #{src}"
  puts "Enter a local file path OR a public URL to download:"
  loop do
    print "> "
    entered = gets.strip

    if entered.empty?
      puts "Please enter a path or URL."
      next
    end

    if url?(entered)
      puts "[img] downloading #{entered}"
      return download_to_temp(entered, temp_dir)
    end

    path = File.expand_path(entered)
    return path if File.exist?(path)

    puts "That path does not exist. Try again."
  end
end

def main
  require 'shellwords'

  ensure_tool('ruby')

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} MARKDOWN --title TITLE --template TEMPLATE --out OUTPUT"

    opts.on('--title TITLE', 'Title for the HTML document') { |v| options[:title] = v }
    opts.on('--template PATH', 'Path to HTML template') { |v| options[:template] = v }
    opts.on('--out PATH', 'Output HTML file path') { |v| options[:out] = v }
  end.parse!

  die("Missing required argument: markdown file") if ARGV.empty?
  die("Missing required argument: --title") unless options[:title]
  die("Missing required argument: --template") unless options[:template]
  die("Missing required argument: --out") unless options[:out]

  markdown_path = ARGV[0]
  die("Markdown file not found: #{markdown_path}") unless File.exist?(markdown_path)
  die("Template file not found: #{options[:template]}") unless File.exist?(options[:template])

  md_text = File.read(markdown_path, encoding: 'utf-8')
  template = File.read(options[:template], encoding: 'utf-8')
  fragment = run_pandoc(markdown_path)

  md_imgs = md_text.scan(IMG_MD_RE).flatten.map(&:strip)
  html_imgs = fragment.scan(IMG_HTML_RE).flatten.map(&:strip)

  images = (md_imgs + html_imgs).uniq.reject { |src| src.empty? || src.start_with?('data:') }

  md_dir = File.dirname(File.expand_path(markdown_path))

  Dir.mktmpdir('md2standalone_') do |temp_dir|
    src_to_data = {}
    images.each do |src|
      local = resolve_image(src, md_dir, temp_dir)
      src_to_data[src] = to_data_uri(local)
    end

    fragment = fragment.gsub(IMG_HTML_RE) do |match|
      src = $1
      match.sub(src, src_to_data[src] || src)
    end

    # Process GitHub-style alerts
    fragment = process_github_alerts(fragment)

    out_html = template
      .gsub('{{TITLE}}', options[:title])
      .gsub('{{CONTENT}}', fragment)

    FileUtils.mkdir_p(File.dirname(options[:out]))
    File.write(options[:out], out_html, encoding: 'utf-8')
    puts "Wrote: #{options[:out]}"
  end
end

main if __FILE__ == $0
