//
//  MediaPicker.swift
//  MediaPicker
//
//  Created by mac-00015 on 01/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import Foundation
import Photos
import PhotosUI
import MediaPlayer
import CropViewController

// MARK:- Protocol
// MARK:-
protocol MediaPickerDelegate: class {
    func didFinishPickingItems(_ path: [URL])
}

final class MediaPicker {
    
    private static var mediaPicker: MediaPicker = {
        let mediaPicker = MediaPicker()
        return mediaPicker
    }()
    static var shared: MediaPicker {
        return mediaPicker
    }
    
    weak var delegate: MediaPickerDelegate?
}

// MARK:- Declare file extension and enum
// MARK:-
extension MediaPicker {
    enum LassiOption {
        case CAMERA_AND_GALLERY, CAMERA, GALLERY
    }
    enum MediaType {
        case IMAGE, VIDEO, AUDIO, DOC
    }
    
    enum MediaFormat {
        case PNG
        case JPEG
        case JPG
        case GIF
        case HEIC
        case MPEG4
        case MOV
        case MP4
        case THREEGP
        case QUICKTime
        case AC3
        case AIFC
        case ARM
        case AIFF
        case WAV
        case AU
        case M4A
        case EAC3
        case CAF
        case MKV
        case AVI
        
        var formatValue: String {
            switch self {
            case .PNG:
                return "public.png"
            case .JPEG:
                return "public.jpeg"
            case .JPG:
                return "public.jpg"
            case .GIF:
                return "com.compuserve.gif"
            case .HEIC:
                return "public.heic"
            case .MPEG4:
                return "public.mpeg-4"
            case .MOV:
                return "public.mov"
            case .MP4:
                return "public.mp4"
            case .THREEGP:
                return "public.3gpp"
            case .QUICKTime:
                return "com.apple.quicktime-movie"
            case .AC3:
                return "public.ac3-audio"
            case .AIFC:
                return "public.aifc-audio"
            case .ARM:
                return "org.3gpp.adaptive-multi-rate-audio"
            case .AIFF:
                return "public.aiff-audio"
            case .WAV:
                return "com.microsoft.waveform-audio"
            case .AU:
                return "public.au-audio"
            case .M4A:
                return "com.apple.m4a-audio"
            case .EAC3:
                return "public.enhanced-ac3-audio"
            case .CAF:
                return "com.apple.coreaudio-format"
            case .MKV:
                return "com.microsoft.advanced-​systems-format"
            case .AVI:
                return "public.avi"
            }
        }
    }
}

// MARK:- Fatch Media
// MARK:-
extension MediaPicker {
    
    func fetchMedia(
        optionType : MediaPicker.LassiOption,
        maxCount: Int = 1,
        gridSize: Int = 2,
        toolbarColor: UIColor = UIColor.red,
        toolbarIconColor: UIColor = UIColor.white,
        toolbarTextColor: UIColor = UIColor.black,
        mediaType: MediaPicker.MediaType,
        statusBarColor: UIColor = UIColor.clear,
        supportedFileType: [MediaPicker.MediaFormat] = [],
        setCropType: CropViewCroppingStyle,
        setCropAspectRatio : CropViewControllerAspectRatioPreset,
        minTime: Int = 5,
        maxTime: Int = 0,
        enableCamera: Bool = false
        ) {
        
        switch mediaType {
            
        case .IMAGE, .VIDEO:
            
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                AlbumsVC.shared.configure(
                    optionType: optionType,
                    maxCount: maxCount,
                    gridSize: gridSize,
                    toolbarColor: toolbarColor,
                    toolbarIconColor: toolbarIconColor,
                    mediaType: mediaType,
                    statusBarColor: statusBarColor,
                    supportedFileType: supportedFileType,
                    setCropType: setCropType,
                    setCropAspectRatio: setCropAspectRatio,
                    minTime: minTime,
                    maxTime: maxTime,
                    enableCamera: enableCamera
                )
            } else {
                PHPhotoLibrary.requestAuthorization { (newStatus) in
                    if newStatus == .authorized {
                        AlbumsVC.shared.configure(
                            optionType: optionType,
                            maxCount: maxCount,
                            gridSize: gridSize,
                            toolbarColor: toolbarColor,
                            toolbarIconColor: toolbarIconColor,
                            mediaType: mediaType,
                            statusBarColor: statusBarColor,
                            supportedFileType: supportedFileType,
                            setCropType: setCropType,
                            setCropAspectRatio: setCropAspectRatio,
                            minTime: minTime,
                            maxTime: maxTime,
                            enableCamera: enableCamera
                        )
                    }
                }
            }
        case .AUDIO:
            if MPMediaLibrary.authorizationStatus() == .authorized {
                AlbumsVC.shared.configure(
                    optionType: optionType,
                    maxCount: maxCount,
                    gridSize: gridSize,
                    toolbarColor: toolbarColor,
                    toolbarIconColor: toolbarIconColor,
                    mediaType: mediaType,
                    statusBarColor: statusBarColor,
                    supportedFileType: supportedFileType,
                    setCropType: setCropType,
                    setCropAspectRatio: setCropAspectRatio,
                    minTime: minTime,
                    maxTime: maxTime,
                    enableCamera: enableCamera
                )
                
            } else {
                
                AlbumsVC.shared.configure(
                    optionType: optionType,
                    maxCount: maxCount,
                    gridSize: gridSize,
                    toolbarColor: toolbarColor,
                    toolbarIconColor: toolbarIconColor,
                    mediaType: mediaType,
                    statusBarColor: statusBarColor,
                    supportedFileType: supportedFileType,
                    setCropType: setCropType,
                    setCropAspectRatio: setCropAspectRatio,
                    minTime: minTime,
                    maxTime: maxTime,
                    enableCamera: enableCamera
                )
            }
        
        case .DOC:
            AlbumsVC.shared.configure(
                optionType: optionType,
                maxCount: maxCount,
                gridSize: gridSize,
                toolbarColor: toolbarColor,
                toolbarIconColor: toolbarIconColor,
                mediaType: mediaType,
                statusBarColor: statusBarColor,
                supportedFileType: supportedFileType,
                setCropType: setCropType,
                setCropAspectRatio: setCropAspectRatio,
                minTime: minTime,
                maxTime: maxTime,
                enableCamera: enableCamera
            )
        }
    }
}

