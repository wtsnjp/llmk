require 'fileutils'
require 'pathname'

shared_context "examples" do
  def use_example *fns
    pwd = Pathname.pwd
    fns.each do |fn|
      FileUtils.cp pwd / "examples" / fn, pwd / "tmp/aruba"
    end
  end
end
