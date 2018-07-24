/*****************************************************************************
 * Video.swift
 *****************************************************************************
 * Copyright (C) 2018 Mike JS. Choi
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

struct Video {
    let name: String
    let type: String
    let meta: [String:String]
    
    static let test1 = Video(
        name: "bird",
        type: "m4v",
        meta: ["trackNumber": "0", "album": "Nature", "title": "bird.m4v", "date": "0", "genre": "Nature", "description": "Bird looking into the abiss"]
    )
    static let test2 = Video(
        name: "bunny",
        type: "avi",
        meta: ["title": "bunny.avi"]
    )
    static let test3 = Video(
        name: "salmon",
        type: "mp4",
        meta: ["trackNumber": "0", "album": "Nature", "title": "salmon.mp4", "description": "Salmon trying to swim upstream", "date": "0", "genre": "Nature"]
    )
    static let test4 = Video(
        name: "sea_lions",
        type: "mov",
        meta: ["description": "Tanning sea lions", "genre": "Nature", "title": "sea_lions.mov"]
    )
    static let invalid = Video(
        name: "invalid",
        type: "foo",
        meta: [:]
    )
    
    let bundle = Bundle(for: VLCTimeTest.self)
    
    var media: VLCMedia {
        return type == "foo" ? VLCMedia(path: title) : VLCMedia(path: self.path)
    }
    
    var path: String {
        if type == "foo" {
            return title
        }
        let path = bundle.path(forResource: name, ofType: type)
        return path!
    }
    
    var url: URL {
        let url = bundle.url(forResource: name, withExtension: type)
        XCTAssertNotNil(url)
        return url!
    }
    
    var title: String {
        return "\(name).\(type)"
    }
}
