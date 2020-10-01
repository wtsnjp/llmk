require 'fileutils'
require 'pathname'
require 'spec_helper'

RSpec.describe "Errors", :type => :aruba do
  include_context "messages"

  def write_file fn, content
    pwd = Pathname.pwd
    File.open(pwd / "tmp/aruba" / fn, 'w') do |f|
      f.puts content
    end
  end

  context "if the source file does not exist" do
    before(:each) do
      write_file "llmk.toml", <<~TOML
        source = "foo.tex"
        latex = "true"  # must be succeed
      TOML
    end

    before(:each) { run_llmk "-v" }
    before(:each) { stop_all_commands }

    it 'result in a general error' do
      expect(stderr).to eq <<~EXPECTED
        llmk error: Source file "foo.tex" does not exist
      EXPECTED

      expect(last_command_started).to have_exit_status(1)
    end
  end

  context "using not existing command" do
    before(:each) { write_file "foo.tex", "" }
    before(:each) do
      write_file "llmk.toml", <<~TOML
        source = "foo.tex"
        latex = "false"  # must be failed
      TOML
    end

    before(:each) { run_llmk "-v" }
    before(:each) { stop_all_commands }

    it 'result in "invoked command failure" error' do
      expect(stderr).to eq <<~EXPECTED
        llmk info: Beginning a sequence for "foo.tex"
        llmk info: Running command: false -interaction=nonstopmode -file-line-error -synctex=1 "foo.tex"
        llmk error: Fail running false -interaction=nonstopmode -file-line-error -synctex=1 "foo.tex" (exit code: 256)
      EXPECTED

      expect(last_command_started).to have_exit_status(2)
    end
  end

  context "if invalid TOML syntax" do
    before(:each) do
      write_file "llmk.toml", <<~TOML
        source = invalid  # invalid primitive
      TOML
    end

    before(:each) { run_llmk "-v" }
    before(:each) { stop_all_commands }

    it 'result in a parser error' do
      expect(stderr).to eq <<~EXPECTED
        llmk error: [Parse Error] Invalid primitive
        llmk error: --> llmk.toml:1: source = invalid  # invalid primitive
      EXPECTED

      expect(last_command_started).to have_exit_status(3)
    end
  end

  context "if a wrong value given" do
    before(:each) do
      write_file "llmk.toml", <<~TOML
        source = false  # should be string
      TOML
    end

    before(:each) { run_llmk "-v" }
    before(:each) { stop_all_commands }

    it 'result in a type error' do
      expect(stderr).to eq <<~EXPECTED
        llmk error: [Type Error] Key "source" must have value of type *[string]
      EXPECTED

      expect(last_command_started).to have_exit_status(4)
    end
  end
end
