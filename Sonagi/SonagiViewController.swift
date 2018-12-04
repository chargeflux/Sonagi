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
    
    var text: NSAttributedString?
    
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
        for key in input.posDict.keys.sorted() {
            let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:font,
                                                              NSAttributedString.Key.foregroundColor:
                                                                input.posDict[key]!.color!]
            text = NSAttributedString(string: input.posDict[key]!.morph,attributes:attributes)
            outputTextView.textStorage?.append(text!)
        }
    }
    
    func setTracking() {
        let area = NSTrackingArea.init(rect: CGRect(origin: outputTextView.textContainerOrigin,size:(text?.size())!), options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
        outputTextView.addTrackingArea(area)
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("Entered")
    }
    
    override func mouseExited(with event: NSEvent) {
        print("Exited")
    }
}

