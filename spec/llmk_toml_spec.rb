require 'spec_helper'

RSpec.describe "Various llmk.toml", :type => :aruba do
  include_context "examples"
  include_context "messages"

  let(:llmk_toml_path) { base_dir / "tmp/aruba/llmk.toml" }

  context "llmk.toml without new line at the end" do
    let(:content) { 'source = "default.tex"' }
    before(:each) { use_example "default.tex" }
    before(:each) { File.write(llmk_toml_path, content) }
    before(:each) { run_llmk "-v" }

    it "should work normally" do
      expect(stderr).to include(info_line_seq "default.tex")
      expect(stderr).to include(info_line_runcmd "lualatex", "default.tex")

      expect(file?("default.pdf")).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end
end
