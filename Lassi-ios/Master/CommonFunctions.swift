//
//  CommonFunctions.swift
//  MediaPicker
//
//  Created by mac-0006 on 13/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import Foundation
import AVKit

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        return String(format: "%0.2d:%0.2d", (NSInteger(self) / 60) % 60, NSInteger(self) % 60)
    }
}

func stringFromInt(counter: Int) -> String {
    return String(format: "%0.2d", counter / 60) + ":" + String(format: "%0.2d", counter % 60)
}
