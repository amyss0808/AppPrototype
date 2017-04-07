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
import os.log
import CoreMotion


class TaskDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MKMapViewDelegate {

    // MARK: - Camera Properties
    let imagePicker = UIImagePickerController()
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
            fatalError("task is \(String(describing: task))")
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
                fatalError("request directions has errors: \(String(describing: error))")
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
            
                present(imagePicker, animated: true, completion: {
                    
                    // MARK: test - not finished
                    self.motionManager.accelerometerUpdateInterval = 0.2
                    self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (accelerometerData, error) in
                        guard let myACData = accelerometerData else {
                            fatalError("accelerometerData : \(String(describing: accelerometerData))")
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
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            self.motionManager.stopAccelerometerUpdates()
            print("dismiss------------")
        })
    }
    
    
    // called when the user accepts a newly-captured movie
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.motionManager.stopAccelerometerUpdates()
        
        // dismiss imagepicker & present videoEdit view controller
        let videoEditor = self.storyboard?.instantiateViewController(withIdentifier: "videoEditor") as! VideoEditViewController
        
        self.dismiss(animated: true, completion: nil)
        self.present(videoEditor, animated: true, completion: {
            videoEditor.videoFilePath = ((info[UIImagePickerControllerMediaURL] as? NSURL)?.path)!
            videoEditor.taskId = self.task?.taskId
        })
    }
}
