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


class TaskDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {

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
    
    
    // MARK: - View Outlets
    @IBOutlet weak var taskDetailView: UIView!
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskDetailView.layer.cornerRadius = 6
        
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
        let startPin = StartEndPointAnnotation(position: .start)
        let endPin = StartEndPointAnnotation(position: .end)
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
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        
        switch annotation {
        case is StartEndPointAnnotation:
            guard let startEndPointAnnotation = annotation as? StartEndPointAnnotation else {
                fatalError("Unexpected annotation class: \(annotation)")
            }
            
            if startEndPointAnnotation.position == .start {
                reuseId = "startPointAnnotation"
                let startPointAnnotationView = self.setImage(for: startEndPointAnnotation, reuseId, with: "start pin")
                
                return startPointAnnotationView
                
            } else {
                reuseId = "endPointAnnotation"
                let endPointAnnotationView = self.setImage(for: startEndPointAnnotation, reuseId, with: "start pin")
                
                return endPointAnnotationView
            }
            
            
        default:
            return nil
        }
    }

    
    private func setImage(for annotation: MKAnnotation, _ reuseId: String, with imageName: String) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.image = UIImage(named: imageName)
            
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "videoCapture":
            guard let videoCaptureVC = segue.destination as? VideoCaptureViewController else {
                fatalError("The destination view controller: \(segue.destination) of this segue is not VideoCaptureViewController")
            }
            videoCaptureVC.taskId = self.task?.taskId
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}
