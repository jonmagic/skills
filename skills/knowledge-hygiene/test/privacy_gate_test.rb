require "fileutils"
require "minitest/autorun"
require "open3"
require "pathname"
require "tmpdir"

class PrivacyGateTest < Minitest::Test
  SCRIPT = Pathname.new(__dir__).join("..", "scripts", "privacy-gate").expand_path

  def setup
    @tmpdir = Dir.mktmpdir
    @bin_dir = Pathname.new(@tmpdir).join("bin")
    @bin_dir.mkpath
    write_fake_gh
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_blocks_local_path
    _stdout, stderr, status = run_gate("See /Users/example/notes/source.md.", "github/private-target")

    refute status.success?
    assert_includes stderr, "blocked a local workspace"
  end

  def test_blocks_markdown_link_to_local_path
    _stdout, stderr, status = run_gate("See [note](/Users/example/notes/source.md).", "github/private-target")

    refute status.success?
    assert_includes stderr, "blocked a local workspace"
  end

  def test_blocks_parenthesized_tilde_path
    _stdout, stderr, status = run_gate("Context (~/notes/source.md) here.", "github/private-target")

    refute status.success?
    assert_includes stderr, "blocked a local workspace"
  end

  def test_blocks_bare_home_directory
    _stdout, stderr, status = run_gate("Path: /Users/example", "github/private-target")

    refute status.success?
    assert_includes stderr, "blocked a local workspace"
  end

  def test_blocks_windows_home_path
    _stdout, stderr, status = run_gate('Path: C:\Users\example\notes\source.md', "github/private-target")

    refute status.success?
    assert_includes stderr, "blocked a local workspace"
  end

  def test_blocks_file_url
    _stdout, stderr, status = run_gate("See file:///tmp/private-note.md.", "github/private-target")

    refute status.success?
    assert_includes stderr, "blocked a local workspace"
  end

  def test_blocks_wikilink
    _stdout, stderr, status = run_gate("See [[private source]].", "github/private-target")

    refute status.success?
    assert_includes stderr, "blocked a local workspace"
  end

  def test_blocks_configured_literal
    deny_file = Pathname.new(@tmpdir).join("deny.txt")
    deny_file.write("# Private markers\ninternal.example.test\n")
    _stdout, stderr, status = run_gate(
      "Context: https://internal.example.test/run/123",
      "github/private-target",
      deny_file
    )

    refute status.success?
    assert_includes stderr, "configured private marker"
  end

  def test_blocks_private_repository_reference_for_public_target
    _stdout, stderr, status = run_gate("See https://github.com/github/private-reference/issues/1", "github/public-target")

    refute status.success?
    assert_includes stderr, "blocked private repository reference"
  end

  def test_blocks_scheme_less_private_repository_url
    _stdout, stderr, status = run_gate("See github.com/github/private-reference/issues/1", "github/public-target")

    refute status.success?
    assert_includes stderr, "blocked private repository reference"
  end

  def test_blocks_http_private_repository_url
    _stdout, stderr, status = run_gate("See http://github.com/github/private-reference/issues/1", "github/public-target")

    refute status.success?
    assert_includes stderr, "blocked private repository reference"
  end

  def test_blocks_www_private_repository_url
    _stdout, stderr, status = run_gate("See https://www.github.com/github/private-reference/issues/1", "github/public-target")

    refute status.success?
    assert_includes stderr, "blocked private repository reference"
  end

  def test_blocks_private_raw_content_url
    _stdout, stderr, status = run_gate("See https://raw.githubusercontent.com/github/private-reference/main/file.md", "github/public-target")

    refute status.success?
    assert_includes stderr, "blocked private repository reference"
  end

  def test_blocks_scheme_less_private_raw_content_url
    _stdout, stderr, status = run_gate("See raw.githubusercontent.com/github/private-reference/main/file.md", "github/public-target")

    refute status.success?
    assert_includes stderr, "blocked private repository reference"
  end

  def test_blocks_private_repository_shorthand_for_public_target
    _stdout, stderr, status = run_gate("Superseded by github/private-reference#42.", "github/public-target")

    refute status.success?
    assert_includes stderr, "blocked private repository reference"
  end

  def test_allows_public_repository_reference_for_public_target
    stdout, stderr, status = run_gate("See https://github.com/github/public-reference/issues/1", "github/public-target")

    assert status.success?, stderr
    assert_includes stdout, "Privacy gate passed"
  end

  def test_allows_autolinked_public_repository
    stdout, stderr, status = run_gate("<https://github.com/github/public-reference>", "github/public-target")

    assert status.success?, stderr
    assert_includes stdout, "Privacy gate passed"
  end

  def test_allows_public_repository_url_ending_a_sentence
    stdout, stderr, status = run_gate("See https://github.com/github/public-reference.", "github/public-target")

    assert status.success?, stderr
    assert_includes stdout, "Privacy gate passed"
  end

  def test_allows_gist_url_without_classifying_it_as_a_repository
    stdout, stderr, status = run_gate("See https://gist.github.com/octocat/aa11bb22.", "github/public-target")

    assert status.success?, stderr
    assert_includes stdout, "Privacy gate passed"
  end

  def test_allows_unlisted_reference_for_private_target
    stdout, stderr, status = run_gate("Context: https://internal.example.test/run/123", "github/private-target")

    assert status.success?, stderr
    assert_includes stdout, "Privacy gate passed"
  end

  def test_allows_non_repository_github_url
    stdout, stderr, status = run_gate("See https://github.com/features/copilot.", "github/public-target")

    assert status.success?, stderr
    assert_includes stdout, "Privacy gate passed"
  end

  def test_deny_markers_are_case_insensitive
    deny_file = Pathname.new(@tmpdir).join("deny.txt")
    deny_file.write("InternalHost\n")
    _stdout, stderr, status = run_gate("See https://internalhost.example/run.", "github/private-target", deny_file)

    refute status.success?
    assert_includes stderr, "configured private marker"
  end

  private

  def run_gate(body, target, deny_file = nil)
    body_file = Pathname.new(@tmpdir).join("body-#{rand(1_000_000)}.md")
    body_file.write(body)
    command = ["ruby", SCRIPT.to_s, "--body", body_file.to_s, "--target", target]
    command.concat(["--deny-file", deny_file.to_s]) if deny_file
    Open3.capture3({"PATH" => "#{@bin_dir}:#{ENV.fetch("PATH")}"}, *command)
  end

  def write_fake_gh
    fake = @bin_dir.join("gh")
    fake.write(<<~'RUBY')
      #!/usr/bin/env ruby
      require "json"

      repo = ARGV[2]
      if repo.end_with?(".")
        warn "repository not found"
        exit 1
      end
      private_repo = repo.include?("private")
      puts JSON.generate({"isPrivate" => private_repo, "visibility" => private_repo ? "PRIVATE" : "PUBLIC"})
    RUBY
    fake.chmod(0o755)
  end
end
