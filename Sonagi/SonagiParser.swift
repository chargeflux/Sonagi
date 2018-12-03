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
    var posDict: [Int:(morph:String,pos:String)] = [:]
    
    func parseInputForPOS() {
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/python3")
        let filePath = Bundle.main.url(forResource: "KonlpyParser", withExtension: "py")
        task.arguments = [filePath!.absoluteString,"--type", "pos","--input",inputKR]
        task.standardOutput = pipe
        try? task.run()
        
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        let out = String(data: data, encoding: String.Encoding.utf8)
        
        let outArray = out?.components(separatedBy: "\n")
        
        for (index, entry) in outArray!.enumerated() {
            var tempArr = entry.components(separatedBy: "/")
            posDict.updateValue((morph: tempArr[0], pos: tempArr[1]), forKey: index)
        }
    }
}
