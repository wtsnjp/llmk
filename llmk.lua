#!/usr/bin/env texlua

-- The Light LaTeX Make tool
-- This is the file `llmk.lua'.
--
-- Copyright 2018 Takuto ASAKURA (wtsnjp)
--   GitHub:   https://github.com/wtsnjp
--   Twitter:  @wtsnjp
--
-- This sofware is distributed under the MIT License.
-- for more information, please refer to LICENSE file

local llmk_info = { -- program information
  _VERSION     = 'llmk v0.1',
  _NAME        = 'llmk',
  _AUTHOR      = 'Takuto ASAKURA (wtsnjp)',
  _DESCRIPTION = 'The Light LaTeX Make tool',
  _URL         = 'https://github.com/wtsnjp/llmk',
  _LICENSE     = 'MIT LICENSE (https://opensource.org/licenses/mit-license)',
}

-- library references
local lfs = require 'lfs' -- Lua File System
local md5 = require 'md5' -- MD5 facility

----------------------------------------

-- module 'getopt' : read options from the command line
local GetOpt = {}

-- modified Alternative Get Opt
-- cf. http://lua-users.org/wiki/AlternativeGetOpt
function GetOpt.from_arg(arg, options)
  local tmp
  local tab = {}
  local saved_arg = {table.unpack(arg)}
  for k, v in ipairs(saved_arg) do
    if string.sub(v, 1, 2) == '--' then
      table.remove(arg, 1)
      local x = string.find(v, '=', 1, true)
        if x then
          table.insert(tab, {string.sub(v, 3, x-1), string.sub(v, x+1)})
        else
          table.insert(tab, {string.sub(v, 3), true})
        end
    elseif string.sub(v, 1, 1) == '-' then
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
            table.insert(tab, {jopt, false})
          else
            table.insert(tab, {jopt, tmp})
          end
        else
          table.insert(tab, {jopt, true})
        end
        y = y + 1
      end
    end
  end
  return tab
end

----------------------------------------

-- module 'debug' : print useful information for debugging purpose
local Debug = {
  level = {
    config = false,
    parser = false,
    run = false,
    fdb = false,
    programs = false,
  }
}

function Debug:print(dbg_type, msg)
  local dbg_source = self.level[dbg_type]
  if dbg_source then
    io.stderr:write(llmk_info._NAME .. ' debug-' .. dbg_type .. ': ' .. msg .. '\n')
  end
end

function Debug:print_table(dbg_type, tab)
  local dbg_source = self.level[dbg_type]
  if not dbg_source then return end

  local indent = 2

  local function helper(t, ind)
    for k, v in pairs(t) do
      if type(v) == 'table' then
        self:print(dbg_type, string.rep(' ', ind) .. k .. ':')
        helper(v, ind + indent)
      elseif type(v) == 'string' then
        self:print(dbg_type, string.rep(' ', ind) .. k .. ': "' .. (v) .. '"')
      else -- number,  boolean, etc.
        self:print(dbg_type, string.rep(' ', ind) .. k .. ': ' .. tostring(v))
      end
    end
  end

  helper(tab, indent)
end

local Exit = { -- exit codes
  ok = 0,
  error = 1,
  parser = 2,
  failure = 3,
}
local verbosity_level = 1

local function err_print(err_type, msg)
  if (verbosity_level > 1) or (err_type == 'error') then
    io.stderr:write(llmk_info._NAME .. ' ' .. err_type .. ': ' .. msg .. '\n')
  end
end
----------------------------------------

-- module 'toml' : TOML text parsing
local TOML = {}

-- basic private constants
local _ws = '[\009\032]' -- blanck category
local _nl = '[\10\13\10]' -- new line category

-- private functions

-- read a character once at a time
local function _char(cursor, str, n) --> string
  cursor = cursor + (n or 0)
  return str:sub(cursor, cursor)
end

local function _skip_ws(cursor, str) --> cursor
  while _char(cursor, str):match(_ws) do
    cursor = cursor + 1
  end
  return cursor
end

local function _trim(str)
  return str:gsub('^%s*(.-)%s*$', '%1')
end

local function _bounds(cursor, str)
  return cursor <= str:len()
end

-- parsing functions for each TOML type

-- String parsing:
-- return <cursor>, <string>, <err=nil> or
-- if an error occur return nil, nil, <err description>
-- TODO: support multiline string parsing
-- TODO: process escape characters
local function _parse_string(cursor, str) --> cursor, string, err
  local del = _char(cursor, str) -- ' or "
  if not (del ~= "'" or del ~= '"') then
    return nil, nil, 'Unexpected beginning string delimeter "' .. del .. '"'
  end

  cursor = cursor + 1
  local s_start = cursor
  while _bounds(cursor, str) do
    local c = _char(cursor, str)
    if c == del then -- reached the end of string
      return cursor + 1, str:sub(s_start, cursor - 1)
    elseif c:match(_nl) then
      return nil, nil, 'Single-line string cannot contains line break'
    end
    cursor = cursor + 1
  end

  return nil, nil, 'Unclosing string definition'
end

-- Boolean parsing:
-- return <cursor>, <bool>, <err=nil> or
-- if an error occur return nil, nil, <err description>
local function _parse_boolean(cursor, str) --> cursor, boolean, err
  if str:sub(cursor, cursor + 3) == 'true' then
    return cursor + 4, true
  elseif str:sub(cursor, cursor + 4) == 'false' then
    return cursor + 5, false
  else
    return nil, nil, 'Invalid boolean literal value'
  end
end

-- Number parsing:
-- return <cursor>, <num>, <err=nil> or
-- if an error occur return nil, nil, <err description>
-- TODO: exp, date
local function _parse_number(cursor, str) --> cursor, number, err
  local c_start, c_end = cursor, cursor

  while _bounds(cursor, str) do
    local c = _char(cursor, str)
    if c:match('[%+%-%.eE_0-9]') then
      if c ~= '_' then
        c_end = c_end + 1
      end
    elseif c:match(_ws) or c == '#' or c:match(_nl) then
      break
    else
      return nil, nil, 'Invalid number'
    end
    cursor = cursor + 1
  end

  local n1 = str:sub(c_start, c_end)
  local n2 = n1:gsub("_", "")
  return cursor, tonumber(n2)
end

local _parse_array, _get_value

function _parse_array(cursor, str) --> cursor, array, err
  cursor = cursor + 1
  cursor = _skip_ws(cursor, str)

  local a_type
  local array = {}

  while _bounds(cursor, str) do
    local c = _char(cursor, str)
    if c == ']' then
      break
    elseif c:match(_nl) then
      cursor = cursor + 1
      cursor = _skip_ws(cursor, str)
    elseif c == '#' then
      while _bounds(cursor, str) and not c:match(_nl) do
        cursor = cursor + 1
      end
    else
      local v, err
      cursor, v, err = _get_value(cursor, str)
      if err then
        return nil, nil, err
      end

      if a_type == nil then
        a_type = type(v)
      elseif a_type ~= type(v) then
        return nil, 'Mixed types in array'
      end

      array = array or {}
      table.insert(array, v)

      if _char(cursor, str) == ',' then
        cursor = cursor + 1
      end
      cursor = _skip_ws(cursor, str)
    end
  end
  cursor = cursor + 1

  return cursor, array
end

-- judge the type and get the value
function _get_value(cursor, str)
  local c = _char(cursor, str)
  if (c == '"' or c == "'") then
    return _parse_string(cursor, str)
  elseif c:match('[%+%-0-9]') then
    return _parse_number(cursor, str)
  elseif c == '[' then
    return _parse_array(cursor, str)
  -- TODO: array of table, inline table
  else
    return _parse_boolean(cursor, str)
  end
end

local function _process_key(is_last, buffer, obj, table_array)
  is_last = is_last or false
  buffer = _trim(buffer)

  if buffer == '' then
    return nil, 'Empty table name'
  end

  if is_last and obj[buffer] and not table_array and #obj[buffer] > 0 then
    return nil, 'Cannot redefine label'
  end

  if table_array then
    if obj[buffer] then
      obj = obj[buffer]
      if is_last then
        table.insert(obj, {})
      end
      obj = obj[#obj]
    else
      obj[buffer] = {}
      obj = obj[buffer]
      if is_last then
        table.insert(obj, {})
        obj = obj[1]
      end
    end
  else
    obj[buffer] = obj[buffer] or {}
    obj = obj[buffer]
  end
end

-- public functions

function TOML.parse_toml(toml) --> res, err
  local buffer = ''
  local cursor = 1

  local res = {}
  local obj = res

  -- main loop of parser
  while _bounds(cursor, toml) do
    -- ignore comments and whitespace
    if _char(cursor, toml) == '#' then
      while(not _char(cursor, toml):match(_nl)) do
        cursor = cursor + 1
      end
    end

    if _char(cursor, toml):match(_nl) then
      -- do nothing; skip
    end

    if _char(cursor, toml) == '=' then
      cursor = cursor + 1
      cursor = _skip_ws(cursor, toml)

      -- prepare the key
      local key = _trim(buffer)
      buffer = ''

      if key == '' then
        return nil, 'Empty key name'
      end

      local value, err
      cursor, value, err = _get_value(cursor, toml)
      if err then
        err_print('error', 'parser: '.. err)
        os.exit(Exit.parser)
      end
      if value then
        -- duplicate keys are not allowed
        if obj[key] then
          return nil, 'Cannot redefine key "' .. key .. '"'
        end
        obj[key] = value
        --Debug:print('parser', 'Entry "' .. key .. ' = ' .. value .. '"')
      end

      -- skip whitespace and comments
      cursor = _skip_ws(cursor, toml)
      if _char(cursor, toml) == '#' then
        while _bounds(cursor, toml) and not _char(cursor, toml):match(_nl) do
          cursor = cursor + 1
        end
      end

      -- if garbage remains on this line, raise an error
      if not _char(cursor, toml):match(_nl) and _bounds(cursor, toml) then
        return nil, 'Invalid primitive'
      end

    elseif _char(cursor, toml) == '[' then
      buffer = ''
      cursor = cursor + 1
      local table_array = false

      if _char(cursor, toml) == '[' then
        table_array = true
        cursor = cursor + 1
      end

      obj = res

      while _bounds(cursor, toml) do
        if _char(cursor, toml) == ']' then
          if table_array then
            if _char(cursor, toml, 1) ~= ']' then
              return nil, 'Mismatching brackets'
            else
              cursor = cursor + 1
            end
          end
          cursor = cursor + 1

          _process_key(true, buffer, obj, table_array)
          buffer = ''
          break
        --elseif char() == '"' or char() == "'" then
          -- TODO: quoted keys
        elseif _char(cursor, toml) == '.' then
          cursor = cursor + 1
          _process_key(nil, buffer, obj, table_array)
          buffer = ''
        else
          buffer = buffer .. _char(cursor, toml)
          cursor = cursor + 1
        end
      end

      buffer = ''
    --elseif (char() == '"' or char() == "'") then
      -- TODO: quoted keys
    end

    -- put the char to the buffer and proceed
    buffer = buffer .. (_char(cursor, toml):match(_nl) and '' or _char(cursor, toml))
    cursor = cursor + 1
  end

  return res
end


function TOML.get_toml(fn) --> toml
  local toml = ''
  local toml_field = false
  local toml_source = fn

  local f = io.open(toml_source)

  Debug:print('config', 'Fetching TOML from the file "' .. toml_source .. '".')

  local first_line = true
  local shebang

  for l in f:lines() do
    -- 1. llmk-style TOML field
    if string.match(l, '^%s*%%%s*%+%+%++%s*$') then
      -- NOTE: only topmost field is valid
      if not toml_field then toml_field = true
      else break end
    else
      if toml_field then
        toml = toml .. string.match(l, '^%s*%%%s*(.*)%s*$') .. '\n'
      end
    end

    -- 2. shebang
    if first_line then
      first_line = false
      shebang = string.match(l, '^%s*%%#!%s*(.*)%s*$')
    end
  end

  f:close()

  -- shebang to TOML
  if toml == '' and shebang then
    toml = 'latex = "' .. shebang .. '"\n'
  end

  return toml
end

---------------------------------------

local llmk_toml = 'llmk.toml'
local start_time = os.time()

----------------------------------------

local function init_config()
  local config = { -- basic config table
    latex = 'lualatex',
    bibtex = 'bibtex',
    makeindex = 'makeindex',
    dvipdf = 'dvipdfmx',
    dvips = 'dvips',
    ps2pdf = 'ps2pdf',
    sequence = {'latex', 'bibtex', 'makeindex', 'dvipdf'},
    max_repeat = 3,
  }

  config.programs = { -- program presets
    latex = {
      opts = {
        '-interaction=nonstopmode',
        '-file-line-error',
        '-synctex=1',
      },
      auxiliary = '%B.aux',
    },
    bibtex = {
      target = '%B.bib',
      args = '%B', -- "%B.bib" will result in an error
      postprocess = 'latex',
    },
    makeindex = {
      target = '%B.idx',
      force = false,
      postprocess = 'latex',
    },
    dvipdf = {
      target = '%B.dvi',
      force = false,
    },
    dvips = {
      target = '%B.dvi',
    },
    ps2pdf = {
      target = '%B.ps',
    },
  }
  return config
end

----------------------------------------

-- copy command name from top level
local function fetch_from_top_level(config, name)
  if config.programs[name] then
    if not config.programs[name].command and config[name] then
      config.programs[name].command = config[name]
    end
  end
end

local function update_config(tab, config)
  -- merge the table from TOML
  local function merge_table(tab1, tab2)
    for k, v in pairs(tab2) do
      if type(tab1[k]) == 'table' then
        tab1[k] = merge_table(tab1[k], v)
      else
        tab1[k] = v
      end
    end
  end
  merge_table(config, tab)

  -- set essential program names from top-level
  local prg_names = {'latex', 'bibtex', 'makeindex', 'dvipdf', 'dvips', 'ps2pdf'}
  for _, name in pairs(prg_names) do
    fetch_from_top_level(config, name)
  end

  -- show config table (for debug)
  Debug:print('config', 'The final config table is as follows:')
  Debug:print_table('config', config)
end

local function fetch_config_from_latex_source(fn, config)
  local toml = TOML.get_toml(fn)
  if toml == '' then
    err_print('warning',
      'Neither TOML field nor shebang is found in "' .. fn ..
      '"; using default config.')
  end

  local param, err = TOML.parse_toml(toml)
  if err then
    err_print('error', 'parser: ' .. err)
    os.exit(Exit.parser)
  end
  update_config(param, config)
end

local function fetch_config_from_llmk_toml(config)
  local f = io.open(llmk_toml)
  if f ~= nil then
    local toml = f:read('*all')
    local param, err = TOML.parse_toml(toml)
    if err then
      err_print('error', 'parser: ' .. err)
      os.exit(Exit.parser)
    end

    update_config(param, config)
    f:close()
  else
    err_print('error', 'No target specified and no ' .. llmk_toml .. ' found.')
    os.exit(Exit.error)
  end
end

----------------------------------------

local function table_copy(org)
  local org_type = type(org)
  local copy
  if org_type == 'table' then
    copy = {}
    for org_key, org_value in next, org, nil do
      copy[table_copy(org_key)] = table_copy(org_value)
    end
    setmetatable(copy, table_copy(getmetatable(org)))
  else -- number, string, boolean, etc.
      copy = org
  end
  return copy
end

local function replace_specifiers(str, source, target)
  local tmp = '/' .. source
  local basename = tmp:match('^.*/(.*)%..*$')

  str = str:gsub('%%S', source)
  str = str:gsub('%%T', target)

  if basename then
    str = str:gsub('%%B', basename)
  else
    str = str:gsub('%%B', source)
  end

  return str
end

local function setup_programs(fn, config)
  --[[Setup the programs table for each sequence.

  Collecting tables of only related programs, which appears in the
  `config.sequence` or `prog.postprocess`, and replace all specifiers.

  Args:
    fn (str): the input FILE name

  Returns:
    table of program tables
  ]]
  local prog_names = {}
  local new_programs = {}

  -- collect related programs
  local function add_prog_name(name)
    -- is the program known?
    if not config.programs[name] then
      err_print('error', 'Unknown program "' .. name .. '" is in the sequence.')
      os.exit(Exit.error)
    end

    -- if not new, no addition
    for _, c in pairs(prog_names) do
      if c == name then
        return
      end
    end

    -- if new, add it!
    prog_names[#prog_names + 1] = name
  end

  for _, name in pairs(config.sequence) do
    -- add the program name
    add_prog_name(name)

    -- add postprocess program if any
    local postprocess = config.programs[name].postprocess
    if postprocess then
      add_prog_name(postprocess)
    end
  end

  -- setup the programs
  for _, name in ipairs(prog_names) do
    local prog = table_copy(config.programs[name])

    -- setup the `prog.target`
    local cur_target

    if not prog.target then
      -- the default value of `prog.target` is `fn`
      cur_target = fn
    else
      -- here, %T should be replaced by `fn`
      cur_target = replace_specifiers(prog.target, fn, fn)
    end

    prog.target = cur_target

    -- setup the `prog.opts`
    if prog.opts then -- `prog.opts` is optional
      -- normalize to a table
      if type(prog.opts) ~= 'table' then
        prog.opts = {prog.opts}
      end

      -- replace specifiers as usual
      for idx, opt in ipairs(prog.opts) do
        prog.opts[idx] = replace_specifiers(opt, fn, cur_target)
      end
    end

    -- setup the `prog.args`
    if not prog.args then
      -- the default value of `prog.args` is [`cur_target`]
      prog.args = {cur_target}
    else
      -- normalize to a table
      if type(prog.args) ~= 'table' then
        prog.args = {prog.args}
      end

      -- replace specifiers as usual
      for idx, arg in ipairs(prog.args) do
        prog.args[idx] = replace_specifiers(arg, fn, cur_target)
      end
    end

    -- setup the `prog.auxiliary`
    if prog.auxiliary then -- `prog.auxiliary` is optional
      -- replace specifiers as usual
      prog.auxiliary = replace_specifiers(prog.auxiliary, fn, cur_target)
    end

    -- setup the `prog.force`
    if prog.force == nil then
      -- the default value of `prog.force` is true
      prog.force = true
    end

    -- register the program
    new_programs[name] = prog
  end

  return new_programs
end

local function file_mtime(path)
  return lfs.attributes(path, 'modification')
end

local function file_size(path)
  return lfs.attributes(path, 'size')
end

local function file_md5sum(path)
  local f = assert(io.open(path, 'rb'))
  local content = f:read('*a')
  f:close()
  return md5.sumhexa(content)
end

local function file_status(path)
  return {
    mtime = file_mtime(path),
    size = file_size(path),
    md5sum = file_md5sum(path),
  }
end

local function init_file_database(programs, config, fn)
  -- the template
  local fdb = {
    targets = {},
    auxiliary = {},
  }

  -- investigate current status
  for _, v in ipairs(config.sequence) do
    -- names
    local cur_target = programs[v].target
    local cur_aux = programs[v].auxiliary

    -- target
    if lfs.isfile(cur_target) and not fdb.targets[cur_target] then
      fdb.targets[cur_target] = file_status(cur_target)
    end

    -- auxiliary
    if cur_aux then -- `prog.auxiliary` is optional
      if lfs.isfile(cur_aux) and not fdb.auxiliary[cur_aux] then
        fdb.auxiliary[cur_aux] = file_status(cur_aux)
      end
    end
  end

  return fdb
end

local function construct_cmd(prog, fn, target)
  -- construct the option
  local cmd_opt = ''

  if prog.opts then
    -- construct each option
    for _, opt in ipairs(prog.opts) do
      if #opt > 0 then
        cmd_opt = cmd_opt .. ' ' .. opt
      end
    end
  end

  -- construct the argument
  local cmd_arg = ''

  -- construct each argument
  for _, arg in ipairs(prog.args) do
    cmd_arg = cmd_arg .. ' "' .. arg .. '"'
  end

  -- whole command
  return prog.command .. cmd_opt .. cmd_arg
end

local function check_rerun(prog, fdb)
  Debug:print('run', 'Checking the neccessity of rerun.')

  local aux = prog.auxiliary
  local old_aux_exist = false
  local old_status

  -- if aux file does not exist, no chance of rerun
  if not aux then
    Debug:print('run', 'No auxiliary file specified.')
    return false, fdb
  end

  -- if aux file does not exist, no chance of rerun
  if not lfs.isfile(aux) then
    Debug:print('run', 'The auxiliary file "' .. aux .. '" does not exist.')
    return false, fdb
  end

  -- copy old information and update fdb
  if fdb.auxiliary[aux] then
    old_aux_exist = true
    old_status = table_copy(fdb.auxiliary[aux])
  end
  local aux_status = file_status(aux)
  fdb.auxiliary[aux] = aux_status

  -- if aux file is not new, no rerun
  local new = aux_status.mtime >= start_time
  if not new and old_aux_exist then
    new = aux_status.mtime > old_status.mtime
  end

  if not new then
    Debug:print('run', 'No rerun because the aux file is not new.')
    return false, fdb
  end

  -- if aux file is empty (or almost), no rerun
  if aux_status.size < 9 then -- aux file contains "\\relax \n" by default
    Debug:print('run', 'No rerun because the aux file is (almost) empty.')
    return false, fdb
  end

  -- if new aux is not different from older one, no rerun
  if old_aux_exist then
    if aux_status.md5sum == old_status.md5sum then
      Debug:print('run', 'No rerun because the aux file has not been changed.')
      return false, fdb
    end
  end

  -- ok, then try rerun
  Debug:print('run', 'Try to rerun!')
  return true, fdb
end

local function run_program(prog, fn, fdb)
  -- does command specified?
  if #prog.command < 1 then
    Debug:print('run',
      'Skipping "' .. prog.command .. '" because command does not exist.')
    return false
  end

  -- does target exist?
  if not lfs.isfile(prog.target) then
    Debug:print('run',
      'Skipping "' .. prog.command .. '" because target (' ..
      prog.target .. ') does not exist.')
    return false
  end

  -- is the target modified?
  if not prog.force and file_mtime(prog.target) < start_time then
    Debug:print('run',
      'Skipping "' .. prog.command .. '" because target (' ..
      prog.target .. ') is not updated.')
    return false
  end

  local cmd = construct_cmd(prog, fn, prog.target)
  err_print('info', 'Running command: ' .. cmd)
  local status = os.execute(cmd)

  if status > 0 then
    err_print('error',
      'Fail running '.. cmd .. ' (exit code: ' .. status .. ')')
    os.exit(Exit.failure)
  end

  return true
end

local function process_program(programs, name, fn, fdb, config)
  local prog = programs[name]
  local should_rerun

  -- check prog.command
  -- TODO: move this to pre-checking process
  if type(prog.command) ~= 'string' then
    err_print('error', 'Command name for "' .. name .. '" is not detected.')
    os.exit(Exit.error)
  end

  -- TODO: move this to pre-checking process
  if type(prog.target) ~= 'string' then
    err_print('error', 'Target for "' .. name .. '" is not valid.')
    os.exit(Exit.error)
  end

  -- execute the command
  local run = false
  local exe_count = 0
  while true do
    exe_count = exe_count + 1
    run = run_program(prog, fn, fdb)

    -- if the run is skipped, break immediately
    if not run then break end

    -- if not neccesarry to rerun or reached to max_repeat, break the loop
    should_rerun, fdb = check_rerun(prog, fdb)
    if not ((exe_count < config.max_repeat) and should_rerun) then
      break
    end
  end

  -- go to the postprocess process
  if prog.postprocess and run then
    Debug:print('run', 'Going to postprocess "' .. prog.postprocess .. '".')
    process_program(programs, prog.postprocess, fn, fdb)
  end
end

local function run_sequence(fn, config)
  err_print('info', 'Beginning a sequence for "' .. fn .. '".')

  -- setup the programs table
  local programs = setup_programs(fn, config)
  Debug:print('programs', 'Current programs table:')
  Debug:print_table('programs', programs)

  -- create a file database
  local fdb = init_file_database(programs, config, fn)
  Debug:print('fdb', 'The initial file database is as follows:')
  Debug:print_table('fdb', fdb)

  for _, name in ipairs(config.sequence) do
    Debug:print('run', 'Preparing for program "' .. name .. '".')
    process_program(programs, name, fn, fdb, config)
  end
end

-- return the filename if exits, even if the ".tex" extension is omitted
-- otherwise return nil
local function check_filename(fn)
  if lfs.isfile(fn) then
    return fn -- ok
  end

  local ext = fn:match('%.(.-)$')
  if ext ~= nil then
    return nil
  end

  local new_fn = fn .. '.tex'
  if lfs.isfile(new_fn) then
    return new_fn
  else
    return nil
  end
end

local function make(fns)
  if #fns > 0 then
    for _, fn in ipairs(fns) do
      local config = init_config()
      local checked_fn = check_filename(fn)
      if checked_fn then
        fetch_config_from_latex_source(checked_fn, config)
        run_sequence(checked_fn, config)
      else
        err_print('error', 'No source file found for "' .. fn .. '".')
        os.exit(Exit.error)
      end
    end
  else
    local config = init_config()
    fetch_config_from_llmk_toml(config)
    if type(config.source) == 'string' then
      run_sequence(config.source, config)
    elseif type(config.source) == 'table' then
      for _, fn in ipairs(config.source) do
        run_sequence(fn, config)
      end
    else
      err_print('error', 'No source detected.')
      os.exit(Exit.error)
    end
  end
end

----------------------------------------

-- help texts
local help_text = [[
Usage: llmk[.lua] [OPTION...] [FILE...]

Options:
  -h, --help            Print this help message.
  -V, --version         Print the version number.

  -q, --quiet           Suppress warnings and most error messages.
  -v, --verbose         Print additional information.
  -D, --debug           Activate all debug output (equal to "--debug=all").
  -d CAT, --debug=CAT   Activate debug output restricted to CAT.

Please report bugs to <tkt.asakura@gmail.com>.
]]

-- execution functions
local function read_options()
  local curr_arg
  local action = false

  local opts = GetOpt.from_arg(arg, 'd')
  for _, tp in pairs(opts) do
    local k, v = tp[1], tp[2]
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
    -- debug
    elseif (curr_arg == '-D') or
      (curr_arg == '--debug' and (v == 'all' or v == true)) then
      local lev = Debug.level
      for c, _ in pairs(lev) do
        lev[c] = true
      end
    elseif (curr_arg == '-d') or (curr_arg == '--debug') then
      local lev = Debug.level
      if lev[v] == nil then
        err_print('warning', 'unknown debug category: ' .. v)
      else
        lev[v] = true
      end
    -- verbosity
    elseif (curr_arg == '-q') or (curr_arg == '--quiet') then
      verbosity_level = 0
    elseif (curr_arg == '-v') or (curr_arg == '--verbose') then
      verbosity_level = 2
    -- problem
    else
      err_print('error', 'unknown option: ' .. curr_arg)
      os.exit(Exit.error)
    end
  end

  return action
end

local function do_action(action)
  if action == 'help' then
    io.stdout:write(help_text)
  elseif action == 'version' then
    local info = string.format([[
This is %s
%s

Copyright 2018 %s.
License: %s.
This is free software: you are free to change and redistribute it.

]],
      llmk_info._VERSION,
      llmk_info._DESCRIPTION,
      llmk_info._AUTHOR,
      llmk_info._LICENSE
    )
    io.stdout:write(info)
  end
end

local function main()
  local action = read_options()

  if action then
    do_action(action)
    os.exit(Exit.ok)
  end

  make(arg)
  os.exit(Exit.ok)
end

----------------------------------------

main()

-- EOF
