/*****************************************************************************
 * VLCLibraryTest.swift
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

class VLCLibraryTest: XCTestCase {
    func testSharedLibrary() {
        XCTAssertNotNil(VLCLibrary.shared())
        XCTAssertNotNil(VLCLibrary.shared()?.instance)
    }
    
    func testInitWithOptions() throws {
        let tests = [
            ["--no-video-title-show", "--verbose=4"],
            ["invalid_flag", ""],
            [""]
        ]
        
        for option in tests {
            let library = try XCTAssertNotNilAndUnwrap(VLCLibrary(options: option))
            XCTAssertNotEqual(library, VLCLibrary.shared())
            XCTAssertNotNil(library.instance)
            XCTAssertNotEqual(library.instance, VLCLibrary.shared().instance)
        }
    }
    
    func testDefaultOptions() throws {
        let expected = [
            "--play-and-pause",
            "--no-color",
            "--no-video-title-show",
            "--verbose=4",
            "--no-sout-keep",
            "--vout=macosx",
            "--text-renderer=freetype",
            "--extraintf=macosx_dialog_provider",
            "--audio-resampler=soxr"
        ]
        
        let defaultParams = try XCTAssertNotNilAndUnwrap(UserDefaults.standard.object(forKey: "VLCParams") as? [String])
        XCTAssertEqual(defaultParams, expected)
    }
    
    func testDebugLoggingLevel() throws {
        let library = try XCTAssertNotNilAndUnwrap(VLCLibrary.shared())
        XCTAssertEqual(library.debugLoggingLevel, 0)
        for i in 0...50 {
            library.debugLoggingLevel = Int32(i)
            XCTAssertEqual(library.debugLoggingLevel, Int32(i))
        }
    }
    
    func testDebugLogging() throws {
        let library = try XCTAssertNotNilAndUnwrap(VLCLibrary.shared())
        XCTAssertFalse(library.debugLogging)
        
        library.debugLogging = true
        let yay = expectation(for: NSPredicate(format: "debugLogging == true"), evaluatedWith: library, handler: nil)
        wait(for: [yay], timeout: 20)
        XCTAssertTrue(library.debugLogging)
        
        library.debugLogging = false
        XCTAssertFalse(library.debugLogging)
    }
    
    func testLibraryDescription() throws {
        let library = try XCTAssertNotNilAndUnwrap(VLCLibrary.shared())
        
        XCTAssert(library.version.count > 1)
        XCTAssert(library.compiler.count > 1)
        XCTAssert(library.changeset.count > 1)
    }
}
