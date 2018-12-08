//
//  SonagiParser.swift
//  Sonagi
//
//  Created by chargeflux on 12/2/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa
import Foundation


class PartOfSpeech {
    /// Holds the part of speech tagging output from Open Korean Text Processor (Okt) for an input string

    var inputKR: String!
    
    struct partOfSpeechTag {
        /// Holds an individual part of speech tag
        
        /// A morpheme/word detected by Okt
        var morph: String
        
        /// The part of speech tag for the detected morpheme
        var pos: String
        
        /// The color associated with the part of speech tag
        var color: NSColor?
        
        init(morph: String, pos: String) {
            /// morph:  A morpheme/word detected by Okt
            /// pos: The part of speech tag for the detected morpheme
            self.morph = morph
            self.pos = pos
            
            /// Determine color for the tag that was set
            tagColor()
        }
        
        static func == (lhs: partOfSpeechTag, rhs: partOfSpeechTag) -> Bool {
            return lhs.morph == rhs.morph && lhs.pos == rhs.pos && lhs.color == rhs.color
        }
        
        mutating func tagColor() {
            switch pos {
            case "Noun":
                color = NSColor(red:0.85, green:0, blue:0.4, alpha:1)
            case "Verb":
                color = NSColor(red:0.2, green:0.385, blue:0.999, alpha:1)
            case "Josa":
                color = NSColor.gray
            case "Adjective":
                color = NSColor(red:0.65, green:0.203, blue:0.707, alpha:1)
            case "Suffix":
                color = NSColor(red:0.3, green:0.749, blue:0.339, alpha:1)
            case "Adverb":
                color = NSColor.blue
            case "Determiner":
                color = NSColor.white
            case "Eomi":
                color = NSColor.orange
            case "PreEomi":
                color = NSColor.orange
            case "Conjunction":
                color = NSColor.orange
            case "Modifier":
                color = NSColor.systemBlue
            case "VerbPrefix":
                color = NSColor.gray
            case "Exclamation":
                color = NSColor.gray
            case "Punctuation":
                color = NSColor.gray
            default:
                color = NSColor.white
            }
        }
        
    }
    
    var posDict: [Int:partOfSpeechTag] = [:]
    
    init?(input:String?) {
        /// input: The input string to be parsed
        guard let inputKR = input
            else {
                return nil
        }
        self.inputKR = inputKR
        parseInputForPOS()
    }
    
    func parseInputForPOS() {
        /// Parse input for part of speech tags
        let filePathURL = Bundle.main.url(forResource: "KonlpyParser", withExtension: "py")
        let task = Process()
        let pipe = Pipe()
        task.executableURL = filePathURL
        task.arguments = ["--type", "pos","--input",inputKR]
        task.standardOutput = pipe
        try! task.run()
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        let out = String(data: data, encoding: String.Encoding.utf8)
        let outArray = out?.components(separatedBy: "\n")
        
        for (index, entry) in outArray!.enumerated() {
            var tempArr = entry.components(separatedBy: "/")
            posDict.updateValue(partOfSpeechTag.init(morph: tempArr[0], pos: tempArr[1]), forKey: index)
        }
    }
}
