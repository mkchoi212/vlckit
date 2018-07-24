/*****************************************************************************
 * VLCMediaListTest.swift
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

class VLCMediaListTest: XCTestCase {
    
    func testInit() throws {
        let videos = [Video.test1, Video.test2, Video.test3]
        let source = videos.map{ $0.media }
        
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList(array: source))
        XCTAssertEqual(mediaList.count, source.count)
    }
    
    func testAddMedia() throws {
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList())
        
        let videos = [Video.test1, Video.test1,Video.test2, Video.test3]
        let source = videos.map{ $0.media }
        
        for (idx, media) in source.enumerated() {
            let newIdx = mediaList.add(media)
            XCTAssertEqual(Int(newIdx), idx)
            XCTAssertEqual(mediaList.count, idx + 1)
            XCTAssertEqual(mediaList.media(at: UInt(idx)), media)
        }
    }
    
    func testInsertMedia() throws {
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList(array: nil))
        let videos = [Video.test1, Video.test2, Video.test3, Video.test4]
        let source = videos.map{ $0.media }
        let insertOrder = [0, 1, 0, 2]
        let test = zip(insertOrder, source)
        
        for (i, (insertIdx, media)) in test.enumerated() {
            mediaList.insert(media, at: UInt(insertIdx))
            XCTAssertEqual(mediaList.index(of: media), insertIdx)
            XCTAssertEqual(mediaList.count, i + 1)
        }
    }
    
    func testDescription() throws {
        let videos = [Video.test1, Video.test2, Video.test3]
        let source = videos.map{ $0.media }
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList(array: source))
       
        guard let regex = try? NSRegularExpression(pattern: "<VLCMediaList 0x[0-9a-z]{8,}> \\{\\n(<VLCMedia 0x[0-9a-z]{8,}>, md: 0x[0-9a-z]{8,}, url: \\S*\\n){0,}\\}") else {
            XCTFail("Invalid VLCMediaList description test regex")
            return
        }
        let description = mediaList.description
        let hits = regex.matches(in: description, range: NSRange(description.startIndex..., in: description))
        XCTAssertEqual(hits.count, 1)
    }
    
    func testCountOfMedia() throws {
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList())
        let videos = [Video.test1, Video.test2, Video.test3]
        
        for (idx, video) in videos.enumerated() {
            let media = video.media
            mediaList.add(media)
            XCTAssertEqual(mediaList.count, idx + 1)
        }
    }
}
