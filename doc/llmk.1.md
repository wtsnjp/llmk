# llmk(1) -- The Light LaTeX Make

## SYNOPSIS

`llmk` [OPTION]... [FILE]...

## DESCRIPTION

`llmk` is yet another LaTeX-specific build tool. Its aim is to provide a simple way to write down workflows for processing LaTeX documents. The only requirement is the `texlua`(1) program.

If one or more FILE(s) are specified, `llmk` reads the TOML fields or other supported magic comments in the files. Otherwise, it will read the special configuration file _llmk.toml_ in the working directory. Then, **llmk** will execute the specified workflow to typeset the LaTeX documents.

## OPTIONS

* `-c`, `--clean`:
  Remove the temporary files such as `*.aux` and `*.log`.
* `-C`, `--clobber`:
  Remove all generated files including final PDFs.
* `-d`CAT, `--debug`=CAT:
  Activate debug output restricted to CAT.
* `-D`, `--debug`:
  Activate all debug output (equal to "--debug=all").
* `-h`, `--help`:
  Print this help message.
* `-n`, `--dry-run`:
  Show what would have been executed.
* `-q`, `--quiet`:
  Suppress warnings and most error messages.
* `-s`, `--silent`:
  Silence messages from called programs.
* `-v`, `--verbose`:
  Print additional information (e.g., running commands).
* `-V`, `--version`:
  Print the version number.

## EXIT STATUS

* 0:
  Success.
* 1:
  General error.
* 2:
  Failure executing the workflow. The exit status of the external program is reported in an error message.
* 3:
  Parser error.
* 4:
  Type error.

## REPORTING BUGS

Report bugs to <https://github.com/wtsnjp/llmk/issues>.  
Source: <https://github.com/wtsnjp/llmk>

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
