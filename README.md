# Lassi-ios

//
//  ViewController.swift
//  MediaPicker
//
//  Created by mac-00015 on 01/06/19.
//  Copyright © 2019 mac-00015. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {

@IBOutlet weak var lblfilePath: UILabel!

override func viewDidLoad() {
super.viewDidLoad()
// delegate
MediaPicker.shared.delegate = self
}

}
// Get Media file url (Image, Audio, Video, Document)\
extension ViewController: MediaPickerDelegate {
// deleget func
func didFinishPickingItems(_ path: [URL]) {
lblfilePath.text = "\(path)"
print(path)
}
}


// MARK:- Action Events
// MARK:-
extension ViewController {
@IBAction func btnShowVideosClicked(_ sender: UIButton) {
MediaPicker.shared.fetchMedia(
optionType : MediaPicker.LassiOption.CAMERA_AND_GALLERY, // choose Option CAMERA, GALLERY or CAMERA_AND_GALLERY
maxCount: 2, // Maximum pick count
gridSize: 2, // Grid size 2 to 4
toolbarColor: .red, // toolbar color set
toolbarIconColor: .white, // toolbar icone color set
mediaType: .VIDEO, // MediaType : VIDEO IMAGE, AUDIO OR DOC
supportedFileType: [], // [.MOV,.GIF,.PNG] Filter by limited media format (Optional)
setCropType: .circular, // choose shape for cropping after capturing an image from camera (for mediaType.IMAGE only)
setCropAspectRatio: .presetOriginal, // define crop aspect ratio for cropping after capturing an image from camera (for MediaType.IMAGE only)
minTime: 0, // for MediaType.VIDEO only / minTime in second
maxTime: 200, // for MediaType.VIDEO only / maxTime in second
enableCamera: true // Enable camera
)
}

@IBAction func btnShowPhotosClicked(_ sender: UIButton) {
MediaPicker.shared.fetchMedia(
optionType: MediaPicker.LassiOption.CAMERA_AND_GALLERY,
maxCount: 1,
gridSize: 4,
toolbarColor: .red,
toolbarIconColor: .white,
mediaType: .IMAGE,
supportedFileType: [],
setCropType: .circular,
setCropAspectRatio: .presetOriginal,
minTime: 0,
enableCamera: true
)
}
@IBAction func btnShowAudioClicked(_ sender: UIButton) {
MediaPicker.shared.fetchMedia(
optionType: MediaPicker.LassiOption.GALLERY,
maxCount: 1,
gridSize: 4,
toolbarColor: .red,
toolbarIconColor: .white,
mediaType: .AUDIO,
supportedFileType: [],
setCropType: .default,
setCropAspectRatio: .presetOriginal,
minTime: 0,
enableCamera: true
)
}
@IBAction func btnDocClicked(_ sender: UIButton) {
MediaPicker.shared.fetchMedia(
optionType: MediaPicker.LassiOption.GALLERY,
maxCount: 5,
gridSize: 4,
toolbarColor: .red,
toolbarIconColor: .white,
mediaType: .DOC,
supportedFileType: [],
setCropType: .default,
setCropAspectRatio: .presetOriginal,
minTime: 0,
enableCamera: true
)
}
}

