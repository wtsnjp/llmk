# Rakefile for llmk.
# Public domain.

require 'rake/clean'
require 'pathname'
require 'optparse'

# basics
LLMK_VERSION = "1.1.0"
CTAN_MIRROR = "http://ctan.mirror.rafal.ca/systems/texlive/tlnet"

# woking/temporaly dirs
PWD = Pathname.pwd
TMP_DIR = PWD + "tmp"

# options for ronn
OPT_MAN = "--manual=\"llmk manual\""
OPT_ORG = "--organization=\"llmk #{LLMK_VERSION}\""

# cleaning
CLEAN.include(["doc/*", "tmp"])
CLEAN.include([
  "**/*.log", "**/*.synctex.gz", "**/*.dvi",
  "**/*.ps", "**/*.pdf", "**/*.aux"
])
CLEAN.exclude(["doc/*.md", "doc/*.cls", "doc/*.tex", "doc/*.pdf"])
CLEAN.exclude(["doc/llmk-logo.png"])
CLOBBER.include(["doc/*.pdf", "*.zip"])

desc "Run tests [options available]"
task :test do |task, args|
  # parse options
  options = {}
  if ARGV.delete("--")
    OptionParser.new do |opts|
      opts.banner = "Usage: rake test [-- OPTION...]"
      opts.on("-o", "--opts=OPTS", "Pass OPTS to RSpec") do |args|
        options[:args] = args
      end
      opts.on("-l", "--list=LIST", "Load only specified specs in LIST") do |args|
        options[:list] = args
      end
    end.parse!(ARGV)
  end

  # construct options
  opt_args = if options[:args]
    " " + options[:args].strip
  else
    ""
  end
  opt_files = if options[:list]
    " " + options[:list].split(",").map{|i|"spec/#{i.strip}_spec.rb"}.join(" ")
  else
    ""
  end

  # run rspec
  sh "bundle exec rspec" + opt_args + opt_files

  # make sure to end this process
  exit 0
end

desc "Generate all documentation"
task :doc do
  cd "doc"
  sh "llmk -qs llmk.tex"
  sh "bundle exec ronn -r #{OPT_MAN} #{OPT_ORG} llmk.1.md 2> #{File::NULL}"
end

desc "Preview the manpage"
task :man do
  cd "doc"
  sh "bundle exec ronn -m #{OPT_MAN} #{OPT_ORG} llmk.1.md"
end

desc "Create an archive for CTAN"
task :ctan => :doc do
  # initialize the target
  CTAN_PKG_ID = "light-latex-make-#{LLMK_VERSION}"
  TARGET_DIR = TMP_DIR / CTAN_PKG_ID
  rm_rf TARGET_DIR
  mkdir_p TARGET_DIR

  # copy all required files
  cd PWD
  cp ["LICENSE", "README.md", "llmk.lua", "llmk-logo.png"], TARGET_DIR

  docs = ["llmk-doc.cls", "llmk-logo-code.tex", "llmk.tex", "llmk.pdf", "llmk.1"]
  docs.each do |name|
    cp "doc/#{name}", TARGET_DIR
  end

  # create zip archive
  cd TMP_DIR
  sh "zip -q -r #{CTAN_PKG_ID}.zip #{CTAN_PKG_ID}"
  mv "#{CTAN_PKG_ID}.zip", PWD
end

desc "Setup TeX Live on Unix-like pratforms"
task :setup_unix do
  # only for GitHub Actions
  fail "This task only works on GitHub Actions" if not ENV["GITHUB_ACTIONS"]

  # prepare the install dir
  INSTALL_DIR = TMP_DIR + Time.now.strftime("%F")
  mkdir_p INSTALL_DIR
  cd INSTALL_DIR

  # download install-tl
  sh "wget #{CTAN_MIRROR}/install-tl-unx.tar.gz"
  sh "tar zxvf install-tl-unx.tar.gz"
  cd Dir.glob("install-tl-20[0-9][0-9]*")[0]

  # config
  profile = <<~EOF
    selected_scheme scheme-small
    TEXDIR /tmp/texlive
    TEXMFCONFIG ~/.texlive/texmf-config
    TEXMFHOME ~/texmf
    TEXMFLOCAL /tmp/texlive/texmf-local
    TEXMFSYSCONFIG /tmp/texlive/texmf-config
    TEXMFSYSVAR /tmp/texlive/texmf-var
    TEXMFVAR ~/.texlive/texmf-var
    tlpdbopt_install_docfiles 0
    tlpdbopt_install_srcfiles 0
  EOF

  File.open("llmk.profile", "w") {|f| f.puts(profile)}

  # run install script
  sh "./install-tl -profile ./llmk.profile -repository #{CTAN_MIRROR}"
  sh "tlmgr init-usertree"
  sh "tlmgr -repository #{CTAN_MIRROR} install collection-langjapanese"

  # finish
  cd PWD
  rm_rf INSTALL_DIR
end

desc "Setup TeX Live on Windows"
task :setup_windows do
  # only for GitHub Actions
  fail "This task only works on GitHub Actions" if not ENV["GITHUB_ACTIONS"]

  # prepare the install dir
  INSTALL_DIR = TMP_DIR + Time.now.strftime("%F")
  mkdir_p INSTALL_DIR
  cd INSTALL_DIR

  # download install-tl
  sh "curl -O #{CTAN_MIRROR}/install-tl.zip"
  sh "unzip install-tl.zip"
  cd Dir.glob("install-tl-20[0-9][0-9]*")[0]

  # config
  profile = <<~EOF
    selected_scheme scheme-small
    TEXDIR D:/texlive
    TEXMFCONFIG ~/.texlive/texmf-config
    TEXMFHOME ~/texmf
    TEXMFLOCAL D:/texlive/texmf-local
    TEXMFSYSCONFIG D:/texlive/texmf-config
    TEXMFSYSVAR D:/texlive/texmf-var
    TEXMFVAR ~/.texlive/texmf-var
    binary_win32 1
    tlpdbopt_install_docfiles 0
    tlpdbopt_install_srcfiles 0
  EOF

  File.open("llmk.profile", "w") {|f| f.puts(profile)}

  # run install script
  opt_profile = "-profile ./llmk.profile"
  opt_repo = "-repository #{CTAN_MIRROR}"
  sh "echo y | install-tl-windows.bat #{opt_profile} #{opt_repo}"
  sh "tlmgr.bat init-usertree"
  sh "tlmgr.bat #{opt_repo} install collection-langjapanese"

  # finish
  cd PWD
  rm_rf INSTALL_DIR
end
