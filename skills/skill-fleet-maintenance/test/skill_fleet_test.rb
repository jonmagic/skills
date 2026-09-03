#!/usr/bin/env ruby

require "fileutils"
require "json"
require "minitest/autorun"
require "tmpdir"
require_relative "../lib/skill_fleet"

class SkillFleetTest < Minitest::Test
  def with_tmp
    Dir.mktmpdir("skill-fleet-test-") { |tmp| yield tmp }
  end

  def write_skill(root, name:, frontmatter_name: name, broken_link: false)
    directory = File.join(root, name)
    FileUtils.mkdir_p(File.join(directory, "evals"))
    link = broken_link ? "\n[Missing](references/missing.md)\n" : ""
    File.write(
      File.join(directory, "SKILL.md"),
      <<~MARKDOWN
        ---
        name: #{frontmatter_name}
        description: Use this skill when testing the fleet validator.
        metadata:
          owner: "@tester"
          source: "https://example.invalid"
          last-verified: "2026-07-17"
          review-by: "2099-01-01"
        ---

        # Test Skill
        #{link}
      MARKDOWN
    )
    File.write(
      File.join(directory, "evals", "evals.json"),
      JSON.pretty_generate(
        {
          skill_name: frontmatter_name,
          evals: [
            {
              id: "specific",
              prompt: "Reject an unsafe action.",
              expected_output: "A refusal.",
              files: [],
              assertions: ["Refuses the unsafe action"]
            }
          ]
        }
      )
    )
    File.write(
      File.join(directory, "evals", "trigger-queries.json"),
      JSON.pretty_generate(
        [
          { query: "test one", should_trigger: true, reason: "in scope" },
          { query: "test two", should_trigger: true, reason: "in scope" },
          { query: "test three", should_trigger: true, reason: "in scope" },
          { query: "near one", should_trigger: false, reason: "out of scope" },
          { query: "near two", should_trigger: false, reason: "out of scope" },
          { query: "near three", should_trigger: false, reason: "out of scope" }
        ]
      )
    )
    directory
  end

  def test_valid_skill_passes
    with_tmp do |tmp|
      write_skill(tmp, name: "test-skill")
      skills = SkillFleet::Discovery.new(roots: [tmp]).discover
      validator = SkillFleet::Validator.new(skills).validate
      assert_empty validator.errors
    end
  end

  def test_name_mismatch_and_broken_link_fail
    with_tmp do |tmp|
      write_skill(
        tmp,
        name: "test-skill",
        frontmatter_name: "wrong-name",
        broken_link: true
      )
      skills = SkillFleet::Discovery.new(roots: [tmp]).discover
      validator = SkillFleet::Validator.new(skills).validate
      messages = validator.errors.map(&:message)
      assert messages.any? { |message| message.include?("does not match parent directory") }
      assert messages.any? { |message| message.include?("broken local reference") }
    end
  end

  def test_reference_files_can_link_from_skill_root
    with_tmp do |tmp|
      directory = write_skill(tmp, name: "test-skill")
      FileUtils.mkdir_p(File.join(directory, "references"))
      File.write(File.join(directory, "references", "target.md"), "# Target\n")
      File.write(
        File.join(directory, "references", "nested.md"),
        "Read `references/target.md`.\n"
      )

      skills = SkillFleet::Discovery.new(roots: [directory]).discover
      validator = SkillFleet::Validator.new(skills).validate
      refute validator.errors.any? { |finding| finding.message.include?("target.md") }
    end
  end

  def test_legacy_eval_schema_is_supported_with_warnings
    with_tmp do |tmp|
      directory = write_skill(tmp, name: "test-skill")
      File.write(
        File.join(directory, "evals", "evals.json"),
        JSON.pretty_generate(
          [
            {
              name: "legacy",
              prompt: "Do the safe thing.",
              expected_behavior: "Refuse an unsafe action."
            }
          ]
        )
      )
      triggers = JSON.parse(
        File.read(File.join(directory, "evals", "trigger-queries.json"))
      )
      triggers.each { |item| item.delete("reason") }
      File.write(
        File.join(directory, "evals", "trigger-queries.json"),
        JSON.pretty_generate(triggers)
      )

      skills = SkillFleet::Discovery.new(roots: [directory]).discover
      validator = SkillFleet::Validator.new(skills).validate
      assert_empty validator.errors
      assert validator.warnings.any? { |finding| finding.message.include?("legacy output eval array") }
      assert validator.warnings.any? { |finding| finding.message.include?("should include a reason") }
    end
  end

  def test_copilot_run_detects_skill_tool_event
    with_tmp do |tmp|
      skill_directory = write_skill(tmp, name: "test-skill")
      skill = SkillFleet::Discovery.new(roots: [skill_directory]).discover.first
      fake = File.join(tmp, "fake-copilot")
      File.write(
        fake,
        <<~'SH'
          #!/bin/sh
          if [ -e "$COPILOT_HOME/skills/test-skill" ]; then
            printf '%s\n' '{"type":"session.skills_loaded","data":{"skills":[{"name":"test-skill"}]}}'
            printf '%s\n' '{"type":"tool.execution_start","data":{"toolName":"skill","arguments":{"skill":"test-skill"}}}'
          else
            printf '%s\n' '{"type":"session.skills_loaded","data":{"skills":[]}}'
          fi
          printf '%s\n' '{"type":"assistant.message","data":{"content":"response"}}'
        SH
      )
      FileUtils.chmod(0o700, fake)

      with_skill = SkillFleet::CopilotRun.new(
        prompt: "test",
        skill: skill,
        copilot_bin: fake
      ).execute
      baseline = SkillFleet::CopilotRun.new(
        prompt: "test",
        copilot_bin: fake
      ).execute

      assert with_skill.invoked?("test-skill")
      assert with_skill.event_schema_valid?
      refute baseline.invoked?("test-skill")
      refute_includes baseline.loaded_skill_names, "test-skill"
    end
  end

  def test_copilot_run_rejects_unknown_event_schema
    with_tmp do |tmp|
      fake = File.join(tmp, "fake-copilot")
      File.write(
        fake,
        <<~'SH'
          #!/bin/sh
          printf '%s\n' '{"type":"session.skills_changed","data":{"skills":[]}}'
          printf '%s\n' '{"type":"assistant.output","data":{"content":"response"}}'
        SH
      )
      FileUtils.chmod(0o700, fake)

      run = SkillFleet::CopilotRun.new(
        prompt: "test",
        copilot_bin: fake
      ).execute

      refute run.event_schema_valid?
      refute run.success?
    end
  end
end
