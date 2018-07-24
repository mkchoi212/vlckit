/*****************************************************************************
 * VLCMediaPlayerTest.swift
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

class VLCMediaPlayerTest: XCTestCase {
    
    func testMediaStateToString() {
        let tests: [(VLCMediaPlayerState, String)] = [
            (.stopped,   "VLCMediaPlayerStateStopped"),
            (.opening,   "VLCMediaPlayerStateOpening"),
            (.buffering, "VLCMediaPlayerStateBuffering"),
            (.ended,     "VLCMediaPlayerStateEnded"),
            (.error,     "VLCMediaPlayerStateError"),
            (.playing,   "VLCMediaPlayerStatePlaying"),
            (.paused,    "VLCMediaPlayerStatePaused")
        ]
        
        for (state, string) in tests {
            XCTAssertEqual(VLCMediaPlayerStateToString(state), string)
        }
    }
    
    func testLibraryInstance() {
        XCTAssertNotNil(VLCMediaPlayer().libraryInstance)
    }
    
    #if !os(iOS)
    func testInitWithVideoView() throws {
        let view = VLCVideoView(frame: .zero)
        let player = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(videoView: view))
        
        XCTAssertEqual(player.drawable as? VLCVideoView, view)
        XCTAssertEqual(player.time.intValue, 0)
        XCTAssertEqual(player.remainingTime.intValue, 0)
        XCTAssertEqual(player.position, 0.0)
        XCTAssertEqual(player.state, .stopped)
    }
    
    func testInitWithVideoLayer() throws {
        let videoLayer = VLCVideoLayer(layer: CALayer())
        let player = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(videoLayer: videoLayer))
        
        XCTAssertEqual(player.drawable as? VLCVideoLayer, videoLayer)
        XCTAssertEqual(player.time.intValue, 0)
        XCTAssertEqual(player.remainingTime.intValue, 0)
        XCTAssertEqual(player.position, 0.0)
        XCTAssertEqual(player.state, .stopped)
    }
    #endif
    
    func testInitWithOptions() throws {
        let player = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(options: ["foobar"]))
        XCTAssertNotEqual(player.libraryInstance, VLCLibrary.shared())
        XCTAssertEqual(player.time.intValue, 0)
        XCTAssertEqual(player.remainingTime.intValue, 0)
        XCTAssertEqual(player.position, 0.0)
        XCTAssertEqual(player.state, .stopped)
    }
    
    func testInitWithLibVLCInstance() throws {
        //TODO
    }
    
    #if !os(iOS)
    func testSetVideoView() throws {
        let player = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(options: nil))
        let view = VLCVideoView(frame: .zero)
        
        XCTAssertNil(player.drawable)
        
        player.setVideoView(view)
        XCTAssertEqual(player.drawable as? VLCVideoView, view)
    }
    
    func testSetVideoLayer() throws {
        let player = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(options: nil))
        let videoLayer = VLCVideoLayer(layer: CALayer())
        
        XCTAssertNil(player.drawable)
        
        player.setVideoLayer(videoLayer)
        XCTAssertEqual(player.drawable as? VLCVideoLayer, videoLayer)
    }
    #endif
    
    func testPlay() throws {
        let view = VLCVideoView(frame: .zero)
        let mediaPlayer = try XCTAssertNotNilAndUnwrap(VLCMediaPlayer(videoView: view))
        mediaPlayer.media = Video.test1.media
        
        XCTAssertEqual(mediaPlayer.state, .stopped)
        
        let states: [VLCMediaPlayerState] = [.opening, .buffering, .esAdded, .playing]
        let expectations = states.map { keyValueObservingMediaState(for: mediaPlayer, state: $0) }
        
        mediaPlayer.play()
        wait(for: expectations, timeout: STANDARD_TIME_OUT)
    }
}
