# MATLAB Data Analysis Toolkit

I wrote most of this as an undergrad at RIT between 2017 and 2019, on nights and weekends. It's where I first got into data science. I haven't touched it in years, but the code is here as it was, reorganized so it's easier to follow.

There are two parts. The first is a set of functions for working with data: cleaning and trimming, categorical and numeric helpers, factor analysis, peak finding, joins, and plotting, plus the figure components I used to build dashboards on top of that data. The second is text analytics code from 2018 and 2019, written for two Kaggle competitions on toxic online comments. It takes messy comment text (slang, misspellings, hidden swear words, numbers, units, and links) and turns it into clean text that a model can use.

![Dashboard demo](docs/screenshot.png)

## Folders

```
data-analysis/      trimming, categorical and numeric methods, factor analysis, peak finding
visualization/      dashboard components, layout helpers, plotting, figure helpers
utilities/          logical and binary helpers, table joins, web search, general helpers
text-analytics/     comment cleaning and decoding, see text-analytics/README.md
examples/           dashboard demo and a factor analysis demo
assets/             images and .mat files the dashboard demo loads
release/            the original 2018 toolbox package (.mltbx)
docs/               screenshot of the dashboard demo
```

## Setup

I packaged the toolkit with MATLAB R2017a. Add the folders to your path from the repo root:

```matlab
folders = {'data-analysis','visualization','utilities','text-analytics','examples','assets'};
for k = 1:numel(folders)
    addpath(genpath(folders{k}))
end
```

You can also double-click `release/matlab-data-analysis-toolkit-2018.mltbx`. That file is the package I put on File Exchange in 2018, so it only has the toolkit, not the text analytics code, and it still has its old name inside.

## Examples

```matlab
run_dashboard_example
```

This opens `DemoFigure`, which runs `Example_Program.m` to build a dashboard with a menu, tables, buttons, sliders, a wheel control, two trees you can drag fields between, and a chart. It needs `assets/` on the path and uses `imresize` from the Image Processing Toolbox.

Most components are built the same way. `funBuildo` makes a settings struct (type, tag, position, and any extra properties), and `funControl` builds the component and stores it on `handles`.

`examples/factorDemo.m` runs a factor analysis with `factorMethods` and plots the result. It uses the variable names from MATLAB's `carbig` sample data, so run `load carbig` first.

## Data

None of the data is in this repo. That includes the Kaggle files, the saved decoder objects, and the word tables the text code loads (slang, bad words, state names, and so on). Most of it was .csv and .mat files, and the competition training file alone was about 800 MB. The scripts that built the word tables are in `text-analytics/word-lists/`.

## MATLAB Central

Three pieces of this were on File Exchange. My profile is [here](https://www.mathworks.com/matlabcentral/profile/authors/9682853).

- [Build a Modern Dashboard Today](https://www.mathworks.com/matlabcentral/fileexchange/65073-modern-gui-toolbox-iii): the toolkit package in `release/`.
- [feanalysis](https://www.mathworks.com/matlabcentral/fileexchange/65755-feanalysis): exploratory factor analysis. The same work lives on in `data-analysis/factorMethods.m`, `utilities/general/inputMethods.m`, and `examples/factorDemo.m`.
- [Google Search: Answer & Links](https://www.mathworks.com/matlabcentral/fileexchange/65829-google-search-answer-links): `utilities/web/google.m`. Google has changed its result pages since then, so it no longer parses them.

