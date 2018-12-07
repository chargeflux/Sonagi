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
    
    var morpheme: NSAttributedString?
    
    var textKR: String? = "저는 내년에 한국에 갈 거예요"
    
    var textKRPartOfSpeech: PartOfSpeech?
    
    var currentInfoPopover = [Int: NSPopover]()
    
    let KRFont = NSFont(name: "NanumSquareR", size: 32) ?? NSFont.systemFont(ofSize: 32)
    
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
        self.textKRPartOfSpeech = textKRPartOfSpeech
    }
    
    func setText(input: PartOfSpeech) {
        var textKRFullString = textKR!
        for key in input.posDict.keys.sorted() {
            let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:KRFont,
                                                              NSAttributedString.Key.foregroundColor:
                                                                input.posDict[key]!.color!]
            morpheme = NSAttributedString(string: input.posDict[key]!.morph,attributes:attributes)
            let textCommon = textKRFullString.commonPrefix(with: (morpheme?.string)!)
            var isWhiteSpace: Bool!
            if textCommon.count == morpheme?.string.count {
                (isWhiteSpace, textKRFullString) = checkWhiteSpace(fullString: textKRFullString, commonString: textCommon, textToSet: morpheme!)
                if isWhiteSpace {
                    outputTextView.textStorage?.append(morpheme!)
                    setTracking(morpheme: morpheme?.string, position: key)
                    outputTextView.textStorage?.append(NSAttributedString(string:" "))
                }
                else {
                    outputTextView.textStorage?.append(morpheme!)
                    setTracking(morpheme: morpheme?.string, position: key)
                }
            }
            else {
                (isWhiteSpace, textKRFullString) = checkWhiteSpace(fullString: textKRFullString, commonString: textCommon, textToSet: morpheme!)
                let morphemeModified = NSAttributedString(string:textCommon, attributes:attributes)
                outputTextView.textStorage?.append(morphemeModified)
                setTracking(morpheme: morphemeModified.string, position: key)
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
    
    func setTracking(morpheme: String!, position: Int) {
        let glyphUpperBound = outputTextView.layoutManager?.glyphRange(for: outputTextView.textContainer!).upperBound
        let glyphRect = outputTextView.layoutManager?.boundingRect(forGlyphRange: NSMakeRange(glyphLowerBound, glyphUpperBound!-glyphLowerBound), in: outputTextView.textContainer!)
        let area = NSTrackingArea.init(rect: CGRect(origin: (glyphRect?.origin)!,size:glyphRect!.size), options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: ["Position": position])
        outputTextView.addTrackingArea(area)
        glyphLowerBound = glyphUpperBound!
    }
    
    override func mouseEntered(with event: NSEvent) {
        let mouseHoverPosition = event.trackingArea?.userInfo!["Position"] as! Int
        showInfoPopover(morphemeRect: (event.trackingArea?.rect)!,position: mouseHoverPosition)
        print("Entered")
    }
    
    override func mouseExited(with event: NSEvent) {
        let mouseHoverStopPosition = event.trackingArea?.userInfo!["Position"] as! Int
        currentInfoPopover[mouseHoverStopPosition]!.close()
        print("Exited")
    }
    
    func showInfoPopover(morphemeRect: NSRect, position: Int) {
        let infoPopover = createInfoPopover(position:position)
        infoPopover!.show(relativeTo: morphemeRect, of: outputTextView, preferredEdge: NSRectEdge.minY)
        currentInfoPopover[position] = infoPopover
    }
    
    func createInfoPopover(position:Int) -> NSPopover? {
        let infoFont = NSFont.systemFont(ofSize: 18)
        let attributeMorpheme: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:infoFont,
                                                                  NSAttributedString.Key.foregroundColor:
                                                                    NSColor.white]
        let stringMorpheme = NSAttributedString(string: (textKRPartOfSpeech?.posDict[position]?.morph)! + " ",attributes: attributeMorpheme)
        let attributesPOS: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:infoFont,
                                                          NSAttributedString.Key.foregroundColor:
                                                            textKRPartOfSpeech!.posDict[position]!.color!]
        let stringPOS = NSAttributedString(string: "(" + (textKRPartOfSpeech?.posDict[position]?.pos)! + ")",attributes:attributesPOS)
        
        
        let infoPopover = NSPopover()
        let infoPopoverViewController = NSViewController()
        infoPopoverViewController.view = NSView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(400), height: CGFloat(200)))
        infoPopover.appearance = NSAppearance(named: .vibrantDark)
        infoPopover.contentViewController = infoPopoverViewController
        infoPopover.contentSize = infoPopoverViewController.view.frame.size
        infoPopover.behavior = .applicationDefined
        infoPopover.animates = false
        
        let informationTextView = NSTextView(frame: infoPopoverViewController.view.frame)
        informationTextView.textStorage?.append(stringMorpheme)
        informationTextView.textStorage?.append(stringPOS)
        informationTextView.backgroundColor = NSColor.clear
        informationTextView.isSelectable = false
        informationTextView.isEditable = false
        infoPopover.contentViewController!.view.addSubview(informationTextView)
        
        return infoPopover
    }
    
    func clearOutputTextView() {
        for popover in currentInfoPopover.values {
            popover.close()
        }
        currentInfoPopover.removeAll()
        
        for trackingArea in outputTextView.trackingAreas {
            outputTextView.removeTrackingArea(trackingArea)
        }
        
        outputTextView.textStorage?.deleteCharacters(in: NSMakeRange(0, (outputTextView.textStorage?.string.count)!))
    }
}
