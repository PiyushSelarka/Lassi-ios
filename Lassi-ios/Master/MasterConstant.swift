//
//  MasterConstant.swift
//  MediaPicker
//
//  Created by mac-0006 on 13/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import Foundation
import UIKit

let CMainScreen = UIScreen.main
let CBounds = CMainScreen.bounds

let CScreenSize = CBounds.size
let CScreenWidth = CScreenSize.width
let CScreenHeight = CScreenSize.height

let CSharedApplication = UIApplication.shared
let appDelegate = CSharedApplication.delegate as! AppDelegate
var CTopMostViewController:UIViewController
{
    get { return CSharedApplication.topMostViewController }
    set{}
}

let IS_iPhone_X = CScreenHeight == 812

func CRGB(r:CGFloat , g:CGFloat , b:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

func CRGBA(r:CGFloat , g:CGFloat , b:CGFloat , a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

let CGCDMainThread = DispatchQueue.main
