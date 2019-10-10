//
//  PhotoCollVCell.swift
//  MediaPicker
//
//  Created by mac-00015 on 28/05/19.
//  Copyright © 2019 mac-0002. All rights reserved.
//

import UIKit
import Photos

class PhotoCollVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVPhoto: UIImageView!
    @IBOutlet weak var imgVPhotoSelected: UIImageView!
    @IBOutlet weak var viewSelectedImage: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
