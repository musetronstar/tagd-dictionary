# Voice of America Word Book in Simple English
## in the TAGL language

The VOA Word Book and these project files are in the Public Domain, copywrite free, and can be used for any purpose.

### Steps to produce

1. Download the VOA Word Book:

   `wget http://docs.voanews.eu/en-US-LEARN/2014/02/15/7f8de955-596b-437c-ba40-a68ed754c348.pdf`
2. Convert from pdf to text:

   `pdftotext -nopgbrk -enc ASCII7 7f8de955-596b-437c-ba40-a68ed754c348.pdf`

   Insert blanks lines in 7f8de955-596b-437c-ba40-a68ed754c348.txt before and after
   the caption 'fish' (line 1273) or it will get parsed incorrectly
3. Extract the word list and definitions into a well formatted tab delimmited file:

   `./txt-defs-to-tsv.pl 7f8de955-596b-437c-ba40-a68ed754c348.txt > word-list-defs.tsv`
4. Edit a few inconsistenly formatted words that produced anomolies in the parsed tsv file `word-list-defs.tsv`.  See [Word List Definition Edits].
5. Consruct a file of spans of text up to a given part of speech ordered by frequency of occurence.
   The file is in the format: `<freq> <span> <tab> <pos>`

   `awk -F '\t' '{ print $2 }' word-list-defs.tsv | sort | uniq | while read pos ; do ./ngrams.pl span-pos $pos word-list-defs.tsv ; done | sort | uniq -c | sort -nr > pos-spans.txt`

### [Word List Definition Edits]:

    $ diff prev-word-list-defs.tsv word-list-defs.tsv
    1,3c1,3
    < a (an)	ad.	one
    < a (an)	ad.	any
    < a (an)	ad.	each
    ---
    > a	ad.	one
    > a	ad.	any
    > a	ad.	each
    76a77,79
    > an	ad.	one
    > an	ad.	any
    > an	ad.	each
    313,314d315
    < case (court)	n.	a legal action
    < case (medical)	n.	an incident of disease	There was only one case of chicken pox at the school.
    459a461
    > court case	n.	a legal action
    1400a1403
    > medical case	n.	an incident of disease	There was only one case of chicken pox at the school.
    2040,2042c2043,2046
    < seek(ing)	v.	to search for	They are seeking a cure for cancer.
    < seek(ing)	v.	to try to get	She is seeking election to public office.
    < seek(ing)	v.	to plan to do	Electric power companies are seeking to reduce their use of coal.
    ---
    > seek	v.	to search for	They are seeking a cure for cancer.
    > seek	v.	to try to get	She is seeking election to public office.
    > seek	v.	to plan to do	Electric power companies are seeking to reduce their use of coal.
    > seeking	v.	to seek
    2112c2116,2118
    < should	v.	used with another verb (action word) to show responsibility ("We should study."), probability ("The talks should begin soon."), or that something is believed to be a good idea	Criminals should be punished.
    ---
    > should	v.	used with another verb (action word) to show responsibility	We should study
    > should	v.	used with another verb (action word) to show probability	The talks should begin soon.
    > should	v.	that something is believed to be a good idea	Criminals should be punished.
    2327,2328c2333
    < surplus	n.	extra
    < surplus	n.	("That country has a trade surplus. It exports more than it imports.")
    ---
    > surplus	n.	extra	That country has a trade surplus. It exports more than it imports.
    2524c2529,2530
    < us	pro.	the form of the word "we" used after a preposition ("He said he would write to us.") or used as an object of a verb	They saw us yesterday.
    ---
    > us	pro.	the form of the word "we" used after a preposition	He said he would write to us.
    > us	pro.	used as an object of a verb	They saw us yesterday.
