require 'spec_helper'

RSpec.describe "With --dry-run, processing example", :type => :aruba do
  include_context "examples"
  include_context "messages"

  def info_line_seq file
    info_line "Beginning a sequence for \"#{file}\""
  end

  def info_line_runcmd cmd, file
    default_opts = "-interaction=nonstopmode -file-line-error -synctex=1"
    info_line "Running command: #{cmd} #{default_opts} \"#{file}\""
  end

  context "llmk.toml" do
    before(:each) { use_example "llmk.toml", "simple.tex", "default.tex" }
    before(:each) { run_llmk "-nv" }
    before(:each) { stop_all_commands }

    it "should report the commands to produce simple.pdf and default.pdf" do
      expect(stdout).to eq <<~EXPECTED
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "simple.tex"
        Dry running: bibtex "simple"
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "simple.tex"
        Dry running: makeindex "simple.idx"
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "simple.tex"
        Dry running: makeglossaries "simple.glo"
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "simple.tex"
        Dry running: dvipdfmx "simple.dvi"
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "default.tex"
        Dry running: bibtex "default"
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "default.tex"
        Dry running: makeindex "default.idx"
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "default.tex"
        Dry running: makeglossaries "default.glo"
        Dry running: xelatex -interaction=nonstopmode -file-line-error -synctex=1 "default.tex"
        Dry running: dvipdfmx "default.dvi"
      EXPECTED

      expect(stderr).to eq <<~EXPECTED
        llmk info: Beginning a sequence for "simple.tex"
        llmk info: <-- possibly with rerunning; if the target file "simple.tex" exists
        llmk info: <-- if the target file "simple.bib" exists
        llmk info: <-- as postprocess; possibly with rerunning; if the target file "simple.tex" exists
        llmk info: <-- if the target file "simple.idx" has been generated
        llmk info: <-- as postprocess; possibly with rerunning; if the target file "simple.tex" exists
        llmk info: <-- if the target file "simple.glo" has been generated
        llmk info: <-- as postprocess; possibly with rerunning; if the target file "simple.tex" exists
        llmk info: <-- if the target file "simple.dvi" has been generated
        llmk info: Beginning a sequence for "default.tex"
        llmk info: <-- possibly with rerunning; if the target file "default.tex" exists
        llmk info: <-- if the target file "default.bib" exists
        llmk info: <-- as postprocess; possibly with rerunning; if the target file "default.tex" exists
        llmk info: <-- if the target file "default.idx" has been generated
        llmk info: <-- as postprocess; possibly with rerunning; if the target file "default.tex" exists
        llmk info: <-- if the target file "default.glo" has been generated
        llmk info: <-- as postprocess; possibly with rerunning; if the target file "default.tex" exists
        llmk info: <-- if the target file "default.dvi" has been generated
      EXPECTED

      # no actual run
      expect(stdout).not_to include('This is XeTeX')

      expect(file?('simple.pdf')).not_to be true
      expect(file?('default.pdf')).not_to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "complex.tex" do
    before(:each) { use_example "complex.tex" }
    before(:each) { run_llmk "-nv", "complex.tex" }
    before(:each) { stop_all_commands }

    it "should report the commands to produce complex.pdf" do
      expect(stdout).to eq <<~EXPECTED
        Dry running: uplatex -interaction=nonstopmode -file-line-error -synctex=1 "complex.tex"
        Dry running: uplatex -interaction=nonstopmode -file-line-error -synctex=1 "complex.tex"
        Dry running: uplatex -interaction=nonstopmode -file-line-error -synctex=1 "complex.tex"
        Dry running: dvipdfmx "complex"
      EXPECTED

      expect(stderr).to eq <<~EXPECTED
        llmk info: Beginning a sequence for "complex.tex"
        llmk info: <-- possibly with rerunning; if the target file "complex.tex" exists
        llmk info: <-- possibly with rerunning; if the target file "complex.tex" exists
        llmk info: <-- possibly with rerunning; if the target file "complex.tex" exists
        llmk info: <-- if the target file "complex.dvi" has been generated
      EXPECTED

      # no actual run
      expect(stdout).not_to include('This is e-upTeX')
      expect(stderr).not_to include('complex -> complex.pdf')

      expect(file?('complex.pdf')).not_to be true

      expect(last_command_started).to be_successfully_executed
    end
  end
end
