//
//  PhotosVC.swift
//  MediaPicker
//
//  Created by mac-00015 on 29/05/19.
//  Copyright © 2019 mac-0002. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import CropViewController

class PhotosVC: UIViewController {
    
    @IBOutlet weak var collVPhotos: UICollectionView! {
        // collection view Photos cell register
        didSet {
            self.collVPhotos.register(UINib(nibName: "PhotoCollVCell", bundle: appBundle), forCellWithReuseIdentifier: "PhotoCell")
        }
    }
    @IBOutlet weak var lblNoItemFound: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let shared = PhotosVC()
    /**
     * Selected album
     */
    var selectedCollection: PHAssetCollection?
    /**
     * Selected Audio
     */
    var selectedQuary: [Any]?
    /**
     * Photos in selected album
     */
    private var photos = [PHAsset]()
    /**
     * Audio in selected items
     */
    private var arrAudio: [MPMediaItem]?
    /**
     * Number of items in single row
     */
    var numbeOfItemsInRow = 3
    /**
     * Array of already selected item PHAsset == [PHAsset]
     */
    var alreadySelectedItem = [PHAsset]()
    /**
     * Array of already selected item MPMediaItem == [MPMediaItem]
     */
    var alreadySelectedAudio = [MPMediaItem]()
    /**
     * Which item is selected
     */
    var isSelected = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialization()
    }
}

// MARK:- Initialization
// MARK:-
extension PhotosVC {
    func initialization() {
        self.lblNoItemFound.isHidden = true
        
        /**
         * fetch Audio, video and image
         */
        AlbumsVC.shared.mediaType == MediaPicker.MediaType.AUDIO ? self.fetchAudio() : self.fetchImagesFromGallery(collection: selectedCollection)
        
        /**
         * Config Bar Buttons
         */
        self.activityIndicator.color = .red
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(AlbumsVC.shared.totalSelection) / \(AlbumsVC.shared.maximumSelection) items selected"
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(btnCancelClicked(_:)))
        leftBarButton.tintColor = AlbumsVC.shared.barButtonColor
        self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
       
        if AlbumsVC.shared.maximumSelection != 1 {
            let rightBarButton = UIBarButtonItem(image: UIImage(named: "tick_icon"), style: .plain, target: self, action: #selector(btnDoneClicked(_:)))
            rightBarButton.tintColor = AlbumsVC.shared.barButtonColor
            self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        }
    }
}

// MARK:- UICollectionView Delegate and Datasource methods
// MARK:-
extension PhotosVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if AlbumsVC.shared.mediaType == MediaPicker.MediaType.AUDIO {
            return arrAudio?.count ?? 0
        } else {
            if photos.count != 0 {
                return photos.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCollVCell {
            
            /**
             * Config Table Cells
             */
            if AlbumsVC.shared.mediaType == MediaPicker.MediaType.AUDIO {
                
                if let artWork = arrAudio?[indexPath.row].value(forKey: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
                    cell.imgVPhoto.image = (artWork.image(at: CGSize(width: 50.0, height: 50.0)) != nil) ? artWork.image(at: CGSize(width: 50.0, height: 50.0)) : #imageLiteral(resourceName: "music")
                } else {
                    cell.imgVPhoto.image = #imageLiteral(resourceName: "music")
                }
                if let items = arrAudio?[indexPath.row] {
                    let durication = items.playbackDuration.stringFromTimeInterval()
                    cell.lblDuration.text = durication
                }
                cell.viewSelectedImage.isHidden = self.isSelected[indexPath.row] ? false : true
                cell.imgVPhotoSelected.isHidden = self.isSelected[indexPath.row] ? false : true
               
                return cell
                
            } else {
                
                let imgManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.deliveryMode = .highQualityFormat
                requestOptions.isSynchronous = true
                
                if photos.count > 0 {
                    
                    //...Hide/Show label duration
                    //...Calculate video duration
                    cell.lblDuration.text = AlbumsVC.shared.mediaType == MediaPicker.MediaType.IMAGE ? "" : photos[indexPath.row].duration.stringFromTimeInterval()
                    
                    imgManager.requestImage(for: photos[indexPath.row], targetSize: CGSize(width: cell.imgVPhoto.frame.width, height: cell.imgVPhoto.frame.height), contentMode: .aspectFill, options: requestOptions) { (image, error) in
                        if image != nil {
                            cell.imgVPhoto.image = image
                        }
                        cell.viewSelectedImage.isHidden = self.isSelected[indexPath.row] ? false : true
                        cell.imgVPhotoSelected.isHidden = self.isSelected[indexPath.row] ? false : true
                    }
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // For Audio
        if AlbumsVC.shared.mediaType == MediaPicker.MediaType.AUDIO {
            if AlbumsVC.shared.maximumSelection == 1 {
                guard let item = arrAudio?[indexPath.row] else { return }
                CustomLoaderView.shared.startLoading()
                AlbumsVC.shared.getAudioPath(mediaItem: [item]) { (url) in
                    CustomLoaderView.shared.stopLoading()
                    MediaPicker.shared.delegate?.didFinishPickingItems(url)
                    self.dismissVC()
                }
            } else {
                selectedAudios(indexPath: indexPath)
            }
            
        } else {
            // For image and video
            if AlbumsVC.shared.maximumSelection == 1 {
            
                AlbumsVC.shared.getAssetPath(assets: [photos[indexPath.row]]) { (url,images) in
                    if AlbumsVC.shared.mediaType == MediaPicker.MediaType.IMAGE {
                        
                        /**
                         * cropping image when select 1 image
                         */
                        if let image = images?.first {
                            self.configCropVC(image: image)
                        }
                    } else {
                        MediaPicker.shared.delegate?.didFinishPickingItems(url)
                    }
                }
                dismissVC()
            } else {
                selectedImagesAndVideos(indexPath: indexPath)
            }
        }
    }
}

// MARK:- UICollectionViewDelegateFlowLayout
// MARK:-
extension PhotosVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (Int(UIScreen.main.bounds.width) / numbeOfItemsInRow) - 15
        return CGSize(width: width, height: width)
    }
}

// MARK:- Helper Methods
// MARK:-
extension PhotosVC {
    /**
     * fetch Images and video from gallery
     */
    private func fetchImagesFromGallery(collection: PHAssetCollection?) {
        let items: PHFetchResult<PHAsset>?
        let fetchOptions = PHFetchOptions()
       
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if AlbumsVC.shared.mediaType == MediaPicker.MediaType.IMAGE {
            
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            fetchOptions.includeAssetSourceTypes = PHAssetSourceType(arrayLiteral: [])
            
        } else if AlbumsVC.shared.mediaType == MediaPicker.MediaType.VIDEO {
            
            if AlbumsVC.shared.maxTimeForVideo > AlbumsVC.shared.minTimeForVideo {
                let maxDuration = AlbumsVC.shared.maxTimeForVideo + 1
                let minDuration = AlbumsVC.shared.minTimeForVideo - 1
                // video min & max time Predicate
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d AND duration >= %d AND duration < %d", PHAssetMediaType.video.rawValue, minDuration, maxDuration)
                
            } else {
                
                let minDuration = AlbumsVC.shared.minTimeForVideo - 1
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d AND duration > %d", PHAssetMediaType.video.rawValue, minDuration)
            }
        }
        if let collection = collection {
            items = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        } else {
            items = PHAsset.fetchAssets(with: fetchOptions)
        }
        
        let albumPhotos = items!.objects(at: IndexSet(0..<items!.count))
        let filterArray = AlbumsVC.shared.arrFilter
        
        // filter file types
        photos = filterArray.count != 0 ? albumPhotos.filter({filterArray.contains(($0.value(forKey: "uniformTypeIdentifier") as?  String)!)}) : albumPhotos
        
        for i in 0..<photos.count {
            self.isSelected.append(false)
            let id = photos[i].localIdentifier
            self.alreadySelectedItem = AlbumsVC.shared.selectedItem.filter({$0.localIdentifier == id})
            self.isSelected[i] = self.alreadySelectedItem.count != 0 ? true : false
        }
        
        DispatchQueue.main.async {
            if self.photos.count == 0 {
                self.lblNoItemFound.isHidden = false
            } else {
                self.collVPhotos.reloadData()
            }
        }
    }
    /**
     * fetch Audio from MPMediaPicker
     */
    func fetchAudio() {
        let query = MPMediaQuery()
        
        if let items = query.items,items.count > 0 {
            
            arrAudio = items
            for i in 0..<arrAudio!.count {
                self.isSelected.append(false)
                let id = arrAudio![i].albumTitle
                self.alreadySelectedAudio = AlbumsVC.shared.selectedAudioItem.filter({$0.albumTitle == id})
                self.isSelected[i] = self.alreadySelectedAudio.count != 0 ? true : false
            }
            self.collVPhotos.reloadData()
            
        } else {
            self.lblNoItemFound.isHidden = false
        }
    }
    /**
     * selection image and video
     */
    func selectedImagesAndVideos(indexPath:IndexPath) {
        
        let alreadySelectedImage = AlbumsVC.shared.selectedItem.filter({$0.localIdentifier == photos[indexPath.row].localIdentifier})
        
        if alreadySelectedImage.count == 0 {
            if AlbumsVC.shared.totalSelection < AlbumsVC.shared.maximumSelection {
                AlbumsVC.shared.selectedItem.append((photos[indexPath.row]))
                self.isSelected[indexPath.row] = true
                if let cell = collVPhotos.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? PhotoCollVCell {
                    cell.viewSelectedImage.isHidden = false
                    cell.imgVPhotoSelected.isHidden = false
                }
                AlbumsVC.shared.totalSelection =  AlbumsVC.shared.totalSelection + 1
                let selectedCount = AlbumsVC.shared.totalSelection
                self.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
                AlbumsVC.shared.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
            }
        } else {
            let alreadySelectedImageIndex = AlbumsVC.shared.selectedItem.firstIndex(of: alreadySelectedImage.first!)
            self.isSelected[indexPath.row] = false
            AlbumsVC.shared.selectedItem.remove(at: alreadySelectedImageIndex!)
            if let cell = collVPhotos.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? PhotoCollVCell {
                cell.viewSelectedImage.isHidden = true
                cell.imgVPhotoSelected.isHidden = true
            }
            AlbumsVC.shared.totalSelection = AlbumsVC.shared.totalSelection - 1
            let selectedCount = AlbumsVC.shared.totalSelection
            self.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
            AlbumsVC.shared.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
        }
    }
    func selectedAudios(indexPath:IndexPath) {
        /**
         * Selection Audio and set audio durication when view Hide/Show
         */
        let alreadySelectedAudio = AlbumsVC.shared.selectedAudioItem.filter({$0.albumTitle == arrAudio?[indexPath.row].albumTitle})
        
        if alreadySelectedAudio.count == 0 {
            if AlbumsVC.shared.totalSelection < AlbumsVC.shared.maximumSelection {
                AlbumsVC.shared.selectedAudioItem.append((arrAudio?[indexPath.row])!)
                self.isSelected[indexPath.row] = true
                if let cell = collVPhotos.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? PhotoCollVCell {
                    cell.viewSelectedImage.isHidden = false
                    cell.imgVPhotoSelected.isHidden = false
                }
                AlbumsVC.shared.totalSelection =  AlbumsVC.shared.totalSelection + 1
                let selectedCount = AlbumsVC.shared.totalSelection
                
                self.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
                AlbumsVC.shared.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
            }
        } else {
            /**
             * already Selected Image when view Hide/Show
             */
            let alreadySelectedImageIndex = AlbumsVC.shared.selectedAudioItem.firstIndex(of: alreadySelectedAudio.first!)
            self.isSelected[indexPath.row] = false
            AlbumsVC.shared.selectedAudioItem.remove(at: alreadySelectedImageIndex!)
            if let cell = collVPhotos.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? PhotoCollVCell {
                cell.viewSelectedImage.isHidden = true
                cell.imgVPhotoSelected.isHidden = true
            }
            AlbumsVC.shared.totalSelection = AlbumsVC.shared.totalSelection - 1
            let selectedCount = AlbumsVC.shared.totalSelection
            self.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
            AlbumsVC.shared.title = AlbumsVC.shared.maximumSelection == 1 ? nil : "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
        }
    }
    
    func dismissVC() {
        AlbumsVC.shared.navigation.dismiss(animated: true) {
            if let StatusbarView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                StatusbarView.backgroundColor = .clear
            }
        }
    }
}

// MARK:- Action Events
// MARK:-
extension PhotosVC {

    @objc private func btnCancelClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func btnDoneClicked(_ sender: UIBarButtonItem) {
        
        if AlbumsVC.shared.mediaType == MediaPicker.MediaType.AUDIO {
            if AlbumsVC.shared.selectedAudioItem.count != 0 {
                getAudioPath()
            }
        } else {
            if AlbumsVC.shared.selectedItem.count != 0 {
                getAssetPath()
            }
        }
        dismissVC()
    }
}

// MARK:- selected item(s) url(s)
// MARK:-
extension PhotosVC {
    
    fileprivate func getAudioPath() {
        
        CustomLoaderView.shared.startLoading()
        AlbumsVC.shared.getAudioPath(mediaItem: AlbumsVC.shared.selectedAudioItem) { (url) in
            MediaPicker.shared.delegate?.didFinishPickingItems(url)
            CustomLoaderView.shared.stopLoading()
        }
    }
    
    fileprivate func getAssetPath() {
        AlbumsVC.shared.getAssetPath(assets: AlbumsVC.shared.selectedItem) { (url,images) in
            MediaPicker.shared.delegate?.didFinishPickingItems(url)
        }
    }
}

//MARK:- Config CropViewController
//MARK:- CropViewControllerDelegate
extension PhotosVC: CropViewControllerDelegate {
    
    func configCropVC(image:UIImage) {
       
        let cropController = CropViewController(croppingStyle: AlbumsVC.shared.setCropType ?? CropViewCroppingStyle.default, image: image)
        cropController.delegate = self
        cropController.aspectRatioPreset = AlbumsVC.shared.setCropAspectRatio ?? CropViewControllerAspectRatioPreset.presetOriginal
        cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
        cropController.resetAspectRatioEnabled = false // When tapping 'reset', the aspect ratio will NOT be reset back to default
        
        guard let window = appWindow else {
            return
        }
        
        window.rootViewController?.present(cropController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        /**
         * cropping image save in album
         */
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        cropViewController.dismiss(animated: false) { }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print(error.localizedDescription)
        } else {
            
            let fetchOptions = PHFetchOptions()
            let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            result.enumerateObjects({ (collection, _, _) in
                /**
                 * save image fatch and selection
                 */
                if collection.localizedTitle == "All Photos" {
                    let asset = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    if asset.count > 0{
                        if let image = asset.lastObject {
                            AlbumsVC.shared.selectedItem.append(image)
                            AlbumsVC.shared.totalSelection =  AlbumsVC.shared.totalSelection + 1
                            let selectedCount = AlbumsVC.shared.totalSelection
                            PhotosVC.shared.title = "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
                            AlbumsVC.shared.title = "\(selectedCount) / \(AlbumsVC.shared.maximumSelection) items selected"
                            AlbumsVC.shared.getAssetPath(assets: AlbumsVC.shared.selectedItem) { (url,images)  in
                                MediaPicker.shared.delegate?.didFinishPickingItems(url)
                            }
                            CGCDMainThread.async {
                                AlbumsVC.shared.collVAlbums.reloadData()
                            }
                        }
                    }
                }
            })
        }
    }
}
