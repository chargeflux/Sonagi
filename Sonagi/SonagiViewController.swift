//
//  SonagiViewController.swift
//  Sonagi
//
//  Created by chargeflux on 12/2/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa
import SQLite

class SonagiViewController: NSViewController {
    
    @IBOutlet var outputTextView: NSTextView!
    
    /// Holds the current text extracted from Pasteboard
    var textKR: String? {
        didSet {
            // Parse the string if it is set (representing a change)
            let parseKRTextWorkItem = DispatchWorkItem { [weak self] in
                self!.parseKRText()
            }
            DispatchQueue.main.async(execute: parseKRTextWorkItem)
        }
    }
    
    /// Holds raw string from pasteboard
    var rawText: String?
    
    /// Holds the PartOfSpeech class for the current instance of `textKR`
    var textKRPartOfSpeech: PartOfSpeech?
    
    /// Font for Korean text
    let KRFont = NSFont(name: "NanumSquareR", size: 32) ?? NSFont.systemFont(ofSize: 32)
    
    /// Holds all information popovers for the current instance of `textKR`
    /// It is indexed by word order in `textKR`
    var currentInfoPopover = [Int: NSPopover]()
    
    /// The SQLite.Swift connection to `dictionary.db`
    var dictionaryDB: Connection?
    
    /// The table/dictionary from `dictionary.db` that will be queried
    var dictionary: Table?
    
    /// Describes the column in database as a generic structure for parsing in SQLite.swift
    let word = Expression<String>("word")
    
    let def = Expression<String>("def")
    
    /// Track change count of User's pasteboard, which changes every time the pasteboard is changed
    var pasteboardCount: Int = NSPasteboard.general.changeCount
    
    /// Holds any observers that are registered to Notification center
    var observers: [NSObjectProtocol] = []
    
    var currentWindowSize: NSSize?
    
    /// Holds all newlines manually inserted into `outputTextView`
    var forcedNewLines: [Int:NSRange] = [:]
    
    override func viewDidLoad() {
        // TODO: detect and parse text on first launch?
        super.viewDidLoad()
        dictionaryDB = try! Connection(Bundle.main.path(forResource: "dictionary", ofType: "db",
                                                        inDirectory: "Database")!,readonly:true)
        dictionary = Table("kengdic")
        
        // Add observer for when App becomes active
        observers.append(NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil, queue: nil,
            using: windowDidBecomeKey))
        
        // Add observer for when window is resized
        observers.append(NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: nil, queue: nil,
            using: windowResized))
    }
    
    override func viewDidAppear() {
        currentWindowSize = self.view.window!.frame.size
    }
    
    /// Receives notification for window resize events and initiates recalculation of
    /// NSTrackingArea per morpheme if window size changed
    func windowResized(_ notification: Notification) {
        guard self.view.window!.frame.size != currentWindowSize
            else { return }
        recalculateTracking()
        currentWindowSize = self.view.window!.frame.size
    }
    
    /// Recalculate all instances of NSTrackingArea due to change in position for morphemes/words
    /// and window size
    func recalculateTracking() {
        glyphLowerBound = 0
        
        /// Make sure text exists for recalculation to occur
        guard outputTextView.string != ""
            else { return }
        
        // Remove all previous insertions of newlines due to previous resize event
        // Removal is in reverse to negate need to recalculate shifted NSRange values if not in reverse
        for lineBreak in forcedNewLines.keys.sorted(by: { $0 > $1 }){
            outputTextView.textStorage?.deleteCharacters(in: forcedNewLines[lineBreak]!)
        }
        forcedNewLines.removeAll()
        
        for trackingArea in outputTextView.trackingAreas {
            outputTextView.removeTrackingArea(trackingArea)
        }
        
        let currentOutputTextViewString = outputTextView.string
        let beforeEndIndexCurrentOutput = currentOutputTextViewString.index(before:currentOutputTextViewString.endIndex)

        for position in (textKRPartOfSpeech?.posDictNotStemmed.keys.sorted())! {
            
            let currentMorpheme = textKRPartOfSpeech?.posDictNotStemmed[position]?.morph
            
            setTracking(morpheme: currentMorpheme, position: position)
            
            guard let afterMorphemeIndex = currentOutputTextViewString.index(currentOutputTextViewString.startIndex,offsetBy: glyphLowerBound,limitedBy:beforeEndIndexCurrentOutput) // Can't use EndIndex as limitedBy bound
                else {
                    return
            }
            if currentOutputTextViewString[afterMorphemeIndex] == " " { // Makes sure setTracking accounts for whitespace in outputTextView
                addWhitespace = true
            }
        }
    }
    
    /// Clean raw text from pasteboard by stripping newlines and excess spaces
    func cleanRawText() {
        rawText = rawText?.replacingOccurrences(of: "\n", with: " ")
        if (rawText?.contains("  "))! {
            rawText = rawText?.replacingOccurrences(of: "[ ]+", with: " ", options: .regularExpression, range: nil)
        }
        rawText = rawText!.trimmingCharacters(in: .whitespaces)
        textKR = rawText
    }
    
    /// Initiate parsing of `textKR` for Part of Speech tagging
    func parseKRText() {
        guard let textKRPartOfSpeech = PartOfSpeech(input: textKR)
            else {
                return
        }
        // Set the text in outputTextView (Sonagi's window) with a parsed/tagged form of `textKR`
        setText(input:textKRPartOfSpeech)
        
        // Updates the current instance of textKRPartOfSpeech with a parsed/tagged form of `textKR`
        self.textKRPartOfSpeech = textKRPartOfSpeech
    }
    
    /// Executed whenever the app becomes the key window
    /// Checks if pasteboard changes and sets `textKR` with the new string retrieved from User's pasteboard
    /// else nothing changes and exits early
    /// - Parameters:
    ///     - notification: A notification whose name is `NSApplication.didBecomeActiveNotification`
    func windowDidBecomeKey(_ notification: Notification) {
        guard let detectedText = checkPasteboardChanged()
            else {
                return
        }
        rawText = detectedText
        cleanRawText()
    }
    
    /// Checks if the User's pasteboard changed by comparing change count
    /// - Returns:
    ///     - String: The latest item as String from User's pasteboard
    func checkPasteboardChanged() -> String? {
        guard pasteboardCount != NSPasteboard.general.changeCount
            else {
                return nil
        }
        // Updates `pasteboardCount` with the current changeCount
        pasteboardCount = NSPasteboard.general.changeCount
        
        // Gets latest item in User's pasteboard that is of type "String"
        return NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
    }
    
    /// Parse the PartOfSpeech object and set text in outputTextView
    /// - Parameters:
    ///     - input: the `PartOfSpeech` object to be processed and set in `outputTextView`
    func setText(input: PartOfSpeech) {
        /// textKRFullString will be sliced per iteration of `posDictNotStemmed` to maintain position
        var textKRFullString = textKR!
        clearOutputTextView()
        
        // Sort dictionary by index in ascending order
        for key in input.posDictNotStemmed.keys.sorted() {
            // Inherent assumption that posDictNotStemmed == textKR, aside from white space.
            
            /// Set attributes for morpheme/word detected by Open Korean Text Processor (Okt), especially color according to tag
            let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:KRFont,
                                                              NSAttributedString.Key.foregroundColor:
                                                                input.posDictNotStemmed[key]!.color!]
            
            let morpheme = NSAttributedString(string: input.posDictNotStemmed[key]!.morph,attributes:attributes)

            /// Okt does not detect whitespace and has to be accounted for
            var isWhiteSpace: Bool!
            
            // Note `checkWhiteSpaceSlice` checks if there is a whitespace and slices `textKRFullString `as well
            (isWhiteSpace, textKRFullString) = checkWhiteSpaceSlice(fullString: textKRFullString, morpheme: morpheme.string)
            if isWhiteSpace {
                outputTextView.textStorage?.append(morpheme)
                
                // Adds NSTracking area for morpheme/word
                setTracking(morpheme: morpheme.string, position: key)
                
                // Adds whitespace after new morpheme/word in the text string in outputTextView to match `textKRFullString`
                outputTextView.textStorage?.append(NSAttributedString(string:" ",attributes:attributes))
                
                // Makes sure setTracking accounts for inserted whitespace in outputTextView that matches `textKRFullString`
                addWhitespace = true
            }
            else {
                outputTextView.textStorage?.append(morpheme)
                setTracking(morpheme: morpheme.string, position: key)
            }
        }
    }
    
    /// Checks if there is a white space after the morpheme/word from Okt in `fullString` and slices `fullString` (e.g., `textKRFullString`) after whitespace or the last `morpheme` character in `fullString`.
    /// - Parameters:
    ///     - fullString: The full string to check against for whitespace and to be sliced
    ///     - morpheme: The string that will be checked against fullString for orientation and whitespace
    /// - Returns:
    ///     - Bool: If there is a whitespace after `morpheme`
    ///     - String: The sliced fullString after any white space or the last `morpheme` character in `fullString`
    func checkWhiteSpaceSlice(fullString: String, morpheme: String) -> (Bool?, String) {
        
        /// Orients `morpheme` to `fullString` and get the last index where `morpheme` matches `fullString`
        let lastCommonIndex = fullString.index(fullString.startIndex, offsetBy: morpheme.count-1)
        
        // if afterLastCommonIndex == fullString.endIndex, function does not return nil; necessary to check
        if let afterLastCommonIndex = fullString.index(lastCommonIndex,offsetBy: 1, limitedBy: fullString.endIndex) as String.Index?, afterLastCommonIndex != fullString.endIndex {
                if fullString[afterLastCommonIndex] == " " {
                    // returns true and sliced `fullString` after whitespace
                    return (true, String(fullString[fullString.index(after:afterLastCommonIndex)...]))
                }
            // returns false and sliced `fullString` after the last `morpheme` character in `fullString`
            return (false, String(fullString[afterLastCommonIndex...]))
        }
        // fullString can't be sliced
        return (false, fullString)
    }
    
    /// Tracks the position of the last morpheme/word in outputTextView's string
    var glyphLowerBound: Int = 0
    
    /// If outputTextView has an inserted whitespace character to match `textKR`
    var addWhitespace: Bool = false
    
    /// Sets a NSTrackingArea for each morpheme/word detected by Okt in outputTextView with "position" key that holds the
    /// position of the morpheme in the overall text string.
    /// - Parameters:
    ///     - morpheme: The morpheme/word for which a NSTracking area is to be added
    ///     - position: The position of the morpheme/word in the overall text string
    func setTracking(morpheme: String!, position: Int) {
        if addWhitespace {
            addWhitespace = false
            glyphLowerBound += 1
        }
        
        let morphemeLength = morpheme.count
        var glyphRect = outputTextView.layoutManager?.boundingRect(forGlyphRange: NSMakeRange(glyphLowerBound, morphemeLength), in: outputTextView.textContainer!)
        
        // Checks if word is split due to word wrapping (40 is due to fixed text size)
        // TODO: Calculation of expected glyphRect height
        if (glyphRect?.height)! > CGFloat(40) {
            let newline = NSAttributedString(string: "\n")
            outputTextView.textStorage?.insert(newline, at: glyphLowerBound)
            forcedNewLines[position] = NSMakeRange(glyphLowerBound, 1)
            glyphRect = outputTextView.layoutManager?.boundingRect(forGlyphRange: NSMakeRange(glyphLowerBound+1, morphemeLength), in: outputTextView.textContainer!)
        }
        
        let area = NSTrackingArea.init(rect: CGRect(origin: (glyphRect?.origin)!,size:glyphRect!.size), options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: ["Position": position])
        outputTextView.addTrackingArea(area)
        glyphLowerBound += morphemeLength
    }

    override func mouseEntered(with event: NSEvent) {
        let mouseHoverPosition = event.trackingArea?.userInfo!["Position"] as! Int
        // Checks if infoPopover already exists, else shows a newly created one
        guard currentInfoPopover[mouseHoverPosition] == nil
            else {
                currentInfoPopover[mouseHoverPosition]?.show(relativeTo: (event.trackingArea?.rect)!, of: outputTextView, preferredEdge: NSRectEdge.minY)
                return
        }
        // morphemeRect and mouseHoverPosition is the triggered NSTrackingArea's rectangle and "Position" value
        showInfoPopover(morphemeRect: (event.trackingArea?.rect)!,position: mouseHoverPosition)
    }
    
    override func mouseExited(with event: NSEvent) {
        let mouseHoverStopPosition = event.trackingArea?.userInfo!["Position"] as! Int
        currentInfoPopover[mouseHoverStopPosition]!.close()
    } // FIXME: If text is slightly offscreen, enter/exit event is fired rapidly - masking or prevent repeat event?
    
    /// Initiates the creation of a information popover and shows it above the hovered morpheme/word
    /// - Parameters:
    ///     - morphemeRect: the rectangular region defined by the morpheme's NSTrackingArea
    ///     - position: The position of the morpheme/word in the overall text string
    func showInfoPopover(morphemeRect: NSRect, position: Int) {
        let infoPopover = createInfoPopover(position:position)
        infoPopover!.show(relativeTo: morphemeRect, of: outputTextView, preferredEdge: NSRectEdge.minY)
        
        // Adds newly created infoPopover to `currentInfoPopover` for tracking
        currentInfoPopover[position] = infoPopover
    }
    
    /// Creates a new infoPopover using the given position to retrieve the morpheme/word from the current
    /// instance of `textKRPartOfSpeech`
    ///
    /// - Parameter position: The position of the morpheme/word in the overall text string
    func createInfoPopover(position:Int) -> NSPopover? {
        let infoFont = NSFont.systemFont(ofSize: 18)
        let attributeMorpheme: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:infoFont,
                                                                  NSAttributedString.Key.foregroundColor:
                                                                    NSColor.white]

        let morph = (textKRPartOfSpeech?.posDict[position]?.morph)!
        let stringMorpheme = NSAttributedString(string: morph + " ",attributes: attributeMorpheme)
        let attributesPOS: [NSAttributedString.Key : Any] = [.font: infoFont,
                                                             .foregroundColor:
                                                            textKRPartOfSpeech!.posDict[position]!.color!]
        let stringPOS = NSAttributedString(string: "(" + (textKRPartOfSpeech?.posDict[position]?.pos)! + ")",
                                           attributes:attributesPOS)
        
        // Get up to 4 entries in the dictionary for morpheme/word
        let query = dictionary!.filter(word == morph).limit(4)
        
        // If there is no definition, there is only one newline character after "word (pos)"
        var definition: String! = "\n"
    
        for (index, queryResult) in try! dictionaryDB!.prepare(query).enumerated() {
            if index == 0 {
                // If there is a definition, add another newline character after "word (pos)" for a total of two
                definition.append("\n")
            }
            definition.append(String(index+1) + ". " + queryResult[def] + "\n")
        }
        
        let stringDefinition = NSAttributedString(string:definition,attributes:attributeMorpheme)

        let infoPopover = NSPopover()
        let infoPopoverViewController = NSViewController()
        
        infoPopover.contentViewController = infoPopoverViewController
        infoPopover.behavior = .applicationDefined
        infoPopover.animates = false
        
        let informationTextView = NSTextView(frame: NSRect(x: 0, y: -20, width: 300, height: 0))
        informationTextView.textStorage?.append(stringMorpheme)
        informationTextView.textStorage?.append(stringPOS)
        informationTextView.textStorage?.append(stringDefinition)
        
        informationTextView.sizeToFit()
        
        informationTextView.textContainerInset = NSSize(width: 10, height: 10)
        infoPopoverViewController.view = NSView(frame: informationTextView.frame)
        infoPopover.contentSize = NSSize(width:informationTextView.frame.size.width, height:informationTextView.frame.size.height-20)
        
        informationTextView.backgroundColor = NSColor.black
        informationTextView.isSelectable = false
        informationTextView.isEditable = false
        
        // Override NSPopover's default background color with a custom NSView class
        infoPopover.contentViewController!.view = CustomPopoverBackground()
        infoPopover.contentViewController!.view.addSubview(informationTextView)
        
        return infoPopover
    }
    
    /// Reset outputTextView; remove string in outputTextView, popovers and trackingAreas for previous sentence
    func clearOutputTextView() {
        for popover in currentInfoPopover.values {
            popover.close()
        }
        currentInfoPopover.removeAll()
        
        for trackingArea in outputTextView.trackingAreas {
            outputTextView.removeTrackingArea(trackingArea)
        }
        
        outputTextView.textStorage?.deleteCharacters(in: NSMakeRange(0, (outputTextView.textStorage?.string.count)!))
        
        glyphLowerBound = 0
    }
}


/// Overrides the background of NSPopover to a custom color
class CustomPopoverBackground: NSView {
    /// Intercept view and modify before adding to NSPopover view hierachy
    /// https://developer.apple.com/documentation/appkit/nsview/1483329-viewdidmovetowindow
    override func viewDidMoveToWindow() {
        guard let baseView = window?.contentView?.superview
            else { return }
        
        let backgroundView = NSView(frame: baseView.bounds)
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.black.cgColor
        backgroundView.autoresizingMask = [.width, .height]

        baseView.addSubview(backgroundView, positioned: .below, relativeTo: baseView)
    }
}
