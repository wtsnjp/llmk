require 'spec_helper'

RSpec.describe "Showing help", :type => :aruba do
  include_context "messages"

  let(:help_text) do
    <<~EXPECTED
      Usage: llmk [OPTION]... [FILE]...

      Options:
        -c, --clean           Remove the temporary files such as aux and log files.
        -C, --clobber         Remove all generated files including final PDFs.
        -d CAT, --debug=CAT   Activate debug output restricted to CAT.
        -D, --debug           Activate all debug output (equal to "--debug=all").
        -h, --help            Print this help message.
        -q, --quiet           Suppress most messages.
        -s, --silent          Silence messages from called programs.
        -v, --verbose         Print additional information.
        -V, --version         Print the version number.

      Please report bugs to <tkt.asakura@gmail.com>.
    EXPECTED
  end

  context "with --help" do
    before(:each) { run_llmk "--help" }
    before(:each) { stop_all_commands }

    it do
      expect(stdout).to eq help_text
      expect(last_command_started).to be_successfully_executed
    end
  end

  context "with -h" do
    before(:each) { run_llmk "-h" }
    before(:each) { stop_all_commands }

    it do
      expect(stdout).to eq help_text
      expect(last_command_started).to be_successfully_executed
    end
  end
end
