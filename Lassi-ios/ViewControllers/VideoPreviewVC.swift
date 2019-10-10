//
//  VideoPreviewVC.swift
//  MediaPicker
//
//  Created by mac-00015 on 03/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import UIKit
import AVKit
import Photos

class VideoPreviewVC: UIViewController {
    
    @IBOutlet weak var sliderProgress: UISlider!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    
    /**
     * video url
     */
    var videoURL: URL?
    /**
     * AVPlayer ViewController
     */
    var avPlayerVC = AVPlayerViewController()
    /**
     * AVPlayer
     */
    var player: AVPlayer?
    /**
     * AVPlayerLayer
     */
    var playerLayer: AVPlayerLayer?
    /**
     * current Time
     */
    var currentTime = Timer()
    /**
     * remaining Time
     */
    var remainingTime = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialization()
    }
}

// MARK:- Initialization
// MARK:-
extension VideoPreviewVC {
    func initialization() {
        self.customizeVideo()
    }
}

// MARK:- set-up video timming
// MARK:-
extension VideoPreviewVC {
    
    @objc func checkCurrentTime() {
        
        if let currentItem = player?.currentItem {
            
            sliderProgress.minimumValue = 0.0
            sliderProgress.maximumValue = Float((currentItem.duration.seconds))
            
            let videoCurrentTime = Float(CMTimeGetSeconds(currentItem.currentTime()))
            let secondsFinal = lrintf(videoCurrentTime.truncatingRemainder(dividingBy: 60))
            let seconds = String(format: "%02d", Int(secondsFinal % 60))
            let minutes = String(format: "%02d", Int((videoCurrentTime.truncatingRemainder(dividingBy: 3600)) / 60))
            lblCurrentTime.text = "\(minutes):\(seconds)"
            sliderProgress.value = Float((player?.currentTime().seconds)!)
            self.actionAtEnd()
        }
    }
    
    @objc func checkRemainingTime() {
        if let currentItem = player?.currentItem {
            let videoTotalTime = Float(CMTimeGetSeconds(currentItem.duration))
            let videoCurrentTime = Float(CMTimeGetSeconds(currentItem.currentTime()))
            let timeRemainingInVideo = videoTotalTime - videoCurrentTime
            let secondsFinal = lrintf(timeRemainingInVideo.truncatingRemainder(dividingBy: 60))
            let seconds = String(format: "%02d", Int(secondsFinal % 60))
            let minutes = String(format: "%02d", Int((timeRemainingInVideo.truncatingRemainder(dividingBy: 3600)) / 60))
            self.actionAtEnd()
            lblRemainingTime.text = "\(minutes):\(seconds)"
        }
    }
}

// MARK:- customize Video and action to video end
// MARK:-
extension VideoPreviewVC {
    
    fileprivate func customizeVideo() {
        guard videoURL != nil else {
            return
        }
        playerLayer?.frame = self.view.frame
        player = AVPlayer(url: videoURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = CGRect(x: 0, y: 0, width: CScreenWidth, height: CScreenHeight)
        self.view.layer.insertSublayer(playerLayer!, at: 0)
    }
    
    fileprivate func actionAtEnd() {
        if sliderProgress.value == sliderProgress.maximumValue {
            btnPlayPause.setImage(UIImage(named: "play"), for: .normal)
            btnPlayPause.tag = 1
            player?.seek(to: CMTimeMake(value: 0, timescale: 1))
            player?.pause()
        }
    }
}
// MARK:- Helper methods
// MARK:-
extension VideoPreviewVC {

    //MARK: - Add video to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print(error.localizedDescription)
        } else {
            
            let fetchOptions = PHFetchOptions()
            let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            result.enumerateObjects({ (collection, _, _) in
                if collection.localizedTitle == "Videos" {
                    let asset = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    if asset.count > 0{
                        
                        if let image = asset.lastObject {
                            
                            if AlbumsVC.shared.maximumSelection == 1 {
                                AlbumsVC.shared.getAssetPath(assets: [image]) { (url,images) in
                                    MediaPicker.shared.delegate?.didFinishPickingItems(url)
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                AlbumsVC.shared.selectedItem.append(image)
                                AlbumsVC.shared.totalSelection =  AlbumsVC.shared.totalSelection + 1
                                let selectedCount = AlbumsVC.shared.totalSelection
                                PhotosVC.shared.title = "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
                                AlbumsVC.shared.title = "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
                                
                                CGCDMainThread.async {
                                    AlbumsVC.shared.collVAlbums.reloadData()
                                }
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            })
        }
    }
}

// MARK:- Action Events
// MARK:-
extension VideoPreviewVC {
    
    @IBAction func btnCancelClicked(_ sender: UIButton) {
        player?.pause()
        currentTime.invalidate()
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnRightClicked(_ sender: UIButton) {
        //...Need to save video to gallery
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL?.path ?? "", self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    // slider Value Changed
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let seconds : Int64 = Int64(sliderProgress.value)
        let time : CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: time)
        self.actionAtEnd()
    }
    // play pause video
    @IBAction func btnPlayPauseClicked(_ sender: UIButton) {
        if sender.tag == 0 {
            btnPlayPause.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
            sender.tag = 1
        } else {
            player?.play()
            
            sender.tag = 0
            btnPlayPause.setImage(UIImage(named: "pause"), for: .normal)
            currentTime = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkCurrentTime), userInfo: nil, repeats: true)
            remainingTime = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkRemainingTime), userInfo: nil, repeats: true)
        }
    }
    // set Volume
    @IBAction func btnVolumeClicked(_ sender: UIButton) {
        sender.tag = sender.tag == 0 ? 1 : 0
        btnVolume.setImage(UIImage(named: sender.tag == 0 ? "mute" : "volume"), for: .normal)
        player?.isMuted = sender.tag == 0 ? true : false
    }
}
