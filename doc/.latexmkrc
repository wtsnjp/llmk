# .latexmkrc for Texdoc documentation
# Public domain.

$pdflatex = "xelatex -synctex=1 -interaction=nonstopmode -halt-on-error %O %S";
$max_repeat = 5;
$pdf_mode = 1;
