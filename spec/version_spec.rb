require 'spec_helper'
require 'llmk_helper'

RSpec.configure do |c|
  c.include Helplers
end

RSpec.describe "Showing version", :type => :aruba do
  let(:version) { "0.0.0" }

  let(:version_text) do
<<~EXPECTED
llmk #{version}

Copyright 2018 Takuto ASAKURA (wtsnjp).
License: The MIT License <https://opensource.org/licenses/mit-license>.
This is free software: you are free to change and redistribute it.
EXPECTED
  end

  before(:all) { set_default_env }

  context "with --version" do
    before(:each) { run_llmk "--version" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started.stdout.gsub("\r", "")).to eq version_text }
  end

  context "with -V" do
    before(:each) { run_llmk "-V" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started.stdout.gsub("\r", "")).to eq version_text }
  end
end
