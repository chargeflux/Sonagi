# Sonagi
**Sonagi** is a Swift app that parses and breaks down Korean sentences and shows definitions for each morpheme or word. The parsing algorithm is based on [Open Korean Text Processor](https://github.com/open-korean-text/open-korean-text) and is accessed via [KoNLPy](https://github.com/konlpy/konlpy/), a Python package for Korean NLP. Definitions are based on [kengdic](https://github.com/garfieldnate/kengdic) by Joseph Speigle; `kengdic` is hosted by [garfieldnate](https://github.com/garfieldnate) and is released under MPL 2.0.

## Compilation
1) Install Cocoapods if not already installed
2) Run `pod install` in the folder `Dependencies`
3) Launch `Sonagi.xcworkspace`
4) Build

## Usage
1) Copy some Korean text and Sonagi will present, color-coded by part of speech. 
2) Hover over individual words or morphemes and see the definition as a popover
3) Sonagi will detect if the user's clipboard has changed when the user switches back to the app and will update the displayed text accordingly.

## TODO
1) Implement history
2) Clean up definitions before presenting, e.g., spacing, abbreviations

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Libraries/Databases Used
- [KoNLPy](https://github.com/konlpy/konlpy/) (0.5.1)
- [Open Korean Text Processor](https://github.com/open-korean-text/open-korean-text) (2.1.0 *according to KoNLPy*)
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) (0.11.5)
- [kengdic](https://github.com/garfieldnate/kengdic)

## License
[MIT](./LICENSE.txt)