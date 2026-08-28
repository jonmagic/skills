require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "pathname"
require "tmpdir"

class FetchPrimaryArtifactsTest < Minitest::Test
  SCRIPT = Pathname.new(__dir__).join("..", "scripts", "fetch-primary-artifacts").expand_path

  def setup
    @tmpdir = Dir.mktmpdir
    @bin_dir = Pathname.new(@tmpdir).join("bin")
    @bin_dir.mkpath
    @gh_log = Pathname.new(@tmpdir).join("gh.log")
    write_fake_gh
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_fetches_active_issue_and_flattens_timeline
    output = Pathname.new(@tmpdir).join("artifacts")
    stdout, stderr, status = run_script(output, "github/example#42")

    assert status.success?, stderr
    assert_includes stdout, "Fetched primary artifacts for 1 issue(s)"
    assert_equal 2, JSON.parse(output.join("github-example-42-timeline.json").read).length

    audit = JSON.parse(output.join("audit.json").read)
    assert_equal "success", audit.dig("authentication", "status")
    assert_equal "active", audit.dig("issues", 0, "selection_status")
    assert_equal 2, audit.dig("issues", 0, "timeline_event_count")
    assert_equal ["success", "success", "success", "success"], audit.dig("issues", 0, "commands").map { |entry| entry["status"] }
  end

  def test_excludes_archived_repository_without_fetching_issue
    output = Pathname.new(@tmpdir).join("artifacts")
    _stdout, stderr, status = run_script(output, "github/archived#7")

    assert_equal 2, status.exitstatus
    assert_includes stderr, "replace those candidates"
    refute output.join("github-archived-7-issue.json").exist?
  end

  def test_rejects_pull_request_candidate
    output = Pathname.new(@tmpdir).join("artifacts")
    _stdout, stderr, status = run_script(output, "github/pull#12")

    refute status.success?
    assert_includes stderr, "is a pull request, not an issue"
  end

  def test_fails_closed_when_primary_issue_is_unreadable
    output = Pathname.new(@tmpdir).join("artifacts")
    _stdout, stderr, status = run_script(output, "github/unreadable#9")

    refute status.success?
    assert_includes stderr, "Primary issue retrieval failed"
  end

  def test_falls_back_when_relationship_fields_are_unsupported
    output = Pathname.new(@tmpdir).join("artifacts")
    stdout, stderr, status = run_script(output, "github/legacy-gh#8")

    assert status.success?, stderr
    assert_includes stdout, "Fetched primary artifacts"
    audit = JSON.parse(output.join("audit.json").read)
    assert_equal "unavailable", audit.dig("issues", 0, "relationship_fields_status")
    commands = audit.dig("issues", 0, "commands")
    assert_equal ["failure", "success"], commands.slice(2, 2).map { |entry| entry["status"] }
  end

  def test_writes_audit_on_authentication_failure
    output = Pathname.new(@tmpdir).join("artifacts")
    _stdout, stderr, status = run_script(output, "github/example#42", "GH_TEST_AUTH_FAIL" => "1")

    refute status.success?
    assert_includes stderr, "GitHub authentication failed"
    assert_equal "failure", JSON.parse(output.join("audit.json").read).dig("authentication", "status")
  end

  def test_rejects_invalid_issue_spec
    output = Pathname.new(@tmpdir).join("artifacts")
    _stdout, stderr, status = run_script(output, "not-an-issue")

    refute status.success?
    assert_includes stderr, "expected OWNER/REPO#NUMBER"
  end

  def test_rejects_nonempty_output_directory
    output = Pathname.new(@tmpdir).join("artifacts")
    output.mkpath
    output.join("existing.json").write("{}")
    _stdout, stderr, status = run_script(output, "github/example#42")

    refute status.success?
    assert_includes stderr, "Output directory must be empty"
  end

  def test_rejects_output_inside_git_worktree
    repo = Pathname.new(@tmpdir).join("repo")
    repo.mkpath
    system("git", "-C", repo.to_s, "init", "--quiet")
    output = repo.join("artifacts")
    _stdout, stderr, status = run_script(output, "github/example#42")

    refute status.success?
    assert_includes stderr, "Refusing to write raw artifacts inside Git worktree"
  end

  private

  def run_script(output, *specs)
    extra_env = specs.last.is_a?(Hash) ? specs.pop : {}
    Open3.capture3(
      {"PATH" => "#{@bin_dir}:#{ENV.fetch("PATH")}", "GH_TEST_LOG" => @gh_log.to_s}.merge(extra_env),
      "ruby", SCRIPT.to_s, "--output", output.to_s, *specs
    )
  end

  def write_fake_gh
    fake = @bin_dir.join("gh")
    fake.write(<<~'RUBY')
      #!/usr/bin/env ruby
      require "json"

      File.open(ENV.fetch("GH_TEST_LOG"), "a") { |file| file.puts(ARGV.join(" ")) }

      if ARGV == ["auth", "status"]
        if ENV["GH_TEST_AUTH_FAIL"]
          warn "not authenticated"
          exit 1
        end
        puts "authenticated"
      elsif ARGV[0, 2] == ["repo", "view"]
        repo = ARGV[2]
        puts JSON.generate({
          "isArchived" => repo == "github/archived",
          "nameWithOwner" => repo,
          "url" => "https://github.com/#{repo}",
          "visibility" => "PRIVATE",
          "isPrivate" => true,
          "viewerPermission" => "ADMIN",
          "hasIssuesEnabled" => true
        })
      elsif ARGV[0, 2] == ["api", "repos/github/pull/issues/12"]
        puts JSON.generate({"pull_request" => {"url" => "https://api.github.com/pulls/12"}})
      elsif ARGV[0] == "api" && ARGV[1]&.start_with?("repos/") && !ARGV.include?("--paginate")
        puts JSON.generate({"number" => ARGV[1].split("/").last.to_i})
      elsif ARGV[0, 2] == ["issue", "view"] && ARGV[2] == "9"
        warn "not readable"
        exit 1
      elsif ARGV[0, 2] == ["issue", "view"] && ARGV[4] == "github/legacy-gh" && ARGV.last.include?("parent")
        warn "Unknown JSON field: parent"
        exit 1
      elsif ARGV[0, 2] == ["issue", "view"]
        number = ARGV[2].to_i
        repo = ARGV[4]
        puts JSON.generate({
          "number" => number,
          "title" => "Example",
          "state" => "OPEN",
          "stateReason" => nil,
          "body" => "Body",
          "comments" => [],
          "url" => "https://github.com/#{repo}/issues/#{number}"
        })
      elsif ARGV[0, 4] == ["api", "--paginate", "--slurp", "-H"]
        puts JSON.generate([[{"event" => "labeled"}], [{"event" => "commented"}]])
      else
        warn "unexpected arguments: #{ARGV.inspect}"
        exit 1
      end
    RUBY
    fake.chmod(0o755)
  end
end
