# llmk(1) -- The Light LaTeX Make

## SYNOPSIS

`llmk` [OPTION]... [FILE]...

## DESCRIPTION

`llmk` is yet another LaTeX-specific build tool. Its aim is to provide a simple way to write down workflows for processing LaTeX documents. The only requirement is the `texlua`(1) program.

If one or more FILE(s) are specified, `llmk` reads the TOML fields or other supported magic comments in the files. Otherwise, it will read the special configuration file _llmk.toml_ in the working directory. Then, **llmk** will execute the specified workflow to typeset the LaTeX documents.

## OPTIONS

* `-h`, `--help`:
  Print this help message.
* `-V`, `--version`:
  Print the version number.

* `-s`, `--silent`:
  Silence messages from called programs.
* `-q`, `--quiet`:
  Suppress warnings and most error messages.
* `-v`, `--verbose`:
  Print additional information (e.g., viewer command).
* `-D`, `--debug`:
  Activate all debug output (equal to "--debug=all").
* `-d`CAT, `--debug`=CAT:
  Activate debug output restricted to CAT.

## EXIT STATUS

* 0:
  Success.
* 1:
  General error.
* 2:
  Parser error.
* 3:
  Failure executing the workflow. The exit status of the external program is reported in an error message.

## REPORTING BUGS

Report bugs to tkt.asakura@gmail.com.  
Source: https://github.com/wtsnjp/llmk

## COPYRIGHT

Copyright 2018-2020 Takuto ASAKURA (wtsnjp).  
License: The MIT License <https://opensource.org/licenses/mit-license>.  
This is free software: you are free to change and redistribute it.

## SEE ALSO

The full documentation is maintained as a PDF manual. The command

```
texdoc llmk
```

should give you access to the complete manual.
