//
//  CustomLoaderView.swift
//  LoginDemo
//
//  Created by mac-00013 on 26/03/19.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class CustomLoaderView: UIView {
        
    static let shared: CustomLoaderView = {
        let loader = CustomLoaderView()
        let view = loader.instantiate()
        return view
    }()
    
    @IBOutlet weak var viewBackground: UIView! {
        didSet {
            self.viewBackground.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    func instantiate() -> CustomLoaderView {
        let view: CustomLoaderView = .initFromNib()
        return view
    }
    
    func startLoading() {
        
        guard let window = appWindow else {
            return
        }
        
        self.frame = CGRect(x: 0, y: 0, width: CScreenWidth, height: CScreenHeight)
        window.addSubview(self)
        self.activityLoader.startAnimating()
    }
    
    func stopLoading() {
        self.activityLoader.stopAnimating()
        self.removeFromSuperview()
    }
    
}
