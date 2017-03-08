//
//  TaskViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/6.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import CoreLocation

class TaskViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerView: UIView!
    
    let manager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        containerView.isHidden = true

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        loadTaskPin()
    }
    
    
    
    // MARK: - Map functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[locations.count-1]
        let latitude: CLLocationDegrees = userLocation.coordinate.latitude
        let longitude: CLLocationDegrees = userLocation.coordinate.longitude
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: false)
        manager.stopUpdatingLocation()
    }
    
    
    @IBAction func getUserLocation(_ sender: UIButton) {
        manager.startUpdatingLocation()
    }
    
    
    
    // MARK: - Pin functions
    func loadTaskPin() {
        var taskPinList = [TaskPointAnnotation]()
        let url = "http://140.119.19.33:8080/SoslabProjectServer/taskLocationList"
        
        Alamofire.request(url, method: .get).validate().responseJSON(completionHandler: { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                
                for (_, subJson):(String, JSON) in json {
                    let taskPin = TaskPointAnnotation()
                    taskPin.id = subJson["id"].intValue
                    taskPin.address = subJson["address"].stringValue
                    taskPin.coordinate.latitude = subJson["lat"].doubleValue
                    taskPin.coordinate.longitude = subJson["lng"].doubleValue
                    
                    taskPinList.append(taskPin)
                }
                
                // load pin to map
                self.mapView.addAnnotations(taskPinList)

                
            case .failure(let error):
                print("didn't get task list because: \(error)")
            }
        })
    }

    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        containerView.isHidden = false
        if view as TaskPointAnnotation {
            <#code#>
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        containerView.isHidden = true
    }

}
