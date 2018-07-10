require 'aruba/rspec'
require 'pathname'

module Helplers
  # constants
  PWD = Pathname.pwd
  PATH = ENV["PATH"]

  # running the target llmk
  def run_llmk(*args)
    if args.size > 0
      run "llmk #{args.join(' ')}"
    else
      run "llmk"
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
