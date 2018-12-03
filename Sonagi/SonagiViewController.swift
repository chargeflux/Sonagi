//
//  ViewController.swift
//  Sonagi
//
//  Created by chargeflux on 12/2/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa

class SonagiViewController: NSViewController {
    
    @IBOutlet var outputTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
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
        let text = NSAttributedString(string: "저는 내년에 한국에 갈 거예요",attributes:attributes)
        self.outputTextView.textStorage?.append(text)
    }

}

