require 'fileutils'
require 'pathname'

shared_context "examples" do
  # constants
  PWD = Pathname.pwd
  EXAMPLE_DIR = PWD + "examples"
  WORKING_DIR = PWD + "tmp/aruba"

  before(:each) { FileUtils.cp_r "#{EXAMPLE_DIR}/.", WORKING_DIR }
end
