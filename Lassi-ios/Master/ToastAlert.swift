//
//  ToastAlert.swift
//  MediaPicker
//
//  Created by mac-0006 on 13/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import Foundation
import UIKit

class ToastAlert {
    
    private init() {}
    
    private static let toastAlert:ToastAlert = {
        let toastAlert = ToastAlert()
        return toastAlert
    }()
    
    static var shared:ToastAlert {
        return toastAlert
    }
    
    fileprivate static var animationDuration:TimeInterval = 1.5
    fileprivate static var viewRemovingDuration:TimeInterval = 3.5
    fileprivate static var timer = Timer()
}

extension ToastAlert {
    
    enum ToastAlertPosition {
        case top
        case center
        case bottom
    }
}

extension ToastAlert {
    
    fileprivate static let toastAlertView:UIView = {
        let toastAlertView = UIView()
        toastAlertView.tag = 200
        toastAlertView.layer.cornerRadius = 3.5
        toastAlertView.backgroundColor = CRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.0)
        toastAlertView.translatesAutoresizingMaskIntoConstraints = false
        return toastAlertView
    }()
    
    func setToastalertViewBgColor(color:UIColor?) {
        
        if var rgba = color?.getRGB() {
            
            rgba.a = 0.0
            
            ToastAlert.toastAlertView.backgroundColor = CRGBA(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
        }
    }
    
    func setToastalertViewAlpha(alpha:CGFloat) {
        
        if var rgba = ToastAlert.toastAlertView.backgroundColor?.getRGB() {
            
            rgba.a = alpha
            
            ToastAlert.toastAlertView.backgroundColor = CRGBA(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
        }
    }
    
    func setToastalertViewCornerRadius(cornerRadius:CGFloat) {
        ToastAlert.toastAlertView.layer.cornerRadius = cornerRadius
    }
    
}

extension ToastAlert {
    
    fileprivate static let lblMessage:UILabel = {
        let lblMessage = UILabel()
        lblMessage.textAlignment = .center
        lblMessage.textColor = CRGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.0)
        lblMessage.numberOfLines = 0
        lblMessage.translatesAutoresizingMaskIntoConstraints = false
        return lblMessage
    }()
    
    func setLblMessageTextAlignment(alignment:NSTextAlignment) {
        ToastAlert.lblMessage.textAlignment = alignment
    }
    
    func setLblMessageFont(font:UIFont) {
        ToastAlert.lblMessage.font = font
    }
    
    func setLblMessageTextColor(textColor:UIColor) {
        ToastAlert.lblMessage.textColor = textColor
    }
    
    fileprivate func setLblMessageText(message:String) {
        ToastAlert.lblMessage.text = message
    }
}

extension ToastAlert {
    
    func showToastAlert(position:ToastAlert.ToastAlertPosition , message:String) {
        
        if let toastAlertView = appdelegate.window?.viewWithTag(200) {
            ToastAlert.timer.invalidate()
            toastAlertView.removeAllSubviews()
            toastAlertView.removeFromSuperview()
        }
        
        ToastAlert.shared.setLblMessageText(message: message)
        self.resizeToastalertView(position: position)
        self.performAnimation()
    }
    
    private func resizeToastalertView(position:ToastAlertPosition) {
        appdelegate.window?.addSubview(ToastAlert.toastAlertView)
        
        NSLayoutConstraint(item: ToastAlert.toastAlertView, attribute: .centerX, relatedBy: .equal, toItem: appdelegate.window, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: ToastAlert.toastAlertView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CScreenWidth - 10.0 - 10.0).isActive = true
        
        var toastAlertViewAttribute:NSLayoutConstraint.Attribute
        var constant:CGFloat
        var appWindowAttribute:NSLayoutConstraint.Attribute
        
        switch position {
            
        case .top:
            constant = (IS_iPhone_X ? 88.0 : 64.0) + 20.0
            toastAlertViewAttribute = .top
            appWindowAttribute = .top
            
        case .center:
            constant = 0.0
            toastAlertViewAttribute = .centerY
            appWindowAttribute = .centerY
            
        case .bottom:
            constant = (IS_iPhone_X ? -(34.0 + 55.0) : -55.0)
            toastAlertViewAttribute = .bottom
            appWindowAttribute = .bottom
            
        }
        
        NSLayoutConstraint(item: ToastAlert.toastAlertView, attribute: toastAlertViewAttribute, relatedBy: .equal, toItem: appdelegate.window, attribute: appWindowAttribute, multiplier: 1.0, constant: constant).isActive = true
        
        ToastAlert.toastAlertView.addSubview(ToastAlert.lblMessage)
        
        NSLayoutConstraint(item: ToastAlert.lblMessage, attribute: .leading, relatedBy: .equal, toItem: ToastAlert.toastAlertView, attribute: .leading, multiplier: 1.0, constant: 10.0).isActive = true
        
        NSLayoutConstraint(item: ToastAlert.lblMessage, attribute: .top, relatedBy: .equal, toItem: ToastAlert.toastAlertView, attribute: .top, multiplier: 1.0, constant: 10.0).isActive = true
        
        NSLayoutConstraint(item: ToastAlert.lblMessage, attribute: .trailing, relatedBy: .equal, toItem: ToastAlert.toastAlertView, attribute: .trailing, multiplier: 1.0, constant: -10.0).isActive = true
        
        NSLayoutConstraint(item: ToastAlert.lblMessage, attribute: .bottom, relatedBy: .equal, toItem: ToastAlert.toastAlertView, attribute: .bottom, multiplier: 1.0, constant: -10.0).isActive = true
    }
    
    fileprivate func performAnimation() {
        
        if var rgba = ToastAlert.toastAlertView.backgroundColor?.getRGB() {
            
            rgba.a = 0.25
            
            ToastAlert.toastAlertView.backgroundColor = CRGBA(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
        }
        
        if var rgba = ToastAlert.lblMessage.textColor.getRGB() {
            
            rgba.a = 1.0
            
            ToastAlert.lblMessage.textColor = CRGBA(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
        }
        
        ToastAlert.toastAlertView.alpha = 0
        UIView.animate(withDuration: ToastAlert.animationDuration) {
            ToastAlert.toastAlertView.alpha = 1
            
        }
        
        ToastAlert.timer = Timer.scheduledTimer(withTimeInterval: ToastAlert.viewRemovingDuration, repeats: false) { (_timer) in
            
            UIView.animate(withDuration: ToastAlert.animationDuration, animations: {
                ToastAlert.toastAlertView.alpha = 0
            }, completion: { (completion) in
                _timer.invalidate()
                ToastAlert.toastAlertView.removeAllSubviews()
                ToastAlert.toastAlertView.removeFromSuperview()
            })
        }
    }
}



