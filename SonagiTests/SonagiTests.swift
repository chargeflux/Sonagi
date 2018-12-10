//
//  SonagiTests.swift
//  SonagiTests
//
//  Created by chargeflux on 12/2/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import XCTest
@testable import Sonagi

class SonagiTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    typealias partOfSpeechTag = PartOfSpeech.partOfSpeechTag

    func testSonagiParserPOS() {
        let pos = Sonagi.PartOfSpeech(input: "저는 내년에 한국에 갈 거예요")
        let samplePartOfSpeechTag = partOfSpeechTag.init(morph: "갈다", pos: "Verb")
        let correctPosDict: [Int:partOfSpeechTag] = [6: partOfSpeechTag.init(morph: "갈다", pos: "Verb"),
                                                     3: partOfSpeechTag.init(morph: "에", pos: "Josa"),
                                                     7: partOfSpeechTag.init(morph: "거", pos: "Noun"),
                                                     8: partOfSpeechTag.init(morph: "예요", pos: "Josa"),
                                                     0: partOfSpeechTag.init(morph: "저", pos: "Noun"),
                                                     1: partOfSpeechTag.init(morph: "는", pos: "Josa"),
                                                     2: partOfSpeechTag.init(morph: "내년", pos: "Noun"),
                                                     4: partOfSpeechTag.init(morph: "한국", pos: "Noun"),
                                                     5: partOfSpeechTag.init(morph: "에", pos: "Josa")]
        posDictTestIterator(testPosDict: pos!, expectedPosDict: correctPosDict, funcName: "testSonagiParserPOS", testNumber: 1)
        
        // Check for member count for partOfSpeechTag struct
        let partOfSpeechTagMirror = Mirror(reflecting: samplePartOfSpeechTag)
        XCTAssertEqual(partOfSpeechTagMirror.children.count, 3, "The member count of partOfSpeechTag struct has changed; update equality operator and add test cases for equality")
    }
    
    func testSonagiParserPOSInput() {
        
        let posV1 = Sonagi.PartOfSpeech(input: "/")
        let correctPosDictV1: [Int:partOfSpeechTag] = [0: partOfSpeechTag.init(morph: "/", pos: "Punctuation")]
        posDictTestIterator(testPosDict: posV1!, expectedPosDict: correctPosDictV1, funcName: "testSonagiParserPOSInput", testNumber: 1)
        
        let posV2 = Sonagi.PartOfSpeech(input: "///////////")
        let correctPosDictV2: [Int:partOfSpeechTag] = [0: partOfSpeechTag.init(morph: "///////////", pos: "Punctuation")]
        posDictTestIterator(testPosDict: posV2!, expectedPosDict: correctPosDictV2, funcName: "testSonagiParserPOSInput", testNumber: 2)
        
        let posV3 = Sonagi.PartOfSpeech(input: "//예요/한국////거//")
        let correctPosDictV3: [Int:partOfSpeechTag] = [0: partOfSpeechTag.init(morph: "//", pos: "Punctuation"),
                                                       1: partOfSpeechTag.init(morph: "예요", pos: "Josa"),
                                                       2: partOfSpeechTag.init(morph: "/", pos: "Punctuation"),
                                                       3: partOfSpeechTag.init(morph: "한국", pos: "Noun"),
                                                       4: partOfSpeechTag.init(morph: "////", pos: "Punctuation"),
                                                       5: partOfSpeechTag.init(morph: "거", pos: "Noun"),
                                                       6: partOfSpeechTag.init(morph: "//", pos: "Punctuation")]
        posDictTestIterator(testPosDict: posV3!, expectedPosDict: correctPosDictV3, funcName: "testSonagiParserPOSInput", testNumber: 3)
        
        let posV4 = Sonagi.PartOfSpeech(input: "")
        let correctPosDictV4: [Int:partOfSpeechTag]? = [:]
        posDictTestIterator(testPosDict: posV4!, expectedPosDict: correctPosDictV4!, funcName: "testSonagiParserPOSInput", testNumber: 4)
        
        let posV5 = Sonagi.PartOfSpeech(input: " ")
        let correctPosDictV5: [Int:partOfSpeechTag]? = [:]
        posDictTestIterator(testPosDict: posV5!, expectedPosDict: correctPosDictV5!, funcName: "testSonagiParserPOSInput", testNumber: 5)
        
        let posV6 = Sonagi.PartOfSpeech(input: "  예요")
        let correctPosDictV6: [Int:partOfSpeechTag]? = [0: partOfSpeechTag.init(morph: "예요", pos: "Josa")]
        posDictTestIterator(testPosDict: posV6!, expectedPosDict: correctPosDictV6!, funcName: "testSonagiParserPOSInput", testNumber: 6)
        
    }
    
    func posDictTestIterator(testPosDict:PartOfSpeech, expectedPosDict: [Int:partOfSpeechTag], funcName: String, testNumber: Int) {
        for key in expectedPosDict.keys {
            // Check for equality in partOfSpeechTag struct values
            XCTAssert(expectedPosDict[key]!.morph == testPosDict.posDict[key]!.morph, "Incorrect morpheme (Expected: \(expectedPosDict[key]!.morph),Test: \(testPosDict.posDict[key]!.morph)) in \(funcName): Test #\(testNumber)")
            XCTAssert(expectedPosDict[key]!.pos == testPosDict.posDict[key]!.pos, "Incorrect detection of part of speech (Expected: \(expectedPosDict[key]!.pos), Test: \(testPosDict.posDict[key]!.pos)) in \(funcName): Test #\(testNumber)")
            XCTAssert(expectedPosDict[key]!.color == testPosDict.posDict[key]!.color, "Incorrect color (Expected: \(expectedPosDict[key]!.color!), Test: \(testPosDict.posDict[key]!.color!)) in \(funcName): Test #\(testNumber)")
            
            // Verify Equatable func override
            XCTAssertTrue(expectedPosDict[key]! == (testPosDict.posDict[key])!, "POS tagging is incorrect")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
