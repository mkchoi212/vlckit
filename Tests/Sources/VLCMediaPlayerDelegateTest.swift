/*****************************************************************************
 * VLCMediaPlayerDelegateTest.swift
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

class MockMediaPlayerDelegate: NSObject, VLCMediaPlayerDelegate {
    
    let callback: (VLCMediaPlayer) -> ()
    
    init(callback: @escaping (VLCMediaPlayer) -> ()) {
        self.callback = callback
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        guard let mediaPlayer = aNotification.object as? VLCMediaPlayer else {
            XCTFail("VLCMediaPlayer is not passed to mejdiaPlayerStateChanged")
            return
        }
        
        callback(mediaPlayer)
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        guard let mediaPlayer = aNotification.object as? VLCMediaPlayer else {
            XCTFail("VLCMediaPlayer is not passed to mediaPlayerTimeChanged")
            return
        }
        
        callback(mediaPlayer)
    }
}

class VLCMediaPlayerDelegateTest: XCTestCase {
    
    func testMediaPlayerTimeChanged() throws {
        let view = VLCVideoView(frame: .zero)
        let mediaPlayer = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(videoView: view))
        mediaPlayer.media = Video.test1.media
        
        let isPlaying = expectation(description: "mediaPlayerTimeChanged called")
        let delegate = MockMediaPlayerDelegate { player in
        }
        mediaPlayer.delegate = delegate
        
        XCTAssertEqual(mediaPlayer.state, .stopped)
        
        mediaPlayer.play()
        wait(for: [isPlaying], timeout: STANDARD_TIME_OUT)
    }
    
    // TODO?? FREEZE?
    func testMediaPlayerStateChanged() throws {
        let view = VLCVideoView(frame: .zero)
        let mediaPlayer = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(videoView: view))
        mediaPlayer.media = Video.test1.media

        let isPlaying = expectation(description: "mediaPlayerStateChanged to .playing")
        let delegate = MockMediaPlayerDelegate { player in
            if player.state == .playing {
                isPlaying.fulfill()
            }
        }
        mediaPlayer.delegate = delegate

        XCTAssertEqual(mediaPlayer.state, .stopped)
        
        mediaPlayer.play()
        wait(for: [isPlaying], timeout: STANDARD_TIME_OUT)
    }
}
