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

    var inputKR: String!
    var task = Process()
    var pipe = Pipe()
    
    struct partOfSpeechTag {
        var morph: String
        var pos: String
        var color: NSColor?
        
        init(morph: String, pos: String) {
            self.morph = morph
            self.pos = pos
            tagColor()
        }
        
        static func == (lhs: partOfSpeechTag, rhs: partOfSpeechTag) -> Bool {
            return lhs.morph == rhs.morph && lhs.pos == rhs.pos && lhs.color == rhs.color
        }
        
        mutating func tagColor() {
            switch pos {
            case "Verb":
                color = NSColor.blue
            case "Josa":
                color = NSColor.red
            case "Noun":
                color = NSColor.purple
            default:
                color = NSColor.white
            }
        }
        
    }
    
    var posDict: [Int:partOfSpeechTag] = [:]
    
    init?(input:String) {
        inputKR = input
        parseInputForPOS()
    }
    
    func parseInputForPOS() {
        let filePathURL = Bundle.main.url(forResource: "KonlpyParser", withExtension: "py")
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
