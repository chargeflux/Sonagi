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

    func testSonagiParserPOS() {
        let pos = Sonagi.PartOfSpeech(input: "저는 내년에 한국에 갈 거예요")
        
        typealias partOfSpeechTag = PartOfSpeech.partOfSpeechTag
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
        for key in correctPosDict.keys {
            // Check for equality in partOfSpeechTag struct values
            XCTAssertTrue(correctPosDict[key]!.morph == pos?.posDict[key]!.morph,"Incorrect detection of morpheme")
            XCTAssertTrue(correctPosDict[key]!.pos == pos?.posDict[key]!.pos,"Incorrect detection of part of speech")
            XCTAssertTrue(correctPosDict[key]!.color == pos?.posDict[key]!.color,"Incorrect detection of color")
            
            // Verify Equatable func override
            XCTAssertTrue(correctPosDict[key]! == (pos?.posDict[key])!, "POS tagging is incorrect")
        }
        
        // Check for member count for partOfSpeechTag struct
        let partOfSpeechTagMirror = Mirror(reflecting: samplePartOfSpeechTag)
        XCTAssertEqual(partOfSpeechTagMirror.children.count, 3, "The member count of partOfSpeechTag struct has changed; update equality operator and add test cases for equality")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
