# Rakefile for llmk.
# Public domain.

require 'rake/clean'
require 'pathname'

# basics
LLMK_VERSION = "0.0.0"
PKG_NAME = "llmk-#{LLMK_VERSION}"

# woking/temporaly dirs
PWD = Pathname.pwd
TMP_DIR = PWD + "tmp"

# options for ronn
OPT_MAN = "--manual=\"llmk manual\""
OPT_ORG = "--organization=\"llmk #{LLMK_VERSION}\""

# cleaning
CLEAN.include(["doc/*", "tmp"])
CLEAN.exclude(["doc/*.md", "doc/*.tex", "doc/*.pdf"])
CLOBBER.include(["doc/*.pdf", "*.zip"])

#desc "Run tests (only listed specs, if specified)"
#task :test do |task, args|
#  # run rspec
#  args = args.to_a
#  if args.size > 0
#    f_list = args.map{|f| "spec/#{f}_spec.rb"}.join(" ")
#    sh "bundle exec rspec #{f_list}"
#  else
#    sh "bundle exec rspec"
#  end
#end

desc "Generate all documentation"
task :doc do
  cd "doc"
  sh "llmk -q llmk.tex > #{File::NULL} 2> #{File::NULL}"
  sh "bundle exec ronn -r #{OPT_MAN} #{OPT_ORG} llmk.1.md 2> #{File::NULL}"
end

desc "Preview the manpage"
task :man do
  cd "doc"
  sh "bundle exec ronn -m #{OPT_MAN} #{OPT_ORG} llmk.1.md"
end
