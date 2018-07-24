/*****************************************************************************
 * VLCMediaListDelegateTest.swift
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

final class MockMediaListDelegate: NSObject, VLCMediaListDelegate {
    var addedIdx: Int?
    var removedIdx: Int?
    var removedExpectation: XCTestExpectation?
    var addedExpectation: XCTestExpectation?
    
    func mediaList(_ aMediaList: VLCMediaList!, mediaRemovedAt index: UInt) {
        removedIdx = Int(index)
        removedExpectation?.fulfill()
    }
    
    func mediaList(_ aMediaList: VLCMediaList!, mediaAdded media: VLCMedia!, at index: UInt) {
        addedIdx = Int(index)
        addedExpectation?.fulfill()
    }
}

class VLCMediaListDelegateTest: XCTestCase {
    
    // MARK: Delegate callbacks
    func testMediaRemovedAt() throws {
        let videos = [Video.test1, Video.test2, Video.test3, Video.test4]
        let source = videos.map{ VLCMedia(path: $0.path) }
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList(array: source))
        
        let delegate = MockMediaListDelegate()
        mediaList.delegate = delegate
        
        for idx in 0..<videos.count {
            let delegateCalled = self.expectation(description: "delegate::mediaRemovedAt called")
            delegate.removedExpectation = delegateCalled
            
            let target = videos.count - (idx + 1)
            mediaList.removeMedia(at: UInt(target))
            wait(for: [delegateCalled], timeout: 10)
            
            XCTAssertEqual(delegate.removedIdx, target)
            XCTAssertEqual(mediaList.count, target)
        }
    }
    
    func testMediaAdded() throws {
        let videos = [Video.test1, Video.test2, Video.test3]
        let source = videos.map{ VLCMedia(path: $0.path) }
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList())
        
        let delegate = MockMediaListDelegate()
        mediaList.delegate = delegate
        
        for (idx, media) in source.enumerated() {
            let delegateCalled = self.expectation(description: "delegate::mediaAdded called")
            delegate.addedExpectation = delegateCalled
            
            let insertedIdx = mediaList.add(media)
            XCTAssertEqual(Int(insertedIdx), idx)
            XCTAssertEqual(mediaList.count, idx + 1)
            
            wait(for: [delegateCalled], timeout: 5)
            XCTAssertEqual(delegate.addedIdx, idx)
        }
    }
    
    // MARK: KVO
    
    func testAddMedia() throws {
        let videos = [Video.test1, Video.test2, Video.test3]
        let source = videos.map{ VLCMedia(path: $0.path) }
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList())
        
        for (idx, media) in source.enumerated() {
            let observerCalled = keyValueObservingExpectation(for: mediaList, keyPath: "media") { (obj, hist) -> Bool in
                guard let mediaList = (obj as? VLCMediaList) else { return false }
                return mediaList.count == idx + 1
            }
            mediaList.add(media)
            wait(for: [observerCalled], timeout: 5)
        }
    }
    
    func testRemoveMedia() throws {
        let tests: [(deleteIdx: UInt, expected: [Int], count: Int, ok: Bool)] = [
            (3, [0,1,2,-1,3], 4, true),
            (9, [0,1,2,-1,3], 4, false),
            (1, [0,-1,1,-1,2], 3, true),
            (0, [-1,-1,0,-1,1], 2, true),
            (1, [-1,-1,0,-1,-1], 1, true),
            (0, [-1,-1,-1,-1,-1], 0, true)
        ]
        
        let videos = [Video.test1, Video.test1, Video.test2, Video.test3, Video.test4]
        let source = videos.map{ VLCMedia(path: $0.path) }
        let mediaList = try XCTAssertNotNilAndUnwrap(VLCMediaList(array: source))
        
        for test in tests {
            ObjcRuntime.try({
                mediaList.removeMedia(at: test.deleteIdx)

                let observerCalled = self.keyValueObservingExpectation(for: mediaList, keyPath: "media") { (obj, hist) -> Bool in
                    guard let mediaList = (obj as? VLCMediaList) else { return false }
                    return mediaList.count == test.count
                }
                self.wait(for: [observerCalled], timeout: 5)

                let order = source.map { mediaList.index(of: $0) }
                XCTAssertEqual(order, test.expected)
                XCTAssertEqual(mediaList.count, test.count)
            }, catch: { exception in
                XCTAssertEqual(exception?.name.rawValue, "NSRangeException")
                XCTAssertFalse(test.ok)
            }, finally: nil)
        }
    }
}
