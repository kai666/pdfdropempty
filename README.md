# pdfdropempty.sh

little sh script to drop empty pages from PDF file.

Relies on PDFjam by David Firth.

# usage

    $ pdfdropempty file_with_empty_pages.pdf

The script creates two new files, called $fn_full.pdf and $fn_empty.pdf.
$fn_empty.pdf should consist of solely empty pages, all pages found to
contain text/images are in $fn_full.pdf

# known limitations

I guess it works only with correctly OCR'ed PDFs.
