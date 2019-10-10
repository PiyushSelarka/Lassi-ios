//
//  ExtensionUIColor.swift
//  MediaPicker
//
//  Created by mac-0006 on 13/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func getRGB() -> (r:CGFloat , g:CGFloat , b:CGFloat , a:CGFloat)? {
        
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        
        return (red , green , blue , alpha)
    }
}
