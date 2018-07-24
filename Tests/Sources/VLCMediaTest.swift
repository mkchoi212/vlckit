/*****************************************************************************
 * VLCMediaTest.swift
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

class VLCMediaTest: XCTestCase {
    func testCodecNameForFourCC() {
        let tests: [(input: String, fourcc: UInt32, expected: String)] = [
            (VLCMediaTracksInformationTypeAudio, 0x414B4D53, "Smacker audio"),
            (VLCMediaTracksInformationTypeVideo, 0x32564933, "3ivx MPEG-4 Video"),
            (VLCMediaTracksInformationTypeText, 0x37324353, "SCTE-27 subtitles"),
            (VLCMediaTracksInformationTypeUnknown, 0x37324353, "SCTE-27 subtitles"),
            ("", 0x0, "")
        ]
        
        for (input, fourcc, expected) in tests {
            let actual = VLCMedia.codecName(forFourCC: fourcc, trackType: input)
            XCTAssertEqual(expected, actual, input)
        }
    }
    
    func testInitWithUrl() {
        let tests = [
            "sftp://dummypath.mov",
            "smb://dummypath.mkv",
            "http://www.x.com/我们走吧.mp3".encodeURL(),
            "smb://server/가즈아.mp3".encodeURL(),
            "smb://server/media file.mp3".encodeURL()
        ]
        
        for path in tests {
            let media = VLCMedia(url: URL(string: path)!)
            XCTAssertEqual(media.url.absoluteString, path)
            media.verify(type: .file)
        }
    }
    
    func testInitWithPath() {
        // TODO: failure case?
        let tests = [Video.test1, Video.test2, Video.test3, Video.test4]
        
        for test in tests {
            let media = VLCMedia(path: test.path)
            media.verify(type: .file)
        }
    }
    
    func testInitWithNode() {
        // TODO: failure case?
        let tests = ["foo", "bar", ""]
        
        for name in tests {
            let media = VLCMedia(asNodeWithName: name)
            XCTAssertEqual(media.mediaType, .unknown)
            XCTAssertEqual(media.url.absoluteString, "vlc://nop")
        }
    }
    
    func testMediaType() {
        // TODO: more cases
        let tests: [(path: String, expected: VLCMediaType)]  = [
            ("file", .file),
        ]
        
        for (path, expected) in tests {
            let media = VLCMedia(path: path)
            XCTAssertEqual(media.mediaType, expected)
        }
    }
    
    func testDescription() {
        let tests = [
            Video.test1,
            Video.test2,
            Video.test3,
            Video.invalid
        ]
        
        guard let regex = try? NSRegularExpression(pattern: "<VLCMedia 0x[0-9a-z]{8,}>, md: 0x[0-9a-z]{8,}, url: \\S*") else {
            XCTFail("Invalid VLCMedia description test regex")
            return
        }
        
        for video in tests {
            let media = video.media
            let description = media.description
            let hits = regex.matches(in: description, range: NSRange(description.startIndex..., in: description))
            XCTAssertEqual(hits.count, 1)
        }
    }
    
    func testCompare() {
        let left = VLCMedia(path: "file")
        let tests: [(right: VLCMedia?, expected: ComparisonResult)] = [
            (left, .orderedSame),
            (VLCMedia(path: "FILE"), .orderedAscending),
            (nil, .orderedDescending)
        ]

        for (right, expected) in tests {
            XCTAssertEqual(left.compare(right), expected)
        }
    }
    
    func testLength() {
        let tests: [(video: Video, expected: VLCTime)] = [
            (Video.test1, VLCTime(int: 4758)),
            (Video.test2, VLCTime(int: 4000)),
            (Video.test3, VLCTime(int: 4788)),
            (Video.test4, VLCTime(int: 3522)),
            (Video.invalid, VLCTime(int: 0))
        ]
        
        for (video, expected) in tests {
            let media = video.media
            let expection = self.expectation(description: "mediaDidFinishParsing called")
            let delegate = MockMediaDelegate(parseExpectation: expection)
            media.delegate = delegate
            
            media.parse(withOptions: VLCMediaParsingOptions(VLCMediaParseLocal))
            waitForExpectations(timeout: 5) { err in
                XCTAssertNil(err)
                XCTAssertEqual(media.length.intValue, expected.intValue)
            }
        }
    }
    
    func testLengthWaitUntilDate() {
        let tests: [(path: String, timeout: Double, expected: String)] = [
            (Video.test1.path, -1, "--:--"),
            (Video.test2.path, 5, "00:04"),
            (Video.test3.path, 5, "00:04"),
            (Video.test4.path, 5, "00:03"),
        ]
        
        for (path, timeout, expected) in tests {
            let media = VLCMedia(path: path)
            media.parse(withOptions: VLCMediaParsingOptions(VLCMediaParseLocal))
            let time = media.lengthWait(until: Date(timeIntervalSinceNow: timeout))
            XCTAssertEqual(time.description, expected.description)
        }
    }
    
    func testParseWithOptions() {
        let tests: [(video: Video, mode: Int, expected: VLCMediaParsedStatus)] = [
            // shouldn't this be skipped?
            (Video.test1, VLCMediaParseNetwork, .done),
            (Video.test1, VLCMediaParseLocal, .done),
            (Video.test2, VLCMediaParseLocal, .done),
            (Video.invalid, VLCMediaParseNetwork, .failed),
        ]

        for (video, mode, expected) in tests {
            let media = video.media
            let result = media.parse(withOptions: VLCMediaParsingOptions(mode))
            let expectation = keyValueObservingExpectation(for: media, keyPath: "parsedStatus", expectedValue: expected.rawValue)
            wait(for: [expectation], timeout: 5)
            XCTAssertEqual(result, 0)
        }
    }
    
    func testParseWithOptionsTimeout() {
        let tests: [(media: VLCMedia, mode: Int, timeout: Double, expected: VLCMediaParsedStatus)] = [
            (Video.test1.media, VLCMediaParseLocal, 10, .done),
            (Video.test2.media, VLCMediaParseLocal, 10, .done),
            (VLCMedia(url: URL(string: "https://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_50mb.mp4")!), VLCMediaParseNetwork, 1, .timeout),
            (Video.invalid.media, VLCMediaParseNetwork, 5, .failed),
        ]

        for (media, mode, timeout, expected) in tests {
            media.parse(withOptions: VLCMediaParsingOptions(mode), timeout: Int32(timeout))
            let parsed = keyValueObservingExpectation(for: media, keyPath: "parsedStatus", expectedValue: expected.rawValue)
            wait(for: [parsed], timeout: abs(timeout))
            XCTAssertEqual(media.parsedStatus, expected)
        }
    }
    
    func testSetMetaData() {
        let test: [(key: String, data: String, ok: Bool)] = [
            (VLCMetaInformationURL, "https://foobar", true),
            (VLCMetaInformationDate, "1970/1/1", true),
            ("invalid meta", "foo", false)
        ]

        for (key, data, ok) in test {
            let media = VLCMedia(path: "file")
            
            ObjcRuntime.try({
                media.setMetadata(data, forKey: key)
                XCTAssertTrue(media.saveMetadata)
                XCTAssertEqual(media.metadata(forKey: key), data)
            }, catch: { exception in
                XCTAssertFalse(ok)
            }, finally: nil)
        }
    }
    
    func testParsedStatus() {
        let media = VLCMedia(path: "file")
        XCTAssertEqual(media.parsedStatus, .init)
        XCTAssertFalse(media.isParsed)
        
        media.lengthWait(until: Date(timeIntervalSinceNow: 20))
        XCTAssertEqual(media.parsedStatus, .failed)
        XCTAssertTrue(media.isParsed)
    }
    
    func testAddOptions() {
        // how do you test this?
        let media = VLCMedia(path: Video.test1.path)
        media.addOptions(["foo": "bar"])
    }
}

extension VLCMedia {
    func verify(type: VLCMediaType,file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(metaDictionary, file: file, line: line)
        XCTAssertNotNil(subitems, file: file, line: line)
        XCTAssertNotNil(url, file: file, line: line)
        XCTAssertEqual(mediaType, type, file: file, line: line)
        XCTAssertEqual(state, VLCMediaState.nothingSpecial, file: file, line: line)
    }
}

extension String {
    func encodeURL() -> String {
        guard let encoded = addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            XCTFail("Failed to encode URL \(self)")
            return ""
        }
        return encoded
    }
}
