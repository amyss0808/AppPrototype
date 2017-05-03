//
//  VideoPlaybackViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/23.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON
import os.log

class VideoPlaybackViewController: UIViewController {
    
    // MARK: Playback View Properties
    @IBOutlet weak var playbackView: PlayerView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var finishButton: UIBarButtonItem!
    
    
    static let assetKeysRequiredToPlay = ["playable", "hasProtectedContent"]
    let player = AVPlayer()

    var fileLocation: URL? {
        didSet {
            self.asset = AVURLAsset(url: self.fileLocation!)
        }
    }
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else {
                return
            }
            self.loadURLAsset(newAsset)
        }
    }
    var playerItem: AVPlayerItem? {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
            player.actionAtItemEnd = .none
        }
    }
    var playerLayer: AVPlayerLayer {
        get {
            return playbackView.playerLayer
        }
    }
    
    
    
    
    // MARK: - Section Views
    @IBOutlet var sectionViews: [UIView]!
    @IBOutlet var sectionTitleViews: [UIView]!
    
    
    
    
    // MARK: - Video Edit Button Outlets
    @IBOutlet var weatherButtons: [VideoEditVCButton]!
    @IBOutlet var storeButtons: [VideoEditVCButton]!
    @IBOutlet var publicFacilityButtons: [VideoEditVCButton]!
    
    
    
    
    // MARK: - Video Properties
    var taskId: String?
    var videoId: String?
    var weather: String = ""
    var stores: String = ""
    var publicFacilities: String = ""
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        decorateViews()
        
        self.playbackView.playerLayer.player = player
        
        addObserver(self, forKeyPath: "player.currentItem.status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerReachedEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver(self, forKeyPath: "player.currentItem.status")
        dealWithSelectedButton()
    }
    
    
    private func decorateViews() {
        for view in self.sectionViews {
            view.layer.cornerRadius = 8
            view.layer.shadowOffset = CGSize(width: -1, height: 1)
            view.layer.shadowOpacity = 0.2
        }
    }
    
    
    private func dealWithSelectedButton() {
        for bttn in self.weatherButtons {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(bttn.titleLabel?.text)")
                    return
                }
                self.weather = self.weather + bttnTitle + ","
            }
        }
        self.weather = String(self.weather.characters.dropLast())
        print(self.weather)
        
        
        for bttn in self.storeButtons {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(bttn.titleLabel?.text)")
                    return
                }
                self.stores = self.stores + bttnTitle + ","
            }
        }
        self.stores = String(self.stores.characters.dropLast())
        print(self.stores)
        
        
        for bttn in self.publicFacilityButtons {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(bttn.titleLabel?.text)")
                    return
                }
                self.publicFacilities = self.publicFacilities + bttnTitle + ","
            }
        }
        self.publicFacilities = String(self.publicFacilities.characters.dropLast())
        print(self.publicFacilities)
    }
    
    
    
    
    
    // MARK: - Video Edit Button Functions
    @IBAction func weatherButtonSelected(_ sender: VideoEditVCButton) {
        sender.isChoosed = true
        self.finishButton.isEnabled = true
        
        for bttn in self.weatherButtons {
            if bttn.tag != sender.tag {
                bttn.isChoosed = false
            }
        }
    }
    
    @IBAction func storeButtonSelected(_ sender: VideoEditVCButton) {
        
        // default: isChoosed == false
        if sender.isChoosed == true {
            sender.isChoosed = false
        } else {
            sender.isChoosed = true
        }
    }
    
    @IBAction func publicFacilityButtonSelected(_ sender: VideoEditVCButton) {
        
        // default: isChoosed == false
        if sender.isChoosed == true {
            sender.isChoosed = false
        } else {
            sender.isChoosed = true
        }
    }
    
    
    
    
    

    // MARK: - Video Playback Functions
    func loadURLAsset(_ asset: AVURLAsset) {
        asset.loadValuesAsynchronously(forKeys: VideoPlaybackViewController.assetKeysRequiredToPlay, completionHandler: {
            DispatchQueue.main.async {
                guard asset == self.asset else {
                    return
                }
                for key in VideoPlaybackViewController.assetKeysRequiredToPlay {
                    var error: NSError?
                    
                    if !asset.isPlayable || asset.hasProtectedContent {
                        // alert
                        print("video is not playable")
                        return
                    }
                    
                    if asset.statusOfValue(forKey: key, error: &error) == .failed {
                        // alert
                        print("failed to load")
                        return
                    }
                }
                self.playerItem = AVPlayerItem(asset: asset)
            }
        })
    }
    
    
    
    
    // MARK: - Video Playback button Functions
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        self.updatePlayPauseButtonImage()
    }
    
    
    @IBAction func finishButtonTapped(_ sender: UIBarButtonItem) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
            self.saveVideoToUserLibrary()
        })
    }
    
    
    @IBAction func retakeVideoButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    func updatePlayPauseButtonImage() {
        if self.player.rate > 0 {
            // playing
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            
        } else {
            // paused or stopped
            self.player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    
    func saveVideoToUserLibrary() {
        guard let myFileLocation = self.fileLocation?.path else {
            fatalError("video fileLocation: \(self.fileLocation?.path)")
        }
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(myFileLocation) {
            print("\(myFileLocation)")
            
            UISaveVideoAtPathToSavedPhotosAlbum(myFileLocation, self, #selector(self.getAccessTokenToUpload(videoPath: didFinishSavingWithError:contextInfo:)), nil)
        } else {
            print("didn't save")
        }
    }
    
    
    
    
    // MARK: - Observer Functions
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "player.currentItem.status" {
            self.playPauseButton.isHidden = false
        }
    }
    
    
    func playerReachedEnd(notification: NSNotification) {
        // restart video
        self.asset = AVURLAsset(url: self.fileLocation!)
    }
    
    
    
    
    
    // MARK: - Server Functions
    // Upload a video after saving the video to photos album
    @objc private func getAccessTokenToUpload(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        
        // first request server to get access token
        let url = "http://140.119.19.33:8080/SoslabProjectServer/getAccessToken"
        
        Alamofire.request(url, method: .post).validate().responseString(completionHandler: {
            response in
            switch response.result {
                
            case .success(let accessToken):
                self.uploadVideo(by: accessToken, from: URL(fileURLWithPath: videoPath as String))
                
            case .failure(let error):
                print("callback: \(error)")
            }
        })
    }

    
    private func uploadVideo(by accessToken: String, from fileURL: URL) {
        
        let url = "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet"
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        Alamofire.upload(fileURL, to: url, method: .post, headers: headers).validate().responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                print(value)
                let json = JSON(value)
                self.videoId = json["id"].stringValue
                print("\(self.videoId)")
                
                // send video id to server
                guard let myVideoId = self.videoId else {
                    fatalError("videoId: \(self.videoId)")
                }
                guard let myTaskId = self.taskId else {
                    fatalError("taskId: \(self.taskId)")
                }
                self.sendVideoData(taskId: myTaskId, videoId: myVideoId, stores: self.stores, weather: self.weather, publicFacilities: self.publicFacilities)
                
            case .failure(let error):
                print("Upload video: \(error)")
            }
        })
    }
    
    
//    private func updateVideoData(_ videoId: String, by accessToken: String) {
//        
//        let url = "https://www.googleapis.com/youtube/v3/videos?part=snippet"
//        let headers = ["Authorization": "Bearer \(accessToken)"]
//        
//        Alamofire.request(url, method: .put, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: headers)
//    }
    
    
    private func sendVideoData(taskId: String, videoId: String, stores: String, weather: String, publicFacilities: String) {
        
        let url = "http://140.119.19.33:8080/SoslabProjectServer/saveTask"
        let parameters = ["id": taskId, "youtubeId": videoId, "shop": stores, "weather": weather, "facility": publicFacilities]
        
        Alamofire.request(url, method: .post, parameters: parameters).validate().responseString(completionHandler: {
            response in
            
            switch response.result {
                
            case .success(let value):
                print("\(value)")
                
            case .failure(let error):
                print("Send Video Data: \(error)")
                
            }
        })
    }
}

extension ParameterEncoding {
    
//    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//        var request = try urlRequest.asURLRequest()
//        request.httpBody = data(using: .utf8, allowLossyConversion: false)
//        return request
//    }
}
