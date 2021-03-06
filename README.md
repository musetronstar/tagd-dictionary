# Voice of America Word Book in Simple English
## in the TAGL language

The VOA Word Book and these project files are in the Public Domain, copywrite free, and can be used for any purpose.

### Steps to produce

1. Download the VOA Word Book:

   `wget http://docs.voanews.eu/en-US-LEARN/2014/02/15/7f8de955-596b-437c-ba40-a68ed754c348.pdf`

2. Convert from pdf to text:

   `pdftotext -nopgbrk -enc ASCII7 7f8de955-596b-437c-ba40-a68ed754c348.pdf`

   Insert blanks lines in `7f8de955-596b-437c-ba40-a68ed754c348.txt` before and after
   the caption `fish (line 1273)` or it will get parsed incorrectly

3. Extract the word list and definitions into a well formatted tab delimmited file:

   `./txt-defs-to-tsv.pl 7f8de955-596b-437c-ba40-a68ed754c348.txt | awk -F '\t' '{ printf "%s\t%s\t%s\t%s\n", $1, $2, $3, $4}' > word-list-defs.tsv`

   (awk adds a 4th column if doesn't exist - to make github TSV parser happy)

4. Edit anomolies in the parsed tsv file `word-list-defs.tsv` due to inconsistent formatting in the source document. Add a TSV header and replace `"` with `'` to make github's TSV file parser happy.  See [Word List Definition Edits](#word-list-definition-edits).

5. Generate a TAGL file of the word list and definitions:

	`./tsv-to-tagl.pl VOA word-list-defs.tsv > word-list-defs.tagl`

6. Consruct a file of spans of text up to a given part of speech ordered by frequency of occurence.
   The file is in the format: `freq <tab> span <tab> pos`

   `echo -e "#freq\t#span\t#pos" > pos-spans.tsv && awk -F '\t' '{ print $2 }' word-list-defs.tsv | sort | uniq | while read pos ; do ./ngrams.pl span-pos $pos word-list-defs.tsv ; done | sort | uniq -c | sort -nr | sed 's/^ *\([0-9]\+\) \(.*\)/\1\t\2/g' >> pos-spans.tsv`

### [Word List Definition Edits]:

    $ diff prev-word-list-defs.tsv word-list-defs.tsv
    1,3c1,4
    < a (an)	ad.	one	
    < a (an)	ad.	any	
    < a (an)	ad.	each	
    ---
    > #word	#pos	#definition	#example
    > a	ad.	one	
    > a	ad.	any	
    > a	ad.	each	
    76a78,80
    > an	ad.	one	
    > an	ad.	any	
    > an	ad.	each	
    149c153
    < available	ad.	willing to serve or help.	There was a list of available candidates.
    ---
    > available	ad.	willing to serve or help	There was a list of available candidates.
    313,314d316
    < case (court)	n.	a legal action	
    < case (medical)	n.	an incident of disease	There was only one case of chicken pox at the school.
    352c354
    < circle	n.	a closed shape that has all its points equally distant from the center, like an "O"	
    ---
    > circle	n.	a closed shape that has all its points equally distant from the center, like an 'O'	
    361c363
    < class	n.	also a social or economic group.	They were members of the middle class.
    ---
    > class	n.	also a social or economic group	They were members of the middle class.
    382c384
    < collapse	v.	to break down or fail suddenly in strength, health or power.	The building collapsed in the earthquake. The government collapsed after a vote in parliament.
    ---
    > collapse	v.	to break down or fail suddenly in strength, health or power	The building collapsed in the earthquake. The government collapsed after a vote in parliament.
    459a462
    > court case	n.	a legal action	
    599c602
    < discrimination	n.	unfair treatment or consideration based on opinions about a whole group instead of on the qualities of an individual.	He was accused of discrimination against people from other countries.
    ---
    > discrimination	n.	unfair treatment or consideration based on opinions about a whole group instead of on the qualities of an individual	He was accused of discrimination against people from other countries.
    617c620
    < donate	v.	to present something as a gift to an organization, country or cause.	She donated money to the Red Cross to help survivors of the earthquake.
    ---
    > donate	v.	to present something as a gift to an organization, country or cause	She donated money to the Red Cross to help survivors of the earthquake.
    619c622
    < double	v.	to increase two times as much in size, strength or number.	
    ---
    > double	v.	to increase two times as much in size, strength or number	
    929c932
    < generation	n.	a group of individuals born and living about the same time.	The mother and daughter represented two generations.
    ---
    > generation	n.	a group of individuals born and living about the same time	The mother and daughter represented two generations.
    1184c1187
    < interest	n.	money paid for the use "of money borrowed	
    ---
    > interest	n.	money paid for the use of money borrowed	
    1400a1404
    > medical case	n.	an incident of disease	There was only one case of chicken pox at the school.
    1624,1625c1628
    < other	ad.	the remaining one or ones of two or more	That man is short
    < other	ad.	the other is tall.")	
    ---
    > other	ad.	the remaining one or ones of two or more	That man is short; the other is tall.
    1651c1654
    < partner	n.	a person who takes part in some activity in common with another or others.	The two men were business partners.
    ---
    > partner	n.	a person who takes part in some activity in common with another or others	The two men were business partners.
    1756c1759
    < predict	v.	to say what one believes will happen in the future.	The weather scientist predicted a cold winter.
    ---
    > predict	v.	to say what one believes will happen in the future	The weather scientist predicted a cold winter.
    2000c2003
    < rural	ad.	describing areas away from cities which may include farms, small towns and unpopulated areas.	
    ---
    > rural	ad.	describing areas away from cities which may include farms, small towns and unpopulated areas	
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
    > us	pro.	the form of the word 'we' used after a preposition	He said he would write to us.
    > us	pro.	used as an object of a verb	They saw us yesterday.
    2706c2712
    < processor	n.	the brain of a computer which carries out software instructions that operate the hardware of the computer and devices attached to it. Also called a CPU or chip.	
    ---
    > processor	n.	the brain of a computer which carries out software instructions that operate the hardware of the computer and devices attached to it Also called a CPU or chip.	
    2710,2711c2716,2717
    < account	n.	a record of financial dealings. For example, a bank account is a record of how much money a person or company has in a bank	
    < bond	n.	an agreement to pay interest on a loan, generally for a period of years, until the loan is repaid. A bond can be bought or sold.	
    ---
    > account	n.	a record of financial dealings	A bank account is a record of how much money a person or company has in a bank
    > bond	n.	an agreement to pay interest on a loan, generally for a period of years, until the loan is repaid	A bond can be bought or sold.
    2715,2718c2721,2724
    < dividend	n.	part of a company's earnings that is given to shareholders. Not all stocks pay dividends.	
    < index	n.	a way of measuring the value of a group of securities. For example, a stock index measures the value of a group of stocks.	
    < security	n.	evidence of ownership that has financial value, such as a stock or bond. Security can also mean a financial contract that has value.	
    < stock	n.	a share in ownership of a company. The stock of public companies is traded on stock exchanges.	
    ---
    > dividend	n.	part of a company's earnings that is given to shareholders	Not all stocks pay dividends.
    > index	n.	a way of measuring the value of a group of securities	A stock index measures the value of a group of stocks.
    > security	n.	evidence of ownership that has financial value, such as a stock or bond	Security can also mean a financial contract that has value.
    > stock	n.	a share in ownership of a company	The stock of public companies is traded on stock exchanges.
