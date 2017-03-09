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


class TaskDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MKMapViewDelegate {

    // MARK: - Camera Properties
    let imagePicker = UIImagePickerController()
    var videoFilePath: String = ""
    var videoId: String = ""
    
    
    // MARK: - Task Properties
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDuration: UILabel!
    @IBOutlet weak var taskDistance: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var task: Task? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mytask = task else {
            fatalError("task is \(task)")
        }
        taskTitle.text = mytask.taskTitle
        taskDuration.text = mytask.taskDuration
        taskDistance.text = mytask.taskDistance
        
        let centerLatitude = (mytask.taskStartPointLatitude + mytask.taskEndPointLatitude)/2
        let centerLongitude = (mytask.taskStartPointLongitude + mytask.taskEndPointLongitude)/2
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.0025, 0.0025)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        
        loadStartEndPins(of: mytask)
    }
    
    
    
    // MARK: - Task Functions
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
        directions.calculate(completionHandler: { [unowned self] response, error in
            guard let myresponse = response else {
                fatalError("request directions has errors: \(error)")
            }
            self.mapView.add(myresponse.routes[0].polyline)
        })
        
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
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
}
