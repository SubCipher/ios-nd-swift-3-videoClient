//
//  VideoClientPlaybackViewController.swift
//  VideoClient
//
//  Created by Krishna Picart on 6/10/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


var newVideo: VideoClientDataModel.videos!

class VideoClientPlaybackViewController: UIViewController {
    
    let videoDataModel = VideoClientDataModel.sharedInstance()
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var outputURL: URL!
    var enableSaveButton: Bool!
    
    @IBOutlet weak var saveVideoOutlet: UIButton!
    @IBOutlet weak var playbackMode: UILabel!
    @IBOutlet weak var videoPlaybackView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        if enableSaveButton == false {
            saveVideoOutlet.isEnabled = enableSaveButton
        }
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        playVideoItem()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        avPlayerLayer.frame =  view.bounds
        videoPlaybackView.layer.insertSublayer(avPlayerLayer, at: 0)
    }
    
    @IBAction func playBackVideo(_ sender: UIButton) {
        
        playVideoItem()
    }
    
    func playVideoItem(){
        
        playbackMode.isHidden = false
        
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let playerItem = AVPlayerItem(url: outputURL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    @IBAction func saveVideo(_ sender: UIButton) {
        saveNewVideo()
    }
    
    func generateThumbnailForVideoAtURL(filePathLocal: URL) -> UIImage? {
        
        let asset = AVURLAsset(url: filePathLocal)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let thumbnailGen = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: thumbnailGen)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func createVideoURL() {
        // Save the movie file to photos library
        
        PHPhotoLibrary.shared().performChanges({
            
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = false
            
               
            //MARK:- Create video file

            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .video, fileURL:  self.outputURL as URL, options: options)
            
        }, completionHandler: { success, error in
            if !success {
                print("Could not save video to photo library: ",error?.localizedDescription ?? "error code not found: SaveToPhotoLibrary")
                
                return
            }
        }
            
        )}
    
    
    func createThumbNail(){
        
        let newThumbNailFromFile = self.generateThumbnailForVideoAtURL(filePathLocal: self.outputURL)!
        
        newVideo = VideoClientDataModel.videos.init(videoURL: self.outputURL, videoThumbnail: newThumbNailFromFile)
        let actionSheet = UIAlertController(title: "Success", message: "Your File Was Saved To Local Device", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(actionSheet,animated: true, completion: nil)
        
        self.saveVideoOutlet.isEnabled = false
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Save video func
    func saveNewVideo() {
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                
                DispatchQueue.main.async {
                    
                    guard VideoClientDataModel.sharedInstance().videoClientArray.isEmpty  else {
                        
                        self.createVideoURL()
                        self.createThumbNail()
                        
                        for videoClientCheck in VideoClientDataModel.sharedInstance().videoClientArray {
                            
                            guard videoClientCheck.videoURL == newVideo.videoURL else {
                                
                                VideoClientDataModel.sharedInstance().videoClientArray.append(newVideo)
                                return
                            }
                            let actionSheet = UIAlertController(title: "Duplication", message: "Copy of file already exists", preferredStyle: .alert)
                            
                            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            self.present(actionSheet,animated: true, completion: nil)
                            
                            return
                        }
                        return
                    }
                    
                    self.createVideoURL()
                    self.createThumbNail()
                    VideoClientDataModel.sharedInstance().videoClientArray.append(newVideo)
                    
                    return
                }
            }
        }
    }
}
