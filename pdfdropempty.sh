#!/bin/sh

###
### script to remove empty pages from PDF file
###
###
# Copyright (c) 2017 Kai Doernemann (kai_AT_doernemann.net)
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY KAI DOERNEMANN "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
###

PDFJOIN=pdfjoin
PDFTOTEXT=pdftotext
PERL=perl

pdfXtract () {
	# this function uses 3 arguments:
	#     $1 is the list of pages to extract (","-separated)
	#     $2 is the filename addendum (empty/full)
	#     $3 is the input file
	#     output file will be named "inputfile_$mode.pdf"
	${PDFJOIN} --outfile "${3%.pdf}_${2}.pdf" "$3" "${1}"
}

pdfGenerateTwo () {
	inputpdf="$1"
	set -- `${PDFTOTEXT} $inputpdf - | ${PERL} -e '
my @full = ();
my @empty = ();
my $n = 1;
my $content_length = 0;
while (<>) {
	while (s{^\f}{}) {
		# next page
		if ($content_length) {	push(@full,  $n); }
		else {			push(@empty, $n); }
		$content_length = 0;
		$n++;
	}
	$content_length += length($_);
}
print join(",", @full), " ", join(",", @empty), "\n";
'
`
	full="$1"
	empty="$2"
	if [ -z "$empty" ]; then
		echo "$inputpdf has no empty pages - aborting conversion" >&2
		return
	fi
	if [ -z "$full" ]; then
		echo "$inputpdf has no pages with content - aborting conversion" >&2
		return
	fi
	pdfXtract $full  full  $inputpdf
	pdfXtract $empty empty $inputpdf
}

for inpdf in "$@"; do
	pdfGenerateTwo "$inpdf"
done
exit 0

