#!/usr/bin/env texlua

--
-- llmk.lua
--

-- program information
prog_name = 'llmk'
version = '0.0.0'
author = 'Takuto ASAKURA (wtsnjp)'

-- option flags (default)
debug = {
  ['version'] = false,
  ['config'] = false,
}
verbosity_level = 0

-- config table (default)
config = {
  ['latex'] = 'lualatex',
  ['max_repeat'] = 3,
}

----------------------------------------

-- library
require 'lfs'

-- global functions
function err_print(err_type, msg)
  if (verbosity_level > 0) or (err_type == 'error') then
    io.stderr:write(prog_name .. ' ' .. err_type .. ': ' .. msg .. '\n')
  end
end

function dbg_print(dbg_type, msg)
  if debug[dbg_type] then
    io.stderr:write(prog_name .. ' debug-' .. dbg_type .. ': ' .. msg .. '\n')
  end
end

-- short function names
cd     = lfs.chdir
pwd    = lfs.currentdir
mv     = os.rename
rm     = os.remove
mkdir  = lfs.mkdir
rmdir  = lfs.rmdir
random = math.random

----------------------------------------

do
  local function run_latex(fn)
    local tex_cmd = config['latex'] .. ' ' .. fn
    err_print('info', 'TeX command: "' .. tex_cmd .. '"')
    os.execute(tex_cmd)
  end

  function make(fns)
    fn = fns[1]
    run_latex(fn)
  end
end

----------------------------------------

do
  -- exit codes
  local exit_ok = 0
  local exit_error = 1
  local exit_usage = 2

  -- help texts
  local usage_text = [[
Usage: llmk[.lua] [OPTION...] [FILE...]

Options:
  -h, --help            Print this help message.
  -V, --version         Print the version number.

Please report bugs to <tkt.asakura@gmail.com>.
]]

  local version_text = [[
%s %s

Copyright 2018 %s.
License: The MIT License <https://opensource.org/licenses/mit-license.php>.
This is free software: you are free to change and redistribute it.
]]

  local error_msg = "ERROR"

  -- show uasage / help
  local function show_usage(out, text)
    out:write(usage_text:format(text))
  end

  -- execution functions
  local function read_options()
    if #arg == 0 then
      show_usage(io.stderr, '')
      os.exit(exit_usage)
    end

    local curr_arg
    local action = false

    -- modified Alternative Get Opt
    -- cf. http://lua-users.org/wiki/AlternativeGetOpt
    local function getopt(arg, options)
      local tmp
      local tab = {}
      local saved_arg = { table.unpack(arg) }
      for k, v in ipairs(saved_arg) do
        if string.sub(v, 1, 2) == "--" then
          table.remove(arg, 1)
          local x = string.find(v, "=", 1, true)
          if x then tab[string.sub(v, 3, x-1)] = string.sub(v, x+1)
          else   tab[string.sub(v, 3)] = true
          end
        elseif string.sub(v, 1, 1) == "-" then
          table.remove(arg, 1)
          local y = 2
          local l = string.len(v)
          local jopt
          while (y <= l) do
            jopt = string.sub(v, y, y)
            if string.find(options, jopt, 1, true) then
              if y < l then
                tmp = string.sub(v, y+1)
                y = l
              else
                table.remove(arg, 1)
                tmp = saved_arg[k + 1]
              end
              if string.match(tmp, '^%-') then
                tab[jopt] = false
              else
                tab[jopt] = tmp
              end
            else
              tab[jopt] = true
            end
            y = y + 1
          end
        end
      end
      return tab
    end

    opts = getopt(arg, 'd')
    for k, v in pairs(opts) do
      if #k == 1 then
        curr_arg = '-' .. k
      else
        curr_arg = '--' .. k
      end

      -- action
      if (curr_arg == '-h') or (curr_arg == '--help') then
        action = 'help'
      elseif (curr_arg == '-V') or (curr_arg == '--version') then
        action = 'version'
      else
        err_print('error', 'unknown option: ' .. curr_arg)
        err_print('error', error_msg)
        os.exit(exit_error)
      end
    end

    return action
  end

  local function do_action()
    if action == 'help' then
      show_usage(io.stdout, action_text)
    elseif action == 'version' then
      io.stdout:write(version_text:format(prog_name, version, author))
    end
  end

  function main()
    action = read_options()

    if action then
      do_action()
      os.exit(exit_ok)
    end

    make(arg)
    os.exit(exit_ok)
  end
end

----------------------------------------

main()

-- EOF
