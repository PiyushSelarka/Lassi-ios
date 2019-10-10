//
//  AlbumCollVCell.swift
//  MediaPicker
//
//  Created by mac-00015 on 28/05/19.
//  Copyright © 2019 mac-0002. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer

class AlbumCollVCell: UICollectionViewCell {
    
    @IBOutlet weak var lblAlbumName: UILabel!
    @IBOutlet weak var imgVAlbumCover: UIImageView!
    @IBOutlet weak var viewCamera: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension AlbumCollVCell {
    func setAlbum(_ album: PHAssetCollection) {
        
        let requestOptions = PHImageRequestOptions()
        let imgManager = PHImageManager()
        self.lblAlbumName.text = album.localizedTitle
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        let result = PHAsset.fetchAssets(in: album, options: nil)
        let assetResult = result.objects(at: IndexSet(0..<result.count))
        var lastResult = PHAsset()
       
        if AlbumsVC.shared.mediaType == MediaPicker.MediaType.IMAGE {
            for (index, _) in assetResult.reversed().enumerated() {
                if result[index].mediaType.rawValue == 1 {
                    lastResult = result[index]
                    break
                }
            }
        } else if AlbumsVC.shared.mediaType == MediaPicker.MediaType.VIDEO {
            for (index, _) in assetResult.reversed().enumerated() {
                if result[index].mediaType.rawValue == 2 {
                    lastResult = result[index]
                    break
                }
            }
        }
        imgManager.requestImage(for: lastResult, targetSize: CGSize(width: self.imgVAlbumCover.frame.width, height: self.imgVAlbumCover.frame.height), contentMode: .aspectFill, options: requestOptions) { (image, error) in
            if image != nil {
                self.imgVAlbumCover.image = image
            }
        }
    }
    func setMedia() {
        self.imgVAlbumCover.image = #imageLiteral(resourceName: "music")
        self.lblAlbumName.text = "Audio"
    }
}
