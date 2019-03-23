# Sonagi

**Sonagi** is a Swift app that parses Korean sentences and shows definitions for each morpheme or word. The parsing algorithm is based on [Open Korean Text Processor](https://github.com/open-korean-text/open-korean-text) and is accessed via [KoNLPy](https://github.com/konlpy/konlpy/), a Python package for Korean NLP. Definitions are based on [kengdic](https://github.com/garfieldnate/kengdic) by Joseph Speigle; `kengdic` is hosted by [garfieldnate](https://github.com/garfieldnate) and is released under MPL 2.0.

## Compilation

1) Install Cocoapods if not already installed
2) Run `pod install` in the folder `Dependencies`
3) Launch `Sonagi.xcworkspace`
4) This app requires Python 3.6/2.7. The Python script embedded in this app, `KoNLPyParser.py`, for interfacing with KoNLPy assumes you have a Python installation at `/usr/bin/local/python`, which is the default installation from Homebrew. If you have a Python distribution from Anaconda etc., you may change the first line in the Python script to the path of the Python binary you prefer to use
    - If you are unsure what Python installation you have, run `which python` in terminal. If the output is `/usr/bin/python`, then macOS' system Python version is the default and is not recommended unless you are confident/have prior experience in using it. It is recommended to use Homebrew/Anaconda to avoid interacting with the system's Python distribution and avoid having to use `sudo` for installing Python packages
5) Install the `KoNLPy` package via Pip. Make sure you can successfully import `KoNLPy` (`import konlpy`), the first line of `KoNLPyParser.py` matches your preferred Python distribution and is the distribution that has the `KoNLPy` package installed.
6) Build
    - The app is confirmed to run on macOS 10.14.3 (macOS Mojave)
7) If users have [Nanum Square Regular](https://hangeul.naver.com/2017/nanum), available via Naver, installed, the app will use that font. Otherwise it will opt for the System font.


## Usage

1) Copy some Korean text and Sonagi will present the parsed text, color-coded by part of speech. 
2) Hover over individual words or morphemes and see the definition
3) Sonagi will detect if the user's clipboard has changed when the user switches back to the app and will update the displayed text accordingly.

## TODO

1) Implement history
2) Clean up definitions before presenting, e.g., spacing, abbreviations
3) Add filter for Korean text

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Libraries/Databases Used

- [KoNLPy](https://github.com/konlpy/konlpy/) (0.5.1)
- [Open Korean Text Processor](https://github.com/open-korean-text/open-korean-text) (2.1.0 *according to KoNLPy*)
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) (0.11.5)
- [kengdic](https://github.com/garfieldnate/kengdic)
    - The SQL file for `kengdic` used in **Sonagi** can found in this repository [here](./Sonagi/Database/kengdic.sql)

## License

[MIT](./LICENSE.txt)