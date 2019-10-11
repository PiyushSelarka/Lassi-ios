//
//  PhotoCameraVC.swift
//  MediaPicker
//
//  Created by mac-00015 on 31/05/19.
//  Copyright © 2019 mac-0002. All rights reserved.
//

import UIKit
import AVFoundation
import CropViewController
import Photos

class PhotoCameraVC: UIViewController {
    
    @IBOutlet weak var btnCaptureImage: UIButton! {
        didSet {
            CGCDMainThread.async {
                self.btnCaptureImage.layer.masksToBounds = true
                self.btnCaptureImage.layer.cornerRadius = self.btnCaptureImage.frame.height / 2
            }
        }
    }
    @IBOutlet weak var viewCamera: UIView! {
        didSet {
            self.viewCamera.frame = CGRect(x: 0, y: 0, width: CScreenWidth, height: CScreenHeight)
        }
    }
    @IBOutlet weak var btnFlash: UIButton!
    
    /**
     * Capture session for photo
     */
    var captureSession = AVCaptureSession()
    /**
     * Front camera
     */
    var frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    /**
     * Back camera
     */
    var backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    /**
     * Current device camera status like front or back
     */
    var currentCamera: AVCaptureDevice?
    /**
     * AVCapture PhotoOutput
     */
    var photoOutPut: AVCapturePhotoOutput?
    /**
     * AVCapture preview layer for camera to show camera view
     */
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    /**
     * Set the flash for camera
     */
    var flashMode: AVCaptureDevice.FlashMode = .auto
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    // crop setup
    var croppingStyle : CropViewCroppingStyle?
    var aspectRatioPreset : CropViewControllerAspectRatioPreset?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialization()
    }
}

// MARK:- Initialization
// MARK:-
extension PhotoCameraVC {
    private func initialization() {
        setupCaptureSession()
        currentCamera = AVCaptureDevice.default(for: .video)
        currentCamera = backCamera
        setupInput()
        setupOutput()
        self.hasFlashOrNot()
    }
}

// MARK:- AVCapturePhotoCapture Delegate methods
// MARK:-
extension PhotoCameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            
            let image = UIImage(data: imageData) ?? UIImage()
            
            let cropController = CropViewController(croppingStyle: self.croppingStyle ?? CropViewCroppingStyle.default, image: image)
            cropController.delegate = self
            cropController.aspectRatioPreset = aspectRatioPreset ?? CropViewControllerAspectRatioPreset.presetOriginal
            cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
            cropController.resetAspectRatioEnabled = false // When tapping 'reset', the aspect ratio will NOT be reset back to default
            
            self.present(cropController, animated: true, completion: nil)
        }
    }
}

// MARK:- Helper Methods
// MARK:- setup Capture Session
extension PhotoCameraVC {
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    // setup Input image
    func setupInput() {
        do {
            guard currentCamera != nil else {
                return
            }
            
            let input = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession = AVCaptureSession()
            guard captureSession.canAddInput(input) else {
                return
            }
            captureSession.addInput(input)
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreviewLayer?.connection?.videoOrientation = .portrait
            cameraPreviewLayer?.frame = viewCamera.frame
            guard cameraPreviewLayer != nil else {
                return
            }
            viewCamera.layer.addSublayer(cameraPreviewLayer!)
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    // setup Output image
    func setupOutput() {
        photoOutPut = AVCapturePhotoOutput()
        photoOutPut?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        photoOutPut?.isHighResolutionCaptureEnabled = true
        guard photoOutPut != nil else {
            return
        }
        guard captureSession.canAddOutput(photoOutPut!) else {
            return
        }
        captureSession.addOutput(photoOutPut!)
    }
    // switch To Front Camera
    func switchToFrontCamera() {
        if frontCamera?.isConnected == true {
            UIView.transition(with: self.viewCamera, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            captureSession.stopRunning()
            currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            setupInput()
            setupOutput()
        }
    }
    // switch To Back Camera
    func switchToBackCamera() {
        if backCamera?.isConnected == true {
            UIView.transition(with: self.viewCamera, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            captureSession.stopRunning()
            currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            setupInput()
            setupOutput()
        }
    }
    // flash on/off
    func hasFlashOrNot() {
        guard let isflash = currentCamera?.hasFlash else { return }
        btnFlash.isHidden = isflash ? false : true
    }
    
    func getSettings(flashMode: AVCaptureDevice.FlashMode) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        if currentCamera != nil {
            if currentCamera!.hasFlash {
                settings.flashMode = flashMode
            }
        }
        
        return settings
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
                if collection.localizedTitle == "All Photos" {
                    let asset = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    if asset.count > 0{
                        
                        if let image = asset.lastObject {
                            
                            if AlbumsVC.shared.maximumSelection == 1 {
                                AlbumsVC.shared.getAssetPath(assets: [image]) { (url,images) in
                                    MediaPicker.shared.delegate?.didFinishPickingItems(url)
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
                            }
                        }
                    }
                }
            })
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }
}

// MARK:- Action Events
// MARK:-
extension PhotoCameraVC {
    // image capture
    @IBAction func btnCaptureImageClicked(_ sender: UIButton) {
        guard let capturePhotoOutput = self.photoOutPut else {
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform.identity
            })
        }
        let settings = getSettings(flashMode: flashMode)
    
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = true
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
    // change camera Back/Front
    @IBAction func btnChangeCameraClicked(_ sender: UIButton) {
        guard let currentCameraInput: AVCaptureInput = captureSession.inputs.first else {
            return
        }
        
        if let input = currentCameraInput as? AVCaptureDeviceInput {
            if input.device.position == .back {
                switchToFrontCamera()
            } else if input.device.position == .front {
                switchToBackCamera()
            }
        }
        
        //...To check camera has flash or not
        self.hasFlashOrNot()
    }
    
    @IBAction func btnCancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnChangeFlashClicked(_ sender: UIButton) {
        guard currentCamera != nil else {
            return
        }
        if currentCamera!.hasFlash {
            btnFlash.isHidden = false
            switch btnFlash.tag {
            case 0:
                flashMode = .on
                btnFlash.tag = 1
                sender.setImage(UIImage(named: "camera-flash"), for: .normal)
            case 1:
                flashMode = .off
                btnFlash.tag = 2
                sender.setImage(UIImage(named: "flash-off"), for: .normal)
            case 2:
                flashMode = .auto
                btnFlash.tag = 0
                sender.setImage(UIImage(named: "automatic-flash"), for: .normal)
            default:
                flashMode = .auto
            }
        }
    }
}


//MARK:- CropViewControllerDelegate
//MARK:-
extension PhotoCameraVC: CropViewControllerDelegate {
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // save image
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        cropViewController.dismiss(animated: false) {
            
            guard let window = appWindow else {
                return
            }
            
            window.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
