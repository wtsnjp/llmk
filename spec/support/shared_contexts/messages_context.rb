shared_context "messages" do
  # the aliases to access outputs
  let(:stdout) { last_command_started.stdout.gsub("\r", "") }
  let(:stderr) { last_command_started.stderr.gsub("\r", "") }

  # functions for output line genaration
  def error_line msg
    return "llmk error: #{msg}"
  end

  def warning_line msg
    return "llmk warning: #{msg}"
  end

  def info_line msg
    return "llmk info: #{msg}"
  end

  def debug_line cat, msg=""
    if msg.empty?
      return "llmk debug-#{cat}:"
    else
      return "llmk debug-#{cat}: #{msg}"
    end
  end
end
