require 'spec_helper'

RSpec.describe "Showing version", :type => :aruba do
  include_context "messages"

  let(:version) { "1.1.0" }
  let(:copyright) { "Copyright 2018-2023" }

  let(:version_text) do
    <<~EXPECTED
      llmk #{version}

      #{copyright} Takuto Asakura (wtsnjp).
      License: The MIT License <https://opensource.org/licenses/mit-license>.
      This is free software: you are free to change and redistribute it.
    EXPECTED
  end

  context "with --version" do
    before(:each) { run_llmk "--version" }
    before(:each) { stop_all_commands }

    it do
      expect(stdout).to eq version_text
      expect(last_command_started).to be_successfully_executed
    end
  end

  context "with -V" do
    before(:each) { run_llmk "-V" }
    before(:each) { stop_all_commands }

    it do
      expect(stdout).to eq version_text
      expect(last_command_started).to be_successfully_executed
    end
  end
end
