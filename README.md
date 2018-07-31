# llmk: The Light LaTeX Make

[![Build Status](https://travis-ci.org/wtsnjp/llmk.svg?branch=master)](https://travis-ci.org/wtsnjp/llmk)
[![Build status](https://ci.appveyor.com/api/projects/status/1papc7m85kl9iph1?svg=true)](https://ci.appveyor.com/project/wtsnjp/llmk)

This is yet another build tool for LaTeX documents. The features of **llmk** are:

* it works solely with texlua,
* using TOML to declare the settings,
* no complicated nesting of configuration, and
* modern default settings (make LuaTeX de facto standard!)

## Basic Usage

The easiest way to use **llmk** is to write the build settings into the LaTeX document itself. The settings can be written as [TOML](https://github.com/toml-lang/toml) format in comments of a source file, and those have to be placed between the comment lines only with the consecutive `+` characters (at least three).

Here's a very simple example:

```latex
% hello.tex

% +++
% latex = "xelatex"
% +++

\documentclass{article}
\begin{document}

Hello \textsf{llmk}!

\end{document}
```

Suppose we save this file as `hello.tex`, then run

```
$ llmk hello.tex
```

will produce a PDF document (`hello.pdf`) with XeLaTeX, since it is specified in the TOML line of the source.

You can find other example LaTeX document files in the [examples](./examples) directory.

## Advanced Usage

### Using llmk.toml

Alternatively, you can write your build settings in an independent file named `llmk.toml` (this file name is fixed).

```toml
# llmk.toml

latex = "lualatex"
source = "hello.tex"
```

If you run llmk without any argument, llmk will load `llmk.toml` in the working directory, and compile files specified by `source` key with the settings written in the file.

```
$ llmk
```

### Custom compile sequence

You can setup custom sequence for processing LaTeX documents; use `sequence` key to specify the order of programs to process the documents and specify the detailed settings for each program.

For the simple use, you can specify the command name in the top-level just like `latex = "lualatex"`, which is already shown in the former examples (only available for `latex`, `dvipdf`, and `bibtex`).

However, it is impossible to specify more detailed settings (e.g., command line options) with this simple manner. If you want to change those settings as well, you have to use tables of TOML; write `[programs.<name>]` and then write the each setting following to that:

```toml
# custom sequence
sequence = ["latex", "bibtex", "latex", "dvipdf"]

# quick settings
dvipdf = "dvipdfmx"

# detailed settings for each program
[programs.latex]
  command = "uplatex"
  opt = "-halt-on-error"
  arg = "%T"

[programs.bibtex]
  command = "biber"
  arg = "%B"
```

In the `arg` keys in each program, some format specifiers are available. Those specifiers will be replaced to appropriate strings before executing the programs:

* `%T`: the file name given to llmk as an argument (target)
* `%B`: the base name of `%T`

This way is a bit complicated but strong enough allowing you to use any kind of outer programs.

### Available TOML keys

This is the list of currently available TOML keys.

* `latex` (type: *string*, default: `"lualatex"`)
* `dvipdf` (type: *string*, default: `""`)
* `bibtex` (type: *string*, default: `""`)
* `sequence` (type: *array of strings*, default: `["latex", "dvipdf"]`)
* `programs` (type: *table*)
	* \<program name\>
		* `command` (type: *string*)
		* `opt` (type: *string*)
		* `arg` (type: *string*)
* `source` (type: *string* or *array of strings*, only for `llmk.toml`)

### Default settings for each program

* `latex`
	* `command = "lualatex"`
	* `opt = "-file-line-error -synctex=1"`
	* `arg = "%T"`
* `dvipdf`
	* `command = ""`
	* `arg = "%B"`
* `bibtex`
	* `command = ""`
	* `arg = "%B"`

## License

This package released under [the MIT license](./LICENSE).

---

Takuto ASAKURA ([wtsnjp](https://twitter.com/wtsnjp))
