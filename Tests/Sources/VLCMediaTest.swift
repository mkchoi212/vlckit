/*****************************************************************************
 * VLCMediaTest.swift
 *****************************************************************************
 * Copyright (C) 2018 Mike JS. Choi
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
            // AKMS
            (VLCMediaTracksInformationTypeAudio, 0x414B4D53, "Smacker audio"),
            // H264
            (VLCMediaTracksInformationTypeVideo, 0x34363248, "H264 - MPEG-4 AVC (part 10)"),
            (VLCMediaTracksInformationTypeUnknown, 0x34363248, "H264 - MPEG-4 AVC (part 10)"),
            (VLCMediaTracksInformationTypeText, 0x0, ""),
            ("", 0x0, "")
        ]
        
        for (input, fourcc, expected) in tests {
            let actual = VLCMedia.codecName(forFourCC: fourcc, trackType: input)
            XCTAssertEqual(expected, actual, input)
        }
    }
}
