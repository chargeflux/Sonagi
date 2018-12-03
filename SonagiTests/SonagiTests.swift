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
        let correctPosDict: [Int:(morph:String,pos:String)] = [6: (morph: "갈다", pos: "Verb"), 3: (morph: "에", pos: "Josa"), 7: (morph: "거", pos: "Noun"), 8: (morph: "예요", pos: "Josa"), 0: (morph: "저", pos: "Noun"), 1: (morph: "는", pos: "Josa"), 2: (morph: "내년", pos: "Noun"), 4: (morph: "한국", pos: "Noun"), 5: (morph: "에", pos: "Josa")]
        for key in correctPosDict.keys {
            XCTAssertTrue(correctPosDict[key]! == (pos?.posDict[key])!, "POS tagging is incorrect")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
