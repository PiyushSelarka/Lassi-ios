//
//  ExtensionUIApplication.swift
//  MediaPicker
//
//  Created by mac-0006 on 13/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import Foundation
import UIKit


// MARK: - Extension of UIApplication For getting the TopMostViewController(UIViewController) of Application.
extension UIApplication {
    
    func topMostViewController(viewController : UIViewController? = CSharedApplication.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationViewController = viewController as? UINavigationController {
            
            return CSharedApplication.topMostViewController(viewController: navigationViewController.visibleViewController)
        }
        
        if let tabBarViewController = viewController as? UITabBarController {
            
            if let selectedViewController = tabBarViewController.selectedViewController {
                
                return CSharedApplication.topMostViewController(viewController: selectedViewController)
            }
        }
        
        if let presentedViewController = viewController?.presentedViewController {
            
            return CSharedApplication.topMostViewController(viewController: presentedViewController)
        }
        
        return viewController
    }
    
    var topMostViewController:UIViewController {
        
        var topViewController = self.keyWindow?.rootViewController
        
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        
        return topViewController!
    }
}
