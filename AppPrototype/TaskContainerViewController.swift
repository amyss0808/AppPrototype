//
//  TaskContainerViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/7.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import SwiftyJSON
import os.log

class TaskContainerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Camera Properties
    let imagePicker = UIImagePickerController()
    var videoFilePath: String = ""
    var videoId: String = ""
    
    
    // MARK: - Task Detail Properties
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDuration: UILabel!
    @IBOutlet weak var taskDistance: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Camera functions
    @IBAction func executeTask(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: {})
            } else {
                // alert
                print("There is no rear camera")
            }
        } else {
            // alert
            print("There is no camera on this device")
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {})
    }

    
    // For responding to the user accepting a newly-captured movie
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoFilePath = ((info[UIImagePickerControllerMediaURL] as? NSURL)?.path)!
        
        let videoEditor = self.storyboard?.instantiateViewController(withIdentifier: "videoEditor") as! VideoEditViewController
        
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 375, height: 64))
        videoEditor.view.addSubview(navBar)
        let navItem = UINavigationItem(title: "編輯")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneEditing))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditing))
        navItem.rightBarButtonItem = doneItem
        navItem.leftBarButtonItem = cancelItem
        navBar.setItems([navItem], animated: false)
        
        imagePicker.present(videoEditor, animated: true, completion: {})
    }
    
    
    @objc private func doneEditing() {
        self.dismiss(animated: true, completion: {
            self.saveVideoToAlbum()
        })
    }
    
    @objc private func cancelEditing() {
        self.dismiss(animated: true, completion: {})
    }
    
    
    private func saveVideoToAlbum() {
        if !videoFilePath.isEmpty {
            
            // Save video to the main photo album
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(videoFilePath, self, #selector(self.callback(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                
            } else {
                print("didn't save")
            }
            
        } else {
            print("videoFilePath is empty")
        }
    }
    
    
    // Upload a video after saving the video to photos album
    @objc private func callback(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        let url = "http://140.119.19.33:8080/SoslabProjectServer/getAccessToken"
        
        Alamofire.request(url, method: .post).validate().responseString(completionHandler: {
            (response) in
            switch response.result {
                
            case .success(let value):
                self.videoId = self.uploadVideo(accessToken: value, fileURL: URL(fileURLWithPath: self.videoFilePath))
                
            case .failure(let error):
                print("callback: \(error)")
            }
        })
    }
    
    
    private func uploadVideo(accessToken: String, fileURL: URL) -> String {
        print(self.videoFilePath)
        let url = "https://www.googleapis.com/upload/youtube/v3/videos?part=id"
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        Alamofire.upload(fileURL, to: url, method: .post, headers: headers).validate().responseJSON(completionHandler: { (response) in
            
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                self.videoId = json["id"].stringValue
                
                // send video id to server
                if !self.videoId.isEmpty {
                    print(self.videoId)
                } else {
                    print("Video Id is empty")
                }
                
            case .failure(let error):
                print("Upload video: \(error)")
            }
        })
        return videoId
    }

    
    
    // MARK: - Task Detail functions
    func loadTaskDetail(of taskId: Int) {
        let url = "http://140.119.19.33:8080/SoslabProjectServer/task/\(taskId)"
        
        Alamofire.request(url, method: .get).validate().responseJSON(completionHandler: { response in
            switch response.result {
            
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.taskDistance.text = json["distance"].stringValue
                self.taskTitle.text = json["title"].stringValue.components(separatedBy: "_")[0]
                self.taskDuration.text = json["duration"].stringValue
            
            case .failure(let error):
                print("load task detail error because: \(error)")
            }
        })

    }
}
