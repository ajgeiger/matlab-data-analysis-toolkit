# Text analytics

This is the code I wrote for two Kaggle competitions run by Jigsaw on toxic online comments. In early 2018 it was the Toxic Comment Classification Challenge (Wikipedia talk page comments labeled toxic, severe_toxic, obscene, threat, insult, and identity_hate). In spring 2019 it was Jigsaw Unintended Bias in Toxicity Classification (news site comments).

People who post toxic comments try hard to get past filters, so the text is full of slang, misspellings, stretched words, letters split with spaces or symbols, look-alike Unicode characters, and links. Most of this code is about decoding that text back into plain words before any modeling. The 2018 code also builds word features for each label.

Because the goal was catching abusive words, some of the word lists and string literals include profanity. I took the slurs out of the code before publishing it. The full word tables I built back then were .mat files and aren't included.

## Folders

```
decoders/       DocumentDecoder and the classes it inherits from (2019)
context/        reading the words around a position and decoding numbers (2019)
cleaning/       text cleanup: symbols, spacing, look-alike characters, thesaurus lookups
features/       word index, word frequency by label, and letter count features (2018)
spell-check/    spelling correction for rare words using Microsoft Word (2018 and 2019)
word-lists/     scripts that built the slang, bad word, and replacement tables
web/            pulls YouTube titles and tweet text for links found in comments
scripts/        run scripts and small examples
archive/        early 2018 versions that later code replaced
```

## How the 2019 decoder works

`DocumentDecoder` inherits from four classes, and each one handles part of the job:

- `UrlDecoder` finds links. It swaps in the YouTube title and description or the tweet text where it can, follows bit.ly links, and tags news sites.
- `preDecoder` strips encoding junk, decodes words hidden with symbols or spaces (like `i s l a m i c`), and turns numbers, units, money, and times into words.
- `PatternDecoder` handles repeated letters (`lllloooosssseeeerrrrr`) and repeated patterns (`hahahaha`), and replaces slang.
- `WordDecoder` does spell checking and correction, splits words that run together, and handles tense and thesaurus lookups.

`scripts/run_document_decoder.m` shows the order I ran the steps in on a table of comments: `fitPreprocessing`, `fitPatterns`, then `fitSyntax`, and finally `saveTable` to write the result to CSV.

## Running it

It won't run as is. `WordDecoder` loads `text_structure.mat`, which held the word tables, and that file isn't included. It also opens Microsoft Word through `actxserver` for spell checking, so it only runs on Windows with Word installed. `extractHTMLText` needs the Text Analytics Toolbox, and the `parfor` loops run in parallel only if you have the Parallel Computing Toolbox.

The web scrapers (YouTube, Twitter, thesaurus sites, noslang.com) were written against those sites as they were in 2018 and 2019 and probably won't work now.
