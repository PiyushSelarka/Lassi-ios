//
//  AlbumsVC.swift
//  MediaPicker
//
//  Created by mac-00015 on 27/05/19.
//  Copyright © 2019 mac-0002. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import CropViewController

class AlbumsVC: UIViewController {
    
    @IBOutlet weak var collVAlbums: UICollectionView! {
        didSet {
            
            let podBundle = Bundle(for: AlbumCollVCell.self)
            self.collVAlbums.register(UINib(nibName: "AlbumCollVCell", bundle: podBundle), forCellWithReuseIdentifier: "AlbumCollVCell")
        }
    }
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /**
     * Albums shared
     */
    static let shared = AlbumsVC()
    /**
     * Albums array of PHAssetCollection
     */
    private var albums: [PHAssetCollection] = []
    /**
     * Media array
     */
    private var arrMedia = [Any]()
    /**
     * Array of selected Items MPMediaItem == [MPMediaItem]
     */
    private var selectedMedia = [MPMediaItem]()
    /**
     * Number of items in single row
     */
    private var numbeOfItemsInRow = 3
    /**
     * NavigationController instance
     */
    var navigation = UINavigationController()
    /**
     * PHImageRequestOptions
     */
    let requestOptions = PHImageRequestOptions()
    /**
     * PHImageManager
     */
    let imgManager = PHImageManager()
    /**
     * Array of selected images PHAsset [PHAsset]
     */
    var selectedItem = [PHAsset]()
    /**
     * Array of selected Audios [MPMediaItem]
     */
    var selectedAudioItem = [MPMediaItem]()
    /**
     * Maximum selection which is allowed
     */
    var maximumSelection = 1
    /**
     * Total selection count which is selected
     */
    var totalSelection = 0
    /**
     * Bar button color
     */
    var barButtonColor: UIColor?
    /**
     * Media type passed
     */
    var mediaType: MediaPicker.MediaType?
    /**
     * Filter media by media format
     */
    var arrFilter = [String]()
    /**
     * Minimum time for video
     */
    var minTimeForVideo = 0
    /**
     * Maximum time for video
     */
    var maxTimeForVideo = 0
    /**
     * Camera is enable or not default value is false
     */
    var isCameraEnable = false
    /**
     * Choose Option CAMERA, GALLERY or CAMERA_AND_GALLERY
     */
    var optionType : MediaPicker.LassiOption?
    /**
     * Choose Option Cropping Style default value is .default
     */
    var setCropType : CropViewCroppingStyle?
    /**
     * Choose Option Cropping Ratio default value is .presetOriginal
     */
    var setCropAspectRatio : CropViewControllerAspectRatioPreset?
    
    /**
     * Preferred Status Bar Style
     */
    override var preferredStatusBarStyle: UIStatusBarStyle { return style }
    
    var style: UIStatusBarStyle = .default

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNoDataFound.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /**
         * Config Bar Buttons
         */
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "tick_icon"), style: .plain, target: self, action: #selector(btnDoneClicked(_:)))
        rightBarButton.tintColor = barButtonColor
        
        let cameraButton = UIBarButtonItem(image: UIImage(named: "camera_icon"), style: .plain, target: self, action: #selector(btnCameraClicked(_:)))
        cameraButton.tintColor = barButtonColor
        
        if mediaType == .AUDIO {
            self.navigationItem.setRightBarButtonItems(selectedAudioItem.count > 0 ? [rightBarButton]:[], animated: true)
        } else {
            if optionType == .GALLERY {
                self.navigationItem.setRightBarButtonItems(selectedItem.count > 0 ? [rightBarButton]:[], animated: true)
            } else {
                self.navigationItem.setRightBarButtonItems(selectedItem.count > 0 ? [rightBarButton, cameraButton]:[cameraButton], animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureAlbums()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        let podBundle = Bundle(for: AlbumsVC.self)
        super.init(nibName: "AlbumsVC", bundle: podBundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- Configuration
// MARK:-
extension AlbumsVC {
    func configure(
        optionType: MediaPicker.LassiOption,
        maxCount: Int,
        gridSize: Int,
        toolbarColor: UIColor,
        toolbarIconColor: UIColor,
        mediaType: MediaPicker.MediaType,
        statusBarColor: UIColor,
        supportedFileType: [MediaPicker.MediaFormat],
        setCropType: CropViewCroppingStyle,
        setCropAspectRatio: CropViewControllerAspectRatioPreset,
        minTime: Int,
        maxTime: Int,
        enableCamera: Bool
        ) {
        
        if mediaType == .DOC {
            
            let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf","public.rtf","public.presentation","public.spreadsheet","com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key", "public.text", "com.apple.rtfd"], in: UIDocumentPickerMode.import)
            documentPicker.delegate = self
            if #available(iOS 11.0, *) {
                documentPicker.allowsMultipleSelection = true;
            }
            
            guard let window = appWindow else {
                return
            }
            
            window.rootViewController?.present(documentPicker, animated: true)
            
        } else {
            
            /**
             * Grid only 2 to 4
             */
            if gridSize <= 2 {
                self.numbeOfItemsInRow = 2
            } else if gridSize >= 4 {
                self.numbeOfItemsInRow = 4
            } else {
                self.numbeOfItemsInRow = gridSize
            }
            
            maximumSelection = maxCount <= 1 ? 1 : maxCount
            self.mediaType = mediaType
            self.setCropType = setCropType
            self.setCropAspectRatio = setCropAspectRatio
            self.arrFilter = supportedFileType.map({$0.formatValue})
            self.minTimeForVideo = minTime < 1 ? 1 : minTime
            self.maxTimeForVideo = maxTime
            self.isCameraEnable = enableCamera
            self.optionType = optionType
            
            /**
             * Config UI
             */
            barButtonColor = toolbarIconColor
            navigation = UINavigationController(rootViewController: self)
            navigation.navigationBar.barTintColor = toolbarColor
            navigation.navigationBar.isTranslucent = false
            totalSelection = 0
            
            if let StatusbarView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                StatusbarView.backgroundColor = statusBarColor
            }
            
            if (toolbarColor == UIColor.black && statusBarColor == UIColor.clear) || (toolbarColor == UIColor.black && statusBarColor == UIColor.black) {
                
                navigation.navigationBar.barStyle = .blackTranslucent
                self.style = .lightContent
                setNeedsStatusBarAppearanceUpdate()
            } else if statusBarColor == UIColor.black {
                
                navigation.navigationBar.barStyle = .blackTranslucent
                self.style = .lightContent
                setNeedsStatusBarAppearanceUpdate()
            }
            self.title = maxCount == 1 ? nil : "\(totalSelection) / \(maximumSelection)"
            self.navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: toolbarIconColor]
            let leftBarButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(btnCancelClicked(_:)))
            leftBarButton.tintColor = barButtonColor
            self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
            
            guard let window = appWindow else {
                return
            }
            
            window.rootViewController?.present(navigation, animated: true, completion: nil)
            
            self.selectedItem.removeAll()
            self.selectedAudioItem.removeAll()
        }
    }
}

// MARK:- UICollectionView Delegate and Datasource methods
// MARK:-
extension AlbumsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaType == MediaPicker.MediaType.AUDIO ? MPMediaQuery().items?.count ?? 0 > 0 ? 1 : 0 : albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollVCell", for: indexPath) as? AlbumCollVCell
        
        if cell == nil {
            
            let bundle = Bundle(for: AlbumCollVCell.self)
            cell = bundle.loadNibNamed("AlbumCollVCell", owner: nil, options: nil)?.first as? AlbumCollVCell
        }
        
        
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollVCell", for: indexPath) as? AlbumCollVCell {
        
            
            
//            customCell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:customCellID];
//            if (customCell == nil) {
//                NSArray *nibs = [resourcesBundle loadNibNamed:emptyCellID owner:nil options:nil];
//                customCell = [nibs objectAtIndex:0];
//            }
        
        if let cell = cell {
            if mediaType == MediaPicker.MediaType.AUDIO {
                cell.setMedia()
            } else {
                cell.setAlbum(albums[indexPath.row])
            }
            return cell
        }
           
        
//        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let bundle = Bundle(for: PhotosVC.self)
        let photosVC = PhotosVC(nibName: "PhotosVC", bundle: bundle)
       
        if mediaType == MediaPicker.MediaType.AUDIO {
            let query = MPMediaQuery()
            photosVC.selectedQuary = query.items
        } else {
            let album = albums[indexPath.row]
            photosVC.selectedCollection = album
        }
        
        photosVC.numbeOfItemsInRow = self.numbeOfItemsInRow
        self.navigation.pushViewController(photosVC, animated: true)
    }
}

// MARK:- UICollectionViewDelegateFlowLayout
// MARK:-
extension AlbumsVC: UICollectionViewDelegateFlowLayout {
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
        return CGSize(width: width, height: width + 25)
    }
}

// MARK:- Helper methods
// MARK:- configure Albums for fatch image and video

extension AlbumsVC {
    private func configureAlbums() {
        self.albums.removeAll()
        let fetchOptions = PHFetchOptions()
      
        /**
         * Fatch IMAGE
         */
        if mediaType == MediaPicker.MediaType.IMAGE {
            
            let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            result.enumerateObjects({ (collection, _, _) in
                let asset = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                if asset.count > 0{
                    self.albums.append(collection)
                }
            })
            self.lblNoDataFound.isHidden = self.albums.count != 0
        
            /**
             * Fatch VIDEO
             */
        } else if mediaType == MediaPicker.MediaType.VIDEO {
            
            let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            result.enumerateObjects({ (collection, _, _) in
                let asset = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                if asset.count > 0{
                    self.albums.append(collection)
                }
            })
            
            /**
             * No Data Found
             */
            self.lblNoDataFound.isHidden = self.albums.count == 0 ? false : true
            
        }  else if mediaType == MediaPicker.MediaType.AUDIO {
           
            let query = MPMediaQuery()
            self.lblNoDataFound.isHidden = query.items == nil ? false : true
        }
        self.collVAlbums.isHidden = false
        self.collVAlbums.reloadData()
    }
    
    /**
     * Convert array of PHAsset to UIImage
     */
    func getAssetPath(assets: [PHAsset], completion: @escaping (([URL],_ images: [UIImage]?) -> Void)) {
       
        var arrayOfPath = [URL]()
        let myGroup = DispatchGroup()
        var images = [UIImage]()
        
        // Loader View
        CustomLoaderView.shared.startLoading()
        
        for asset in assets {
            myGroup.enter()
            let option = PHImageRequestOptions()
            var itemPath:URL?
            
            let manager = PHImageManager()
            option.isSynchronous = true
            option.deliveryMode = .highQualityFormat
            option.isNetworkAccessAllowed = true
            option.progressHandler = {  (progress, error, stop, info) in
                print("progress: \(progress)")
            }
            if mediaType == MediaPicker.MediaType.IMAGE {
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    if info != nil {
                        if let itemPath = info?["PHImageFileURLKey"] as? URL {
                            arrayOfPath.append(itemPath)
                            if let orignalImages = result {
                                images.append(orignalImages)
                            }
                            myGroup.leave()
                        } else {
                            ToastAlert.shared.showToastAlert(position: .bottom, message: "Image not supported")
                        }
                    }
                })
            } else if mediaType == MediaPicker.MediaType.VIDEO {
                manager.requestAVAsset(forVideo: asset, options: nil) { (avAsset, audioMix, info) in
                    if avAsset != nil {
                        
                        if let url = avAsset?.value(forKey: "URL") {
                            itemPath = url as? URL
                            arrayOfPath.append(itemPath!)
                            myGroup.leave()
                        } else {
                            ToastAlert.shared.showToastAlert(position: .bottom, message: "Video not supported")
                        }
                    } else {
                        print("avAsset nil")
                        ToastAlert.shared.showToastAlert(position: .bottom, message: "Video not supported")
                    }
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            CustomLoaderView.shared.stopLoading()
            completion(arrayOfPath,images)
        }
    }
    /**
     * Convert array of MPMediaItem to URL
     */
    func getAudioPath(mediaItem: [MPMediaItem], completion: @escaping (([URL]) -> Void)) {
        
        CustomLoaderView.shared.startLoading()
        
        var arrayOfPath = [URL]()
        let myGroup = DispatchGroup()
       
        for media in mediaItem {
            myGroup.enter()
            if let url = media.assetURL {
                export(url) { (url, err) in
                    if err == nil {
                        arrayOfPath.append(url!)
                        myGroup.leave()
                    }
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            CustomLoaderView.shared.stopLoading()
            completion(arrayOfPath)
        }
    }
}

// MARK:- Action events
// MARK:-
extension AlbumsVC {
    @objc func btnCancelClicked(_ sender: UIBarButtonItem) {
        
        self.albums.removeAll()
        CGCDMainThread.async {
            self.collVAlbums.isHidden = true
            self.collVAlbums.reloadData()
        }
        
        self.dismiss(animated: true) {
            if let StatusbarView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                StatusbarView.backgroundColor = .clear
            }
        }
    }
    
    @objc func btnDoneClicked(_ sender: UIBarButtonItem) {
        
        if selectedItem.count != 0 {
            getAssetPath(assets: selectedItem) { (url,image)  in
                MediaPicker.shared.delegate?.didFinishPickingItems(url)
            }
            self.navigation.dismiss(animated: true) {
                if let StatusbarView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                    StatusbarView.backgroundColor = .clear
                }
                self.albums.removeAll()
                CGCDMainThread.async {
                    self.collVAlbums.reloadData()
                }
            }
        }
    }
    
    @objc func btnCameraClicked(_ sender: UIBarButtonItem) {
        if selectedItem.count == 5 {
            ToastAlert.shared.showToastAlert(position: .bottom, message: "Already selected max items.")
        } else {
            if mediaType == MediaPicker.MediaType.VIDEO {
                let bundle = Bundle(for: VideoCameraVC.self)
                let videoCameraVC = VideoCameraVC(nibName: "VideoCameraVC", bundle: bundle)
                self.navigation.present(videoCameraVC, animated: true, completion: nil)
            } else {
                
                let bundle = Bundle(for: PhotoCameraVC.self)
                
                let photoCameraVC = PhotoCameraVC(nibName: "PhotoCameraVC", bundle: bundle)
                photoCameraVC.croppingStyle = setCropType
                photoCameraVC.aspectRatioPreset = setCropAspectRatio
                self.navigation.present(photoCameraVC, animated: true, completion: nil)
            }
        }
    }
}

// MARK:- --------- MPMediaPickerController
// for MPMediaPickerController export media file
extension AlbumsVC {
    
    func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, Error?.self as? Error)
            return
        }
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")
        
        exporter.outputURL = fileURL
        exporter.outputFileType = .m4a
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
    }
}

// MARK:- --------- UIDocumentPickerViewController
extension AlbumsVC : UIDocumentPickerDelegate {
    
    /// A Delegate method of UIDocumentPickerDelegate.
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        /**
         * Documents final array of urls
         */
        MediaPicker.shared.delegate?.didFinishPickingItems(urls.map({$0.absoluteURL}))
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
