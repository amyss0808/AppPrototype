//
//  TaskDetailViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/8.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MobileCoreServices
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import os.log
import CoreMotion


class TaskDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MKMapViewDelegate {

    // MARK: - Camera Properties
    let imagePicker = UIImagePickerController()
    var videoFilePath: String? = nil
    var videoId: String? = nil
    let motionManager = CMMotionManager()
    
    
    // MARK: - Task Properties
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDuration: UILabel!
    @IBOutlet weak var taskDistance: UILabel!
    @IBOutlet weak var executeTask: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var task: Task? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        
        guard let mytask = task else {
            fatalError("task is \(task)")
        }
        taskTitle.text = mytask.taskTitle
        taskDuration.text = mytask.taskDuration
        taskDistance.text = mytask.taskDistance
        
        configureMapView(for: mytask)
        loadStartEndPins(of: mytask)
        
        // disabel or enable + decorate "執行任務" UIButton
        if mytask.taskIsNear == false {
            executeTask.isEnabled = false
            executeTask.layer.cornerRadius = 4
            executeTask.setTitle("無法執行", for: .disabled)
            executeTask.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            
        } else {
            executeTask.isEnabled = true
            executeTask.layer.cornerRadius = 4
            executeTask.layer.shadowOffset = CGSize(width: -1, height: 1)
            executeTask.layer.shadowOpacity = 0.2
        }
    }
    
    
    
    // MARK: - Task Functions
    private func configureMapView(for task: Task) {
        let centerLatitude = (task.taskStartPointLatitude + task.taskEndPointLatitude)/2
        let centerLongitude = (task.taskStartPointLongitude + task.taskEndPointLongitude)/2
        let centerlocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(centerlocation, 550, 550)
        
        mapView.setRegion(region, animated: false)
    }
    
    
    private func loadStartEndPins(of task: Task) {
        let startPin = MKPointAnnotation()
        let endPin = MKPointAnnotation()
        startPin.coordinate.latitude = task.taskStartPointLatitude
        startPin.coordinate.longitude = task.taskStartPointLongitude
        endPin.coordinate.latitude = task.taskEndPointLatitude
        endPin.coordinate.longitude = task.taskEndPointLongitude
        
        mapView.addAnnotations([startPin, endPin])
        showRoute(from: startPin, to: endPin)
        
    }
    
    
    private func showRoute(from startPin: MKPointAnnotation, to endPin: MKPointAnnotation) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPin.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endPin.coordinate))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { response, error in
            guard let myresponse = response else {
                fatalError("request directions has errors: \(error)")
            }
            self.mapView.add(myresponse.routes[0].polyline)
        })
    }
    
    
    // Draws the route on the map using map overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: 42/255, green: 124/255, blue: 242/255, alpha: 1)
            polylineRenderer.lineWidth = 5;
            return polylineRenderer
            
        } else {
            return MKPolylineRenderer()
        }
    }
    
    
    
    
    // MARK: - Camera Functions
    @IBAction func executeTask(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.cameraFlashMode = .off
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                
                
//                let circle = UIButton(frame: CGRect(x: 177, y: 605, width: 20, height: 20))
//                circle.layer.cornerRadius = 10
//                circle.backgroundColor = UIColor(red: 42.0/255.0, green: 124.0/255.0, blue: 242.0/255.0, alpha: 1)
//                circle.addTarget(self, action: #selector(circleTapped), for: .touchUpInside)
//                
//                imagePicker.view.addSubview(circle)
                
                    
                present(imagePicker, animated: true, completion: {
                    
                    // MARK: test - not finished
                    self.motionManager.accelerometerUpdateInterval = 0.2
                    self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (accelerometerData, error) in
                        guard let myACData = accelerometerData else {
                            fatalError("accelerometerData : \(accelerometerData)")
                        }
                        print("\(myACData.acceleration.x),\(myACData.acceleration.y),\(myACData.acceleration.z)")
                    })
                })
            } else {
                
                // alert
                let alertNoRearCamera = UIAlertController(title: "No Rear Camera! ", message: "There is no rear camera on this device.", preferredStyle: .alert)
                alertNoRearCamera.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    print("There is no rear camera")
                }))
                
                self.present(alertNoRearCamera, animated: true, completion: nil)
            }
        } else {
            
            // alert
            let alertNoCamera = UIAlertController(title: "No Camera! ", message: "There is no camera on this device.", preferredStyle: .alert)
            alertNoCamera.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                print("There is no camera on this device")
            }))
            
            self.present(alertNoCamera, animated: true, completion: nil)
        }
    }
    
    
//    @objc private func circleTapped() {
//        print("hihi")
//    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            self.motionManager.stopAccelerometerUpdates()
            print("dismiss------------")
        })
    }
    
    
    // called when the user accepts a newly-captured movie
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.motionManager.stopAccelerometerUpdates()
        
        videoFilePath = ((info[UIImagePickerControllerMediaURL] as? NSURL)?.path)!
        
        // present videoEdit view controller
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
        guard let myVideoFilePath = videoFilePath else {
            fatalError("videoFilePath: \(videoFilePath)")
        }
        
        // Save video to the main photo album
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(myVideoFilePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(myVideoFilePath, self, #selector(self.callback(videoPath: didFinishSavingWithError:contextInfo:)), nil)
            
        } else {
            print("didn't save")
        }
    }
    
    
    // Upload a video after saving the video to photos album
    @objc private func callback(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        
        // first request server to get access token
        let url = "http://140.119.19.33:8080/SoslabProjectServer/getAccessToken"
        
        Alamofire.request(url, method: .post).validate().responseString(completionHandler: {
            (response) in
            switch response.result {
                
            case .success(let value):
                self.uploadVideo(accessToken: value, fileURL: URL(fileURLWithPath: videoPath as String))
                
            case .failure(let error):
                print("callback: \(error)")
            }
        })
    }
    
    
    private func uploadVideo(accessToken: String, fileURL: URL) {

        let url = "https://www.googleapis.com/upload/youtube/v3/videos?part=id"
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        Alamofire.upload(fileURL, to: url, method: .post, headers: headers).validate().responseJSON(completionHandler: { (response) in
            
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                self.videoId = json["id"].stringValue
                
                // MARK: - not finished
                // send video id to server
                guard let myVideoId = self.videoId else {
                    fatalError("videoId: \(self.videoId)")
                }
                
            
            case .failure(let error):
                print("Upload video: \(error)")
            }
        })
    }
    
    
    private func sendVideoData(videoId: String) {
        let url = "http://140.119.19.33:8080/SoslabProjectServer"
        let parameters = ["videoId": videoId, "taskId": self.task?.taskId]
    }
}
