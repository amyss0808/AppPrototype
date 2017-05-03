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
import os.log

class TaskViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Map Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    let manager = CLLocationManager()
    
    
    
    // MARK: - Search Properties
    var resultSearchController: UISearchController? = nil
    var searchAnnotation = SearchAnnotation()
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareSearch()
        
        mapView.delegate = self
        containerView.isHidden = true
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        loadTaskPin()
        
        // decorate locationButton
        locationButton.layer.cornerRadius = 23
        locationButton.layer.shadowOffset = CGSize(width: 3.3, height: 3.3)
        locationButton.layer.shadowOpacity = 0.3
        locationButton.imageEdgeInsets = UIEdgeInsetsMake(11,11,11,11)
        
        // disable userlocation pin view
        mapView.userLocation.title = ""
        
        // change navigation back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
    }
    
    
    
    // MARK: - Search Functions
    private func prepareSearch() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = mapView
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "請輸入街道名或地標"
        navigationItem.titleView = resultSearchController?.searchBar
       
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.handleMapSearchDelegate = self
        resultSearchController?.searchBar.delegate = self
    }

    
    
    
    
    
    // MARK: - Map functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[locations.count-1]
        let latitude: CLLocationDegrees = userLocation.coordinate.latitude
        let longitude: CLLocationDegrees = userLocation.coordinate.longitude
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.0025, 0.0025)
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
                print("---Connecting to TASK server success---")
                
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
                print("---Didn't get task list because: \(error)---")
            }
        })
    }
    
    
    
    // whether the selected taskpin is near user or not
    private func isNear(_ taskPin: TaskPointAnnotation) -> Bool {
        var isNear = false
        
        let pinLocation = CLLocation(latitude: taskPin.coordinate.latitude, longitude: taskPin.coordinate.longitude)

        let userLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        
        let distance = pinLocation.distance(from: userLocation)
        
        if distance < 2000000 {
            isNear = true
        } else {
            isNear = false
        }
        
        return isNear
    }
    
    
    
    private func createAlert() {
        let farAlert = UIAlertController(title: "Task is too far!", message: "You cannot execute the task.", preferredStyle: .alert)
        
        farAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            print("yes is too far")
        }))
        self.present(farAlert, animated: true, completion: nil)
    }

    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        switch view.annotation {
            
        case is TaskPointAnnotation:
            guard let selectedAnnotation = view.annotation as? TaskPointAnnotation else {
                fatalError("The selected pin annotation cannot be downcast")
            }
            
            guard let subviewController = self.childViewControllers[0] as? TaskContainerViewController else {
                fatalError("The first child view controller of taskViewController is not a container view controller")
            }
            
            // change image of selected pin
            view.image = UIImage(named: "selected taskpin")
            
            
            // load task info on the container view
            let isNear = self.isNear(selectedAnnotation)
            subviewController.loadTaskDetail(of: selectedAnnotation.id, isNear: isNear)
            
            
            if isNear == false {
                createAlert()
            }
            
            containerView.isHidden = false
            
        default:
            print("The selected pin is not a TaskPointAnnotation")
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        switch view.annotation {
            
        case is TaskPointAnnotation:
            view.image = UIImage(named: "taskpin")
            containerView.isHidden = true
            
        default:
            print("The deselected pin is not a TaskPointAnnotation")
        }
    }
    
    
    // called when add annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        switch annotation {
            
        case is SearchAnnotation:
            reuseId = "searchAnnotationView"
            var searchAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if searchAnnotationView == nil {
                searchAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                searchAnnotationView?.image = UIImage(named: "pin")
                
            } else {
                searchAnnotationView?.annotation = annotation
            }
            
            return searchAnnotationView
            
        case is TaskPointAnnotation:
            reuseId = "taskPointAnnotationView"
            var taskPointAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            
            if taskPointAnnotationView == nil {
                taskPointAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                taskPointAnnotationView?.image = UIImage(named: "taskpin")
                
            } else {
                taskPointAnnotationView?.annotation = annotation
            }
            
            return taskPointAnnotationView
            
        default:
            return nil
        }
    }
}






// MARK: - HandleMapSearch Protocal Implement
extension TaskViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        
        // clear existing pins
        self.mapView.removeAnnotation(self.searchAnnotation)
        
        let searchAnnotation = SearchAnnotation()
        searchAnnotation.coordinate = placemark.coordinate
        self.searchAnnotation = searchAnnotation
        
        self.mapView.addAnnotation(searchAnnotation)
        
        let span = MKCoordinateSpanMake(0.025, 0.025)
        let region = MKCoordinateRegionMake(searchAnnotation.coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
    }
}




// MARK: - UISearchBarDelegate Implement
extension TaskViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let result = resultSearchController?.searchResultsController as? LocationSearchTable else{
            fatalError("Unexpected search result controller \(String(describing: resultSearchController?.searchResultsController))")
        }
        let matchItems = result.matchingItems
        
        self.dropPinZoomIn(placemark: matchItems[0].placemark)
        
        self.dismiss(animated: true, completion: nil)
    }
}
