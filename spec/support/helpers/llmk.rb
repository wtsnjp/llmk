require 'aruba/rspec'
require 'pathname'

module SpecHelplers
  module Llmk
    BASE_DIR = Pathname.pwd

    # running the target llmk
    def run_llmk *args, interactive: false
      if args.size > 0
        arg_str = " " + args.join(" ") 
      else
        arg_str = ""
      end

      run_command "texlua #{BASE_DIR}/llmk.lua #{arg_str}"

      stop_all_commands if !interactive
    end
  end
end

RSpec.configure do |config|
  config.include SpecHelplers::Llmk
end
