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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
        setTracking()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setText() {
        let font = NSFont(name: "NanumSquareR", size: 32) ?? NSFont.systemFont(ofSize: 32)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:font,
                          NSAttributedString.Key.foregroundColor:NSColor.white]
        text = NSAttributedString(string: "저는 내년에 한국에 갈 거예요",attributes:attributes)
        outputTextView.textStorage?.append(text!)
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

