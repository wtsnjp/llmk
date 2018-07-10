require 'spec_helper'
require 'llmk_helper'

RSpec.configure do |c|
  c.include Helplers
end

RSpec.describe "Showing help", :type => :aruba do
  let(:help_text) do
<<~EXPECTED
Usage: llmk[.lua] [OPTION...] [FILE...]

Options:
  -h, --help            Print this help message.
  -V, --version         Print the version number.

  -q, --quiet           Suppress warnings and most error messages.
  -v, --verbose         Print additional information.
  -D, --debug           Activate all debug output (equal to "--debug=all").
  -d CAT, --debug=CAT   Activate debug output restricted to CAT.

Please report bugs to <tkt.asakura@gmail.com>.
EXPECTED
  end

  context "with --help" do
    before(:each) { run_llmk "--help" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started.stdout.gsub("\r", "")).to eq help_text }
  end
  
  context "with -h" do
    before(:each) { run_llmk "-h" }
    before(:each) { stop_all_commands }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started.stdout.gsub("\r", "")).to eq help_text }
  end
end
