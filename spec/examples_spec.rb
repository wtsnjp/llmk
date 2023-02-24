require 'spec_helper'

RSpec.describe "Processing example", :type => :aruba do
  include_context "examples"
  include_context "messages"

  def info_line_seq file
    info_line "Beginning a sequence for \"#{file}\""
  end

  def info_line_runcmd cmd, file
    default_opts = "-interaction=nonstopmode -file-line-error -synctex=1 -output-directory=\".\""
    info_line "Running command: #{cmd} #{default_opts} \"#{file}\""
  end
  
  def info_line_runcmd_with_output_directory cmd, file, output_directory
    default_opts = "-interaction=nonstopmode -file-line-error -synctex=1 -output-directory=\"#{output_directory}\""
    info_line "Running command: #{cmd} #{default_opts} \"#{file}\""
  end

  context "llmk.toml" do
    before(:each) { use_example "llmk.toml", "simple.tex", "default.tex" }
    before(:each) { run_llmk "-v" }
    before(:each) { stop_all_commands }

    it "should produce simple.pdf and default.pdf" do
      expect(stderr).to include(info_line_seq 'simple.tex')
      expect(stderr).to include(info_line_runcmd 'xelatex', 'simple.tex')

      expect(stderr).to include(info_line_seq 'default.tex')
      expect(stderr).to include(info_line_runcmd 'xelatex', 'default.tex')

      expect(stdout).to include('This is XeTeX')

      expect(file?('simple.pdf')).to be true
      expect(file?('default.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "default.tex" do
    before(:each) { use_example "default.tex" }
    before(:each) { run_llmk "-v", "default.tex" }
    before(:each) { stop_all_commands }

    it "should produce default.pdf" do
      expect(stderr).to include(info_line_seq 'default.tex')
      expect(stderr).to include(info_line_runcmd 'lualatex', 'default.tex')

      expect(file?('default.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "simple.tex" do
    before(:each) { use_example "simple.tex" }
    before(:each) { run_llmk "-v", "simple.tex" }
    before(:each) { stop_all_commands }

    it "should produce simple.pdf" do
      expect(stderr).to include(info_line_seq 'simple.tex')
      expect(stderr).to include(info_line_runcmd 'xelatex', 'simple.tex')

      expect(file?('simple.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "complex.tex" do
    before(:each) { use_example "complex.tex" }
    before(:each) { run_llmk "-v", "complex.tex" }
    before(:each) { stop_all_commands }

    it "should produce complex.pdf" do
      expect(stderr).to include(info_line_seq 'complex.tex')
      expect(stderr).to include(info_line_runcmd 'uplatex', 'complex.tex')
      expect(stderr).to include(info_line 'Running command: dvipdfmx "complex"')

      expect(stdout).to include('This is e-upTeX')
      expect(stderr).to include('complex.dvi -> complex.pdf')

      expect(file?('complex.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "platex.tex" do
    before(:each) { use_example "platex.tex" }
    before(:each) { run_llmk "-v", "platex.tex" }
    before(:each) { stop_all_commands }

    it "should produce platex.pdf" do
      expect(stderr).to include(info_line_seq 'platex.tex')
      expect(stderr).to include(info_line_runcmd 'platex', 'platex.tex')
      expect(stderr).to include(info_line 'Running command: dvipdfmx "platex.dvi"')

      expect(file?('platex.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "shebang.tex" do
    before(:each) { use_example "shebang.tex" }
    before(:each) { run_llmk "-v", "shebang.tex" }
    before(:each) { stop_all_commands }

    it "should produce shebang.pdf" do
      expect(stderr).to include(info_line_seq 'shebang.tex')
      expect(stderr).to include(info_line_runcmd 'pdflatex', 'shebang.tex')

      expect(file?('shebang.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "texshop.tex" do
    before(:each) { use_example "texshop.tex" }
    before(:each) { run_llmk "-v", "texshop.tex" }
    before(:each) { stop_all_commands }

    it "should produce texshop.pdf" do
      expect(stderr).to include(info_line_seq 'texshop.tex')
      expect(stderr).to include(info_line_runcmd 'xelatex', 'texshop.tex')

      expect(file?('texshop.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end

  context "texstudio.tex" do
    before(:each) { use_example "texstudio.tex" }
    before(:each) { run_llmk "-v", "texstudio.tex" }
    before(:each) { stop_all_commands }

    it "should produce texstudio.pdf" do
      expect(stderr).to include(info_line_seq 'texstudio.tex')
      expect(stderr).to include(info_line_runcmd 'xelatex', 'texstudio.tex')

      expect(file?('texstudio.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end
  
  context "outputdirectory.tex" do
    before(:each) { use_example "outputdirectory.tex" }
    before(:each) { run_llmk "-v", "outputdirectory.tex" }
    before(:each) { stop_all_commands }

    it "should produce outputdirectory.pdf" do
      Dir.mkdir 'output'
      
      expect(stderr).to include(info_line_seq 'outputdirectory.tex')
      expect(stderr).to include(info_line_runcmd_with_output_directory 'xelatex', 'outputdirectory.tex', 'output')

      expect(file?('outputdirectory.pdf')).to be false
      expect(file?('output/outputdirectory.pdf')).to be true

      expect(last_command_started).to be_successfully_executed
    end
  end
end
