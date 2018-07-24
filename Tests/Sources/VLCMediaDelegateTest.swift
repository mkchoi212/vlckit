/*****************************************************************************
 * VLCMediaDelegateTest.swift
 *****************************************************************************
 * Copyright (C) 2018 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Mike JS. Choi <mkchoi212 # icloud.com>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

import XCTest

final class MockMediaDelegate: NSObject, VLCMediaDelegate {
    var metaExpectation: XCTestExpectation?
    var parseExpectation: XCTestExpectation?
    
    init(metaExpectation: XCTestExpectation) {
        super.init()
        self.metaExpectation = metaExpectation
    }
    
    init(parseExpectation: XCTestExpectation) {
        super.init()
        self.parseExpectation = parseExpectation
    }
    
    func mediaMetaDataDidChange(_ aMedia: VLCMedia) {
        metaExpectation?.fulfill()
    }
    
    func mediaDidFinishParsing(_ aMedia: VLCMedia) {
        parseExpectation?.fulfill()
    }
}

class VLCMediaDelegateTest: XCTestCase {
    func testMediaMetaChanged() {
        let expectedMeta: [String : String] = [
            VLCMetaInformationAlbum : "Electric Ladyland",
            VLCMetaInformationArtist : "Jimi Hendrix",
            VLCMetaInformationGenre : "Rock",
            VLCMetaInformationTitle : "All Along the Watchtower",
            VLCMetaInformationDiscNumber : "1"
        ]
        
        let media = VLCMedia(path: "file")
        let delegateCalled = self.expectation(description: "metaDataDidChanged called")
        let delegate = MockMediaDelegate(metaExpectation: delegateCalled)
        media.delegate = delegate
        
        for (key, value) in expectedMeta {
            media.setMetadata(value, forKey: key)
        }
        
        XCTAssertTrue(media.saveMetadata)
        
        wait(for: [delegateCalled], timeout: STANDARD_TIME_OUT)
        XCTAssertEqual(media.metaDictionary as NSObject, expectedMeta as NSObject)
    }
    
    func testParsedChanged() {
        let tests: [(video: Video, expected: VLCMediaParsedStatus)] = [
            (Video.test1, .done),
            (Video.test2, .done),
            (Video.test3, .done),
            (Video.test4, .done),
            (Video.invalid, .failed)
        ]
        
        for (video, expected) in tests {
            let media = video.media
            let delegateCalled = self.expectation(description: "mediaDidFinishParsing called")
            let delegate = MockMediaDelegate(parseExpectation: delegateCalled)
            media.delegate = delegate

            media.parse(withOptions: VLCMediaParsingOptions(VLCMediaParseLocal))
            wait(for: [delegateCalled], timeout: STANDARD_TIME_OUT)
            
            XCTAssertEqual(media.parsedStatus, expected)
        }
    }
    
    func testParsedWithMetaData() {
        let tests: [(video: Video, ok: Bool)] = [
            (Video.test1, true),
            (Video.test2, true),
            (Video.test3, true),
            (Video.test4, true),
            (Video.invalid, false)
        ]
        
        for (video, ok) in tests {
            let media = VLCMedia(path: video.path)
            let delegateCalled = self.expectation(description: "mediaDidFinishParsing called")
            let delegate = MockMediaDelegate(parseExpectation: delegateCalled)
            media.delegate = delegate
            
            media.parse(withOptions: VLCMediaParsingOptions(VLCMediaParseLocal))
            wait(for: [delegateCalled], timeout: STANDARD_TIME_OUT)
            
            if ok {
                XCTAssertEqual(video.meta as NSObject, media.metaDictionary as NSObject)
            }
            XCTAssertEqual(media.metadata(forKey: VLCMetaInformationTitle), video.title)
        }
    }
}
