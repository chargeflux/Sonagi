//
//  SonagiViewController.swift
//  Sonagi
//
//  Created by chargeflux on 12/2/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa

class SonagiViewController: NSViewController {
    
    @IBOutlet var outputTextView: NSTextView!
    
    var morpheme: NSAttributedString?
    
    var textKR: String? = "저는 내년에 한국에 갈 거예요"
    
    var textKRPartOfSpeech: PartOfSpeech?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeKRText()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func initializeKRText() {
        // MARK: Implement pasteboard - continuing monitor, filter for Korean text only?
        guard let textKRPartOfSpeech = PartOfSpeech(input: textKR!)
            else {
                return
            }
        setText(input:textKRPartOfSpeech)
    }
    
    func setText(input: PartOfSpeech) {
        let font = NSFont(name: "NanumSquareR", size: 32) ?? NSFont.systemFont(ofSize: 32)
        var textKRFullString = textKR!
        for key in input.posDict.keys.sorted() {
            let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:font,
                                                              NSAttributedString.Key.foregroundColor:
                                                                input.posDict[key]!.color!]
            morpheme = NSAttributedString(string: input.posDict[key]!.morph,attributes:attributes)
            let textCommon = textKRFullString.commonPrefix(with: (morpheme?.string)!)
            var isWhiteSpace: Bool!
            if textCommon.count == morpheme?.string.count {
                (isWhiteSpace, textKRFullString) = checkWhiteSpace(fullString: textKRFullString, commonString: textCommon, textToSet: morpheme!)
                if isWhiteSpace {
                    outputTextView.textStorage?.append(morpheme!)
                    setTracking(morpheme: morpheme?.string)
                    outputTextView.textStorage?.append(NSAttributedString(string:" "))
                }
                else {
                    outputTextView.textStorage?.append(morpheme!)
                    setTracking(morpheme: morpheme?.string)
                }
            }
            else {
                (isWhiteSpace, textKRFullString) = checkWhiteSpace(fullString: textKRFullString, commonString: textCommon, textToSet: morpheme!)
                let morphemeModified = NSAttributedString(string:textCommon, attributes:attributes)
                outputTextView.textStorage?.append(morphemeModified)
                setTracking(morpheme: morphemeModified.string)
                if isWhiteSpace {
                    outputTextView.textStorage?.append(NSAttributedString(string:" "))
                }
                
            }
        }
    }
    
    func checkWhiteSpace(fullString: String, commonString: String, textToSet: NSAttributedString) -> (Bool?, String) {
        let lastCommonIndex = fullString.index(fullString.startIndex, offsetBy: commonString.count-1)
        
        if let afterLastCommonIndex = fullString.index(lastCommonIndex,offsetBy: 1, limitedBy: fullString.endIndex) as String.Index?, afterLastCommonIndex != fullString.endIndex {
            // if afterLastCommonIndex == fullString.endIndex, function does not return nil; necessary to check
                if fullString[afterLastCommonIndex] == " " {
                    return (true, String(fullString[fullString.index(after:afterLastCommonIndex)...]))
                }
            return (false, String(fullString[afterLastCommonIndex...]))
        }
        return (false, fullString)
    }
    
    var glyphLowerBound: Int = 0
    
    var glyphRectPrevWidth: CGFloat!
    
    func setTracking(morpheme: String!) {
        let glyphUpperBound = outputTextView.layoutManager?.glyphRange(for: outputTextView.textContainer!).upperBound
        let glyphRect = outputTextView.layoutManager?.boundingRect(forGlyphRange: NSMakeRange(glyphLowerBound, glyphUpperBound!-glyphLowerBound), in: outputTextView.textContainer!)
        let area = NSTrackingArea.init(rect: CGRect(origin: (glyphRect?.origin)!,size:glyphRect!.size), options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
        outputTextView.addTrackingArea(area)
        glyphLowerBound = glyphUpperBound!
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("Entered")
    }
    
    override func mouseExited(with event: NSEvent) {
        print("Exited")
    }
}
