require 'spec_helper'
require 'llmk_helper'
require 'pathname'

RSpec.configure do |c|
  c.include Helplers
end

RSpec.describe "Processing example", :type => :aruba do
  # constants
  PWD = Pathname.pwd
  EXAMPLE_DIR = PWD + "examples"
  before(:all) { set_default_env }

  #context "llmk.toml" do
  #  before(:each) { run_llmk }
  #  before(:each) { stop_all_commands }
  #  before(:each) { puts last_command_started.stderr }
  #  it { expect(last_command_started).to be_successfully_executed }
  #end

  context "default.tex" do
    before(:each) { run_llmk "#{EXAMPLE_DIR}/default.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
  
  context "simple.tex" do
    before(:each) { run_llmk "#{EXAMPLE_DIR}/simple.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
  
  context "complex.tex" do
    before(:each) { run_llmk "#{EXAMPLE_DIR}/complex.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
  
  context "platex.tex" do
    before(:each) { run_llmk "#{EXAMPLE_DIR}/platex.tex" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
  end
end
