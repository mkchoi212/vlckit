/*****************************************************************************
 * VLCAudioTest.swift
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

class VLCAudioTest: XCTestCase {
    
    let step = 6
    let min = 0
    let max = 200
    
    func testIsMuted() throws {
        let player = VLCMediaPlayer()
        let audio = try XCTAssertNotNilAndUnwrap(player.audio)
        XCTAssertFalse(audio.isMuted)
        
        audio.isMuted = true
        XCTAssertTrue(audio.isMuted)
        
        audio.isMuted = false
        XCTAssertFalse(audio.isMuted)
        
        audio.setMute(true)
        XCTAssertTrue(audio.isMuted)
        
        audio.setMute(false)
        XCTAssertFalse(audio.isMuted)
    }
    
    func testPassThrough() throws {
        let player = VLCMediaPlayer()
        let audio = try XCTAssertNotNilAndUnwrap(player.audio)
        
        XCTAssertFalse(audio.passthrough)
        
        audio.passthrough = true
        XCTAssertTrue(audio.passthrough)
        
        audio.passthrough = false
        XCTAssertFalse(audio.passthrough)
    }
    
    func testVolumeDown() throws {
        let player = VLCMediaPlayer(options: nil)
        let audio = try XCTAssertNotNilAndUnwrap(player?.audio)
        audio.volume = 9000
        
        for i in (1...50) {
            audio.volumeDown()
            
            if i * step >= max {
                XCTAssertEqual(audio.volume, 0)
            } else {
                XCTAssertEqual(audio.volume, Int32(max - (i * step)))
            }
        }
    
        XCTAssertEqual(audio.volume, 0)
    }
    
    func testVolumeUp() throws {
        let player = VLCMediaPlayer()
        let audio = try XCTAssertNotNilAndUnwrap(player.audio)
        audio.volume = Int32(-9000)
        
        for i in (1...50) {
            audio.volumeUp()
            
            if i * step >= max {
                XCTAssertEqual(audio.volume, Int32(max))
            } else {
                XCTAssertEqual(audio.volume, Int32(i * step))
            }
        }
        
        XCTAssertEqual(audio.volume, Int32(max))
    }
    
    func testSetVolume() throws {
        let player = VLCMediaPlayer()
        let audio = try XCTAssertNotNilAndUnwrap(player.audio)
        
        let tests: [(target: Int, expected: Int)] = [
            (min, min),
            (min - 100, min),
            (50, 50),
            (100, 100),
            (max, max),
            (max + 100, max)
        ]
        
        for (target, expected) in tests {
            audio.volume = Int32(target)
            XCTAssertEqual(audio.volume, Int32(expected))
        }
    }
}
