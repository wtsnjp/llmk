require 'spec_helper'

RSpec.describe "With --silent, processing example", :type => :aruba do
  include_context "examples"
  include_context "messages"

  def info_line_seq file
    info_line "Beginning a sequence for \"#{file}\""
  end

  def info_line_runcmd cmd, file
    default_opts = "-interaction=nonstopmode -file-line-error -synctex=1 -output-directory=\".\""
    info_line "Running command: #{cmd} #{default_opts} \"#{file}\""
  end

  context "llmk.toml" do
    before(:each) { use_example "llmk.toml", "simple.tex", "default.tex" }
    before(:each) { run_llmk "-sv" }

    it "should produce simple.pdf and default.pdf" do
      expect(stderr).to include(info_line_seq 'simple.tex')
      expect(stderr).to include(info_line_runcmd 'xelatex', 'simple.tex')

      expect(stderr).to include(info_line_seq 'default.tex')
      expect(stderr).to include(info_line_runcmd 'xelatex', 'default.tex')

      # check the effect of the --silent option
      expect(stdout).not_to include('This is XeTeX')

      expect(file?('simple.pdf')).to be true
      expect(file?('default.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "complex.tex" do
    before(:each) { use_example "complex.tex" }
    before(:each) { run_llmk "-sv", "complex.tex" }

    it "should produce complex.pdf" do
      expect(stderr).to include(info_line_seq 'complex.tex')
      expect(stderr).to include(info_line_runcmd 'uplatex', 'complex.tex')
      expect(stderr).to include(info_line 'Running command: dvipdfmx "complex"')

      # check the effect of the --silent option
      expect(stdout).not_to include('This is e-upTeX')
      expect(stderr).not_to include('complex -> complex.pdf')

      expect(file?('complex.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end
end
