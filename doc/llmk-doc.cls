% Document class for llmk reference manual
% Copyright 2020 Takuto Asakura (wtsnjp)
% distributed under the MIT licence
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{llmk-doc}
  [2020/08/22 Document class for llmk reference manual]

% class options
\DeclareOption{draft}{\setlength\overfullrule{5pt}}
\ProcessOptions\relax

% remove "draft" from global options list
% (code from https://tex.stackexchange.com/questions/33245/)
\def\@clearglobaloption#1{%
  \def\@tempa{#1}%
  \def\@tempb{\@gobble}%
  \@for\next:=\@classoptionslist\do
    {\ifx\next\@tempa
       \message{Cleared option \next\space from global list}%
     \else
       \edef\@tempb{\@tempb,\next}%
     \fi}%
  \let\@classoptionslist\@tempb
  \expandafter\ifx\@tempb\@gobble
    \let\@classoptionslist\@empty
  \fi}
\@clearglobaloption{draft}

% basic dependency
\LoadClass[a4paper,oneside,fleqn,parskip=half-]{scrartcl}
\RequirePackage[fleqn]{amsmath}
\RequirePackage{graphicx}
\RequirePackage{booktabs}
\RequirePackage{bxtexlogo}
\RequirePackage[british]{babel}
\RequirePackage{needspace}
\RequirePackage{xunicode}
\RequirePackage{fancyvrb}
\RequirePackage{listings}
\RequirePackage{xparse}

% logo
\input{llmk-logo-code}
\RequirePackage[no-math]{fontspec}
\defaultfontfeatures{Ligatures=TeX}
\newcommand{\logomainfont}{\fontspec{Helvetica Neue}}
\newcommand{\logosubfont}{\fontspec{Helvetica Neue Thin}}

% font settings
\let\Zbar\relax
\RequirePackage[defaultsups]{newtxtext}
\RequirePackage[varqu,varl]{inconsolata}
\RequirePackage[bigdelims,vvarbb]{newtxmath}

% for headings
%\setkomafont{title}{}
%\setkomafont{subtitle}{\Huge\itshape}
\setkomafont{author}{}
\setkomafont{date}{}
\deffootnote[1.5em]{1.5em}{1em}{\textsuperscript{\thefootnotemark}\thinspace}

% headers
\RedeclareSectionCommand[
  runin=false,
  afterindent=false,
  beforeskip=\baselineskip,
  afterskip=.5\baselineskip]{section}
\RedeclareSectionCommand[
  runin=false,
  afterindent=false,
  beforeskip=\baselineskip,
  afterskip=.3\baselineskip]{subsection}

% colors
\RequirePackage{xcolor}
\definecolor{links}{named}{violet}
\definecolor{special}{rgb}{0,0.5,0}
\definecolor{code}{rgb}{0,0,0.6}

% tikz for the logo
\RequirePackage{tikz}
\usetikzlibrary{shapes, positioning}

% list environments
\RequirePackage{enumitem}
\newlength\lssep \setlength\lssep{\smallskipamount}
\setlist{noitemsep, topsep=\lssep, partopsep=\lssep}

% hyperref and bookmark
\RequirePackage[
  colorlinks=true, linkcolor=links, urlcolor=links, citecolor=links,
  bookmarks=true, bookmarksnumbered=true, bookmarksopen=true,
  bookmarksopenlevel=2]{hyperref}
\RequirePackage{bookmark}

% text styles
\DeclareUrlCommand\path{\urlstyle{tt}\color{links}}
\DeclareTextFontCommand{\emph}{\color{code}}

% for metadata
\AtBeginDocument{%
  \bgroup
  \def\and{, }%
  \hypersetup{%
    pdftitle={\@title},
    pdfauthor={\@author},
    pdfsubject={\@subtitle},
    pdfkeywords={\@keywords}}
  \egroup}
\RequirePackage[yyyymmdd]{datetime}
\renewcommand{\dateseparator}{-}

% title
\newcommand*{\keywords}[1]{\gdef\@keywords{#1}}
\renewcommand*{\@maketitle}{%
  \global\@topnum=\z@
  \setparsizes{\z@}{\z@}{\z@\@plus 1fil}\par@updaterelative
  \ifx\@titlehead\@empty \else
    \begin{minipage}[t]{\textwidth}
      \usekomafont{titlehead}{\@titlehead\par}%
    \end{minipage}\par
  \fi
  \null
  \vskip 2em%
  \begin{center}%
    \ifx\@subject\@empty \else
      {\usekomafont{subject}{\@subject \par}}%
      \vskip 1.5em
    \fi
    {\llmkLogo[1.2]}% put the logo
    \vskip 1em
    {\fontsize{1.2cm}{0pt}\selectfont\logomainfont llmk}
    \vskip .3em
    {\fontsize{0.5cm}{0pt}\selectfont\logosubfont Light {\LaTeX} Make}
    \vskip .5em
    %{\ifx\@subtitle\@empty\else\usekomafont{subtitle}\@subtitle\par\fi}%
    \vskip 1em
    {%
      \usekomafont{author}{%
        \lineskip .5em%
        \begin{tabular}[t]{c}
          \@author
        \end{tabular}\par
      }%
    }%
    \vskip .75em%
    {\usekomafont{date}{\@date \par}}%
    \vskip \z@ \@plus 1em
    {\usekomafont{publishers}{\@publishers \par}}%
    \ifx\@dedication\@empty \else
      \vskip 2em
      {\usekomafont{dedication}{\@dedication \par}}%
    \fi
  \end{center}%
  \par
  \vskip 2em
}

% some macros
\newcommand*{\prog}[1]{\textsf{#1}}
\newcommand*{\Dash}{\thinspace---\thinspace}
\newcommand*{\email}[1]{\href{mailto:#1}{\code{#1}}}
\newcommand*{\ie}{i.e.,\,}
\newcommand*{\eg}{e.g.,\,}
\newcommand*{\aka}{a.k.a.\,}
\newcommand*{\hyph}{-}
\newcommand*{\meta}[1]{\bgroup
  \normalfont\color{special}$\langle$\textit{#1}$\rangle$\egroup}
\DeclareRobustCommand{\code}[1]{%
  \texorpdfstring{\bgroup\chardef\_=`\_\code@font #1\egroup}{#1}}
\newcommand*{\cs}[1]{\texttt{\char`\\#1}}
\newcommand*{\sopt}[1]{\hyperlink{clo:#1}{\code{\hyph#1}}}
\newcommand*{\lopt}[1]{\hyperlink{clo:#1}{\code{\hyph{}\hyph#1}}}
\newcommand*{\ckey}[1]{\bgroup
  \def\_{-}\def\meta##1{##1}%
  \edef\x{\noexpand\def\noexpand\@tmp@hyname{ckey:#1}}%
  \expandafter\egroup\x
  \hyperlink{\@tmp@hyname}{\code{#1}}}
\newcommand*{\progname}[1]{\bgroup
  \def\_{-}\def\meta##1{##1}%
  \edef\x{\noexpand\def\noexpand\@tmp@hyname{prog:#1}}%
  \expandafter\egroup\x
  \hyperlink{\@tmp@hyname}{\code{#1}}}
\newcommand*{\type}[1]{\textcolor{special}{#1}}
\newcommand*{\README}{%
  \href{https://github.com/wtsnjp/llmk/blob/master/README.md}
  {\code{README.md}}}
\newcommand{\printLICENSE}{%
  \IfFileExists{./LICENSE}{\input{./LICENSE}}{% else
    \IfFileExists{../LICENSE}{\input{../LICENSE}}{% else
      \message{File LICENSE not found}}}}

% verbatim
\def\code@font{% code
  \color{code}\normalfont\ttfamily}
\fvset{%
  formatcom=\code@font,
  commandchars=\\\{\}}

% listings
\lstdefinelanguage{toml}{
  columns=fullflexible,
  morecomment=[l]{\#},
  commentstyle=\color{darkgray}\ttfamily,
  morekeywords={},
  otherkeywords={=}}
\lstdefinestyle{toml}{
  language={toml},
  numbers=left,
  numberstyle=\tiny,
  numbersep=5pt,
  breaklines=true,
  frame=l,
  xleftmargin=15pt,
  xrightmargin=15pt,
  basicstyle=\ttfamily\small,
  stepnumber=1,
  keywords={
    args,aux_file,aux_empty_size,command,generated_target,opts,
    postprocess,target,sequence
  },
  keywordstyle={\color{code}},
  alsoletter={=},
  keywords=[2]{=},
  keywordstyle=[2]{\color{black}},
  %keywords=[3]{true,false},
  %keywordstyle=[3]{\color{special}},
  %string=[b]",
  %stringstyle={\color{special}},
  comment=[l]\#,
  commentstyle=\color{darkgray}}
\lstdefinestyle{latex}{
  columns=fullflexible,
  language=[LaTeX]{TeX},
  numbers=left,
  numberstyle=\tiny,
  numbersep=5pt,
  breaklines=true,
  frame=l,
  xleftmargin=15pt,
  xrightmargin=15pt,
  basicstyle=\ttfamily\small,
  stepnumber=1,
  texcsstyle=*{\color{code}},
  commentstyle=\color{darkgray}}

% manual entries
\newenvironment{manual@entry}{\begin{list}{}{%
  \setlength{\leftmargin}{2em}%
  \setlength{\itemindent}{0pt}%
  \setlength{\itemsep}{0pt}%
  \setlength{\parsep}{0pt}%
  \setlength{\rightmargin}{0em}%
  }\item}{\end{list}}

\NewDocumentEnvironment{clopt}{ m o }
  {%
    \par\vskip.5\baselineskip
    \bgroup
    \def\sopt##1{\hypertarget{clo:##1}{\code{\hyph##1}}}%
    \def\lopt##1{\hypertarget{clo:##1}{\code{\hyph{}\hyph##1}}}%
    \needspace{3\baselineskip}\noindent #1\egroup
    \IfNoValueF{#2}{\hfill (#2)}%
    \begin{manual@entry}%
  }
  {\ifvmode\else\unskip\fi\end{manual@entry}}

\NewDocumentEnvironment{confkey}{ m m o }
  {%
    \par\vskip\baselineskip
    \bgroup
    \def\_{-}\def\meta##1{##1}%
    \edef\x{\noexpand\def\noexpand\@tmp@hyname{ckey:#1}}%
    \expandafter\egroup\x
    \needspace{3ex}\noindent
    \hypertarget{\@tmp@hyname}{\code{#1} [#2]}%
    \IfNoValueF{#3}{\hfill (#3)}%
    \begin{manual@entry}%
  }
  {\ifvmode\else\unskip\fi\end{manual@entry}}

\NewDocumentCommand{\Program}{ m }
  {%
    \bgroup
    \def\_{-}\def\meta##1{##1}%
    \edef\x{\noexpand\def\noexpand\@tmp@hyname{prog:#1}}%
    \expandafter\egroup\x
    \hypertarget{\@tmp@hyname}{\paragraph{Program \code{#1}}}%
  }

% code in hors-text
\newenvironment{htcode}
  {\SaveVerbatim[samepage]{verbmat}}
  {%
    \endSaveVerbatim
    \par\medskip\noindent\hspace*{2em}%
    \BUseVerbatim{verbmat}%
    \par\medskip\@endpetrue
  }

\DefineShortVerb{\|}
% EOF
