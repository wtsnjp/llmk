require 'aruba/rspec'
require 'pathname'

module SpecHelplers
  module Llmk
    # constants
    PWD = Pathname.pwd
    PATH = ENV["PATH"]

    # running the target llmk
    def run_llmk(*args)
      if args.size > 0
        run "texlua #{PWD}/llmk.lua #{args.join(' ')}"
      else
        run "texlua #{PWD}/llmk.lua"
      end
    end

    def set_default_env
      # clear all
      ENV.clear

      # basics
      ENV["PATH"] = PATH
    end

    # generate debug line
    def error_line(msg)
      return "llmk error: #{msg}"
    end

    def debug_line(cat, msg="")
      if msg.empty?
        return "llmk debug-#{cat}:"
      else
        return "llmk debug-#{cat}: #{msg}"
      end
    end
  end
end

RSpec.configure do |config|
  config.include SpecHelplers::Llmk
  config.before(:each) { set_default_env }
end
