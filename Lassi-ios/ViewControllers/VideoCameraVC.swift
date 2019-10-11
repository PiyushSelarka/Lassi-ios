//
//  VideoCameraVC.swift
//  MediaPicker
//
//  Created by mac-00015 on 01/06/19.
//  Copyright © 2019 mac-0002. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCameraVC: UIViewController {
    
    @IBOutlet weak var btnChangeCamera: UIButton!
    @IBOutlet weak var viewVideoCapture: UIView! {
        didSet {
            self.viewVideoCapture.frame = CGRect(x: 0, y: 0, width: CScreenWidth, height: CScreenHeight)
        }
    }
    @IBOutlet weak var btnCaptureVideo: UIButton! {
        didSet {
            CGCDMainThread.async {
                self.btnCaptureVideo.layer.masksToBounds = true
                self.btnCaptureVideo.layer.cornerRadius = self.btnCaptureVideo.frame.height / 2
            }
        }
    }
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var lblDuration: UILabel!
    
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
     * Video output instance
     */
    var videoOutput: AVCaptureVideoDataOutput?
    /**
     * Audio output instance
     */
    var audioOutput: AVCaptureAudioDataOutput?
    /**
     * Movie output data instance
     */
    var movieOutput = AVCaptureMovieFileOutput()
    /**
     * Preview layer for camera
     */
    var previewLayer: AVCaptureVideoPreviewLayer?
    /**
     * Set the flash for camera
     */
    var flashMode: AVCaptureDevice.FlashMode = .off
    /**
     * Set the AVCapture Device Input
     */
    var deviceInput: AVCaptureDeviceInput?
    /**
     * Set the max time for video
     */
    var maxTime = AlbumsVC.shared.maxTimeForVideo
    /**
     * Set the time counter
     */
    var counter = 1
    /**
     * timer
     */
    var timer = Timer()
    /**
     * camera set-up front or back Bool
     */
    var isFrontCamera = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // set-up video time, durication, camera
        counter = maxTime > 0 ? AlbumsVC.shared.maxTimeForVideo - 1 : 1
        lblDuration.isHidden = maxTime > 0 ? false : true
        self.lblDuration.text = stringFromInt(counter: maxTime)
        btnChangeCamera.isHidden = false
    }
}

// MARK:- Initialization
// MARK:-
extension VideoCameraVC {
    private func initialization() {
        // set-up camera view 
        currentCamera = AVCaptureDevice.default(for: .video)
        currentCamera = backCamera
        setupCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        previewLayer?.frame = viewVideoCapture.frame
        setupInput()
        setupOutput()
        
        //...To check camera has flash or not
        self.hasFlashOrNot()
    }
}

// MARK:- AVCaptureFileOutputRecordingDelegate
// MARK:-
extension VideoCameraVC: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            let videoPreviewVC = VideoPreviewVC(nibName: "VideoPreviewVC", bundle: appBundle)
            videoPreviewVC.videoURL = outputFileURL
            self.present(videoPreviewVC, animated: false, completion: nil)
        }
    }
}

// MARK:- set-up Capture Session Input
// MARK:-
extension VideoCameraVC {

    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }
    
    func setupInput() {
        //...set-up Video
        do {
            guard currentCamera != nil else {
                return
            }
            deviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            
            if let deviceInput = deviceInput {
                guard captureSession.canAddInput(deviceInput) else {
                    return
                }
                captureSession.addInput(deviceInput)
                
                guard viewVideoCapture != nil else {
                    return
                }
            }
            guard let previewLayer = previewLayer else { return }
            viewVideoCapture.layer.addSublayer(previewLayer)
            
            CGCDMainThread.async {
                self.captureSession.commitConfiguration()
                self.captureSession.startRunning()
            }
        } catch {
            print(error)
        }
        
        // Setup Microphone
        guard let microphone = AVCaptureDevice.default(for: .audio) else { return }
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
        }
    }
}

// MARK:- set-up Capture Session Output
// MARK:-
extension VideoCameraVC {
    
    func setupOutput() {
        //...Video Output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.recommendedVideoSettings(forVideoCodecType: .jpeg, assetWriterOutputFileType: .mp4)
        guard videoOutput != nil else {
            return
        }
        if captureSession.canAddOutput(videoOutput!) {
            captureSession.addOutput(videoOutput!)
        }
        //...Audio Output
        audioOutput = AVCaptureAudioDataOutput()
        audioOutput?.recommendedAudioSettingsForAssetWriter(writingTo: .m4a)
        guard audioOutput != nil else {
            return
        }
        if captureSession.canAddOutput(audioOutput!) {
            captureSession.addOutput(audioOutput!)
        }
        captureSession.addOutput(movieOutput)
    }
}

// MARK:- set-up Timer
// MARK:-
extension VideoCameraVC {
    
    // update timer
    @objc func UpdateTimer() {
        if counter > 0 {
            self.lblDuration.text = stringFromInt(counter: counter)
            self.counter -= 1
            btnCaptureVideo.tag = 1
        } else {
            self.stopTimer()
        }
    }
    // stop timer
    func stopTimer() {
        self.timer.invalidate()
        btnCaptureVideo.tag = 0
        counter = maxTime - 1
        self.lblDuration.text = "00:00"
        self.movieOutput.stopRecording()
        btnCaptureVideo.setImage(UIImage(), for: .normal)
        btnCaptureVideo.backgroundColor = .white
    }
}

// MARK:- set-up Camera front/back
// MARK:-
extension VideoCameraVC {
    
    private func switchToFrontCamera() {
        captureSession.beginConfiguration()
        if frontCamera?.isConnected == true {
            if let deviceInput = deviceInput {
                captureSession.removeInput(deviceInput)
            }
            currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            setupInput()
            UIView.transition(with: self.viewVideoCapture, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            
        }
    }
    
    private func switchToBackCamera() {
        captureSession.beginConfiguration()
        if backCamera?.isConnected == true {
            if let deviceInput = deviceInput {
                captureSession.removeInput(deviceInput)
            }
            currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            setupInput()
            UIView.transition(with: self.viewVideoCapture, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
}

// MARK:- set-up Flash light
// MARK:-
extension VideoCameraVC {
    
    func hasFlashOrNot() {
        guard let isflash = currentCamera?.hasFlash else { return }
        btnFlash.isHidden = isflash ? false : true
    }
    
    private func flashOn() {
        do {
            guard let isHasTorch = currentCamera?.hasTorch else { return }
            
            if isHasTorch {
                try currentCamera?.lockForConfiguration()
                currentCamera?.torchMode = .on
                flashMode = .on
                currentCamera?.unlockForConfiguration()
            }
            
        } catch {
            print("Device tourch Flash Error ")
        }
    }
    
    private func flashOff() {
        do {
            guard let isHasTorch = currentCamera?.hasTorch else { return }
            if isHasTorch {
                try currentCamera?.lockForConfiguration()
                currentCamera?.torchMode = .off
                flashMode = .off
                currentCamera?.unlockForConfiguration()
            }
        } catch {
            print("Device tourch Flash Error ")
        }
    }
}

//MARK:-
//MARK:- Action Events
extension VideoCameraVC {
    @IBAction func btnCaptureVideo(_ sender: UIButton) {
        btnChangeCamera.isHidden = true
        if sender.tag == 0 {
            sender.tag = 1
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent("output.mov")
            try? FileManager.default.removeItem(at: fileUrl)
            movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
            btnCaptureVideo.setImage(UIImage(named: "stop"), for: .normal)
            if maxTime > 1 {
               timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector (UpdateTimer), userInfo: nil, repeats: true)
            }
        } else {
            self.stopTimer()
        }
    }
    
    @IBAction func btnChangeCameraClicked(_ sender: UIButton) {
        guard let _: AVCaptureInput = captureSession.inputs.first else {
            return
        }
        
        isFrontCamera = isFrontCamera ? false : true
        isFrontCamera ? switchToBackCamera() : switchToFrontCamera()
        
        //...To check camera has flash or not
        self.hasFlashOrNot()
    }
    
    @IBAction func btnFlashClicked(_ sender: UIButton) {
        guard let isflash = currentCamera?.hasFlash else { return }
        
        if isflash {
            btnFlash.isHidden = false
            if btnFlash.tag > 1 {
                flashMode = .auto
                return
            }

            btnFlash.tag == 0 ? flashOn() : flashOff()
            btnFlash.tag = btnFlash.tag == 0 ? 1 : 0
            sender.setImage(UIImage(named: btnFlash.tag == 0 ? "camera-flash" : "flash-off"), for: .normal)
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        self.stopTimer()
        self.dismiss(animated: true, completion: nil)
    }
}
