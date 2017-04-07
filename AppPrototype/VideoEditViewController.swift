//
//  VideoEditViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/7.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import os.log

class VideoEditViewController: UIViewController {
    
    // MARK: - Section Views
    @IBOutlet var sectionViews: [UIView]!
    @IBOutlet var sectionTitleViews: [UIView]!
    
    
    // MARK: - Navigation Properties
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    
    // MARK: - VideoEditVC Button Outlets
    @IBOutlet var publicFacilityBttns: [VideoEditVCButton]!
    @IBOutlet var storeBttns: [VideoEditVCButton]!
    @IBOutlet var weatherBttns: [VideoEditVCButton]!
    
    
    // MARK: - Video Info Properties
    var videoFilePath: String? = nil
    var videoId: String? = nil
    var taskId: String? = nil
    var weather: String = ""
    var stores: String = ""
    var publicFacilities: String = ""
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        decorateViews()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for bttn in publicFacilityBttns {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(String(describing: bttn.titleLabel?.text))")
                    return
                }
                self.publicFacilities = self.publicFacilities + bttnTitle + ","
            }
        }
        self.publicFacilities = String(self.publicFacilities.characters.dropLast())
        print(self.publicFacilities)
        
        
        for bttn in storeBttns {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(String(describing: bttn.titleLabel?.text))")
                    return
                }
                self.stores = self.stores + bttnTitle + ","
            }
        }
        self.stores = String(self.stores.characters.dropLast())
        print(self.stores)
        
        
        for bttn in weatherBttns {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(String(describing: bttn.titleLabel?.text))")
                    return
                }
                self.weather = self.weather + bttnTitle + ","
            }
        }
        self.weather = String(self.weather.characters.dropLast())
        print(self.weather)
    }
    
    
    private func decorateViews() {
        for section in sectionViews {
            section.layer.cornerRadius = 8
        }
        
        for sectionTitle in sectionTitleViews {
            sectionTitle.layer.cornerRadius = 6
        }
        
        finishButton.isEnabled = false
        finishButton.layer.cornerRadius = 4
        finishButton.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 1)
        
    }
    
    
    // MARK: - VideoEditVC Button Functions
    @IBAction func multipleChoiceBttnTapped(_ sender: VideoEditVCButton) {
        
        // default "isChoosed" = false
        if sender.isChoosed {
            sender.isChoosed = false
        } else {
            sender.isChoosed = true
        }
    }
    
    
    @IBAction func singleChoiceBttnTapped(_ sender: VideoEditVCButton) {
        
        // default "isChoosed" = false
        sender.isChoosed = true
        
        // enable finishButton
        finishButton.isEnabled = true
        finishButton.backgroundColor = UIColor(red: 75/255, green: 104/255, blue: 157/255, alpha: 1)
        finishButton.layer.cornerRadius = 4
        finishButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        finishButton.layer.shadowOpacity = 0.2
        
        // disable other buttons
        for bttn in weatherBttns {
            if bttn.tag != sender.tag {
                bttn.isChoosed = false
            }
        }
    }
    
    
    
    // MARK: - Navigation Actions & Functions
    @IBAction func finishEditing(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.saveVideoToAlbum()
        })
    }
    
    
    @IBAction func cancelEditing(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // not used now
    private func finishButtonShouldBeEnabled() -> Bool {
        var shouldEnable = false
        
        var count = 0
        for bttn in weatherBttns {
            if bttn.isChoosed == false {
                count += 1
            }
        }
        
        if count == weatherBttns.count {
            shouldEnable = true
        } else {
            shouldEnable = false
        }
        return shouldEnable
    }
    
    
    
    // MARK: - Server Functions
    private func saveVideoToAlbum() {
        guard let myVideoFilePath = videoFilePath else {
            fatalError("videoFilePath: \(String(describing: videoFilePath))")
        }
        
        // Save video to the main photo album
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(myVideoFilePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(myVideoFilePath, self, #selector(self.getAccessTokenToUpload(videoPath: didFinishSavingWithError:contextInfo:)), nil)
            
        } else {
            print("didn't save")
        }
    }
    
    
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
        
        let url = "https://www.googleapis.com/upload/youtube/v3/videos?part=id"
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        Alamofire.upload(fileURL, to: url, method: .post, headers: headers).validate().responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                self.videoId = json["id"].stringValue
                
                // send video id to server
                guard let myVideoId = self.videoId else {
                    fatalError("videoId: \(String(describing: self.videoId))")
                }
                guard let myTaskId = self.taskId else {
                    fatalError("taskId: \(String(describing: self.taskId))")
                }
                self.sendVideoData(taskId: myTaskId, videoId: myVideoId, stores: self.stores, weather: self.weather, publicFacilities: self.publicFacilities)
                
            case .failure(let error):
                print("Upload video: \(error)")
            }
        })
    }
    
    
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
