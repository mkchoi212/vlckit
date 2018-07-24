//
//  File.swift
//  MobileVLCKit
//
//  Created by Mike Choi on 7/17/18.
//

import XCTest

class VLCDialogProviderTests: XCTestCase {
    func testInitWithLibrary() {
        let tests: [(customUI: Bool, type: String)] = [
            (true, "VLCCustomDialogRendererProtocol"),
            (false, "VLCEmbeddedDialogProvider")
        ]
        
        for (customUI, type) in tests {
            let provider = VLCDialogProvider(library: VLCLibrary.shared(), customUI: customUI)

        }
    }
}
