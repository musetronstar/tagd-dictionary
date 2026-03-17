#!/bin/bash

for a in {a..z}
do
	wget http://www.voanews.com/MediaAssets2/classroom/interactive_learning/interactive_wordbook/deploy/${a}/data/presentation.xml -O presentation-${a}.utf16le.xml
	iconv -f UTF-16LE -t UTF-8 presentation-${a}.utf16le.xml -o presentation-${a}.utf8.xml
done
