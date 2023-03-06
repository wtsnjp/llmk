require 'fileutils'
require 'pathname'

shared_context "examples" do
  let(:base_dir) { SpecHelplers::Llmk::BASE_DIR }

  def use_example *fns
    fns.each do |fn|
      FileUtils.cp base_dir / "examples" / fn, base_dir / "tmp/aruba"
    end
  end
end
