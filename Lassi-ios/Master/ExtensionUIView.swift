//
//  ExtensionUIView.swift
//  MediaPicker
//
//  Created by mac-0006 on 13/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /// This method is used for removing all the subviews of UIView.
    func removeAllSubviews() {
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    /// This method is used for removing all the subviews from InterfaceBuilder for perticular tag.
    ///
    /// - Parameter tag: Pass the tag value of UIView , and that UIView and its all subviews will remove from InterfaceBuilder.
    func removeAllSubviewsOfTag(tag:Int) {
        
        for subview in self.subviews {
            
            if subview.tag == tag {
                subview.removeFromSuperview()
            }
        }
    }
}

extension UIView {
    
    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.
    
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
extension UIView {
    class func initFromNib<T: UIView>() -> T {
        
        guard let nib = appBundle?.loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as? T else {
            return UIView() as! T
        }
        
        return nib
    }
}
