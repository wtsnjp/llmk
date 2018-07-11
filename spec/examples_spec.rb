require 'spec_helper'
require 'llmk_helper'
require 'fileutils'
require 'pathname'

RSpec.configure do |c|
  c.include Helplers
end

RSpec.describe "Processing example", :type => :aruba do
  # constants
  PWD = Pathname.pwd
  EXAMPLE_DIR = PWD + "examples"
  WORKING_DIR = PWD + "tmp/aruba"

  before(:all) { set_default_env }
  before(:each) { FileUtils.cp_r "#{EXAMPLE_DIR}/.", WORKING_DIR }

  context "llmk.toml" do
    before(:each) { run_llmk }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end

  context "default.tex" do
    before(:each) { run_llmk "default.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
  
  context "simple.tex" do
    before(:each) { run_llmk "simple.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
  
  context "complex.tex" do
    before(:each) { run_llmk "complex.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
  
  context "platex.tex" do
    before(:each) { run_llmk "platex.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
end
