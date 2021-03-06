//
//  HouseViewController.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/24.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

//MARK: - HandleMapSearch Protocal
protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

//MARK: - HouseViewController Class
class HouseViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    
    // for annotation and cluster
    var annotationList = [Annotation]()
    let clusteringManager = ClusteringManager()
    
    let locationManager = CLLocationManager()
    
    // for select house
    var constraintParameter: Dictionary<String, String> = [:]
    {
        didSet{
            self.callServerToLoadPin()
        }
    }
    
    // for search
    var resultSearchController: UISearchController? = nil
    var searchAnnotation: SearchAnnotation? = nil

    //MARK: Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // MapView Configuration
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.userLocation.title = ""

        // UI Configuration
        self.locationButton.layer.shadowOffset = CGSize(width: 3.3, height: 3.3)
        self.locationButton.imageEdgeInsets = UIEdgeInsetsMake(11,11,11,11)
        
        containerView.isHidden = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        // User Location Configuration
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Search Location and Road
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
        
        // first load pin
        self.callServerToLoadPin()
    }
    
    //MARK: IBAction
    @IBAction func getUserLocation(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    func callServerToLoadPin() {
        var numberOfNothing = 0
        for (_, value) in self.constraintParameter {
            if value == "nothing" {
                numberOfNothing += 1
            }
        }
        if numberOfNothing == 3 || self.constraintParameter.isEmpty {
            self.loadPinWithoutConstraints()
        } else {
            self.loadPinWithConstraints()
        }
    }
    
    func refreshView() {
        self.callServerToLoadPin()
    }
}


// MARK: - Load Data from Server
extension HouseViewController {
    
    //MARK: Private Functions
    fileprivate func loadPinWithoutConstraints() {

        self.annotationList.removeAll()
        self.clusteringManager.removeAll()
        
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/videoRoadList").responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("---Connecting to VIDEO ROAD server success---")
                
                let jsonArray: Array = JSON(value).arrayValue
                
                for (index, subJson) in jsonArray.enumerated() {
                    let annotation = Annotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: subJson["lat"].doubleValue, longitude: subJson["lng"].doubleValue)
                    annotation.address = subJson["address"].stringValue
                    annotation.numberOfElement = subJson["houseNumber"].intValue
                    annotation.id = index
                    
                    self.annotationList.append(annotation)
                    
                }
                
                DispatchQueue.main.async(execute: {
                    self.clusteringManager.add(annotations: self.annotationList)
                    
                    let mapBoundsWidth = Double(self.mapView.bounds.size.width)
                    let mapRectWidth = self.mapView.visibleMapRect.size.width
                    let scale = mapBoundsWidth / mapRectWidth
                    
                    let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
                    
                    self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
                    
            
                    print("---Display HOME Annotations WITHOUT CONSTRAINTS---")
                })
                
            case .failure(let error):
                print("---Connecting to VIDEO ROAD server failed---")
                print(error)
            }
        }
    }
    
    fileprivate func loadPinWithConstraints() {
        
        self.annotationList.removeAll()
        self.clusteringManager.removeAll()
        
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/search", method: .post, parameters: self.constraintParameter).validate().responseJSON(completionHandler: {
            response in
            
            switch response.result {
                
            case .success(let value):
                print("---Connecting to SEARCH server success---")
                
                let jsonArray: Array = JSON(value).arrayValue
                
                for (index, subJson) in jsonArray.enumerated() {
                    let annotation = Annotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: subJson["lat"].doubleValue, longitude: subJson["lng"].doubleValue)
                    annotation.address = subJson["address"].stringValue
                    annotation.numberOfElement = subJson["houseNumber"].intValue
                    annotation.id = index
                    
                    self.annotationList.append(annotation)
                    
                }
                print(value)
                print(self.annotationList)
                
                DispatchQueue.main.async(execute: {
                    self.clusteringManager.add(annotations: self.annotationList)
                    
                    let mapBoundsWidth = Double(self.mapView.bounds.size.width)
                    let mapRectWidth = self.mapView.visibleMapRect.size.width
                    let scale = mapBoundsWidth / mapRectWidth
                    
                    let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
                    
                    self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
                    
                    print("---Display HOME Annotations WITH CONSTRAINTS---")
                })
                
            case .failure(let error):
                print("---Connecting to SEARCH server failed---")
                print(error)
            }
        })
    }
}


//MARK: - MKMapViewDelegate Implement
extension HouseViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        view.layer.borderColor =  UIColor(red: 51.0/255.0, green: 153.0/255.0, blue: 255.0/255.0, alpha: 1).cgColor
        
        switch view.annotation {
            
        case is Annotation:
            
            containerView.isHidden = false
            
            guard let selectedAnnotation = view.annotation as? Annotation else {
                fatalError("the selected annotation is not Annotaion type")
            }
            
            guard let selectedAnnotationView = view as? AnnotationView else {
                fatalError("the selected annotationVies is not the AnnotationClusterView type")
            }
            guard let countLabelText = selectedAnnotationView.countLabel.text else {
                fatalError("the countLabelText is empty")
            }
            guard let numberOfHouse = Int(countLabelText) else {
                fatalError("the countLabelText counld't convert into Integer")
            }
            
            if let controller = self.childViewControllers[0] as? HouseContainerViewController {
                controller.selectedAddress = [selectedAnnotation.address]
                controller.numberOfHouse = numberOfHouse
            }
        
        case is AnnotationCluster:
            
            containerView.isHidden = false

            guard let selectedAnnotationCluster = view.annotation as? AnnotationCluster else {
                fatalError("the selected annotation is not AnnotaionCluster type")
            }
            
            var selectedAddress: [String] = []
            for mkAnnotation in selectedAnnotationCluster.annotations {
                if let annotation = mkAnnotation as? Annotation {
                    selectedAddress.append(annotation.address)
                } else {
                    fatalError("annotation in annotation cluster is not annotation type")
                }
            }

            guard let selectedAnnotationClusterView = view as? AnnotationClusterView else {
                fatalError("the selected annotationVies is not the AnnotationClusterView type")
            }
            guard let countLabelText = selectedAnnotationClusterView.countLabel.text else {
                fatalError("the countLabelText is empty")
            }
            guard let numberOfHouse = Int(countLabelText) else {
                fatalError("the countLabelText counld't convert into Integer")
            }
            if let controller = self.childViewControllers[0] as? HouseContainerViewController {
                controller.selectedAddress = selectedAddress
                controller.numberOfHouse = numberOfHouse
            }
        default:
            print("user select unknown annotation")
            break
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        view.layer.borderColor = UIColor.white.cgColor
        
        switch view.annotation {
        case is Annotation:
            containerView.isHidden = true
        case is AnnotationCluster:
            containerView.isHidden = true
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        switch annotation {
        case is AnnotationCluster:
        
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                clusterView = AnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                clusterView?.annotation = annotation
            }
            return clusterView
        
        case is Annotation:
            
            reuseId = "houseAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if annotationView == nil {
                annotationView = AnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        
        case is SearchAnnotation:
            
            reuseId = "searchAnnotationView"
            var searchAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if searchAnnotationView == nil {
                searchAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                searchAnnotationView?.image = UIImage(named: "search pin")
            } else {
                searchAnnotationView?.annotation = annotation
            }
            return searchAnnotationView
        default:
            return nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
            
            DispatchQueue.main.async {
                self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
            }
        }
    
    }
}


//MARK: - CLLocaitonManagerDelegate Implement
extension HouseViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("---Updating User Location Failed---")
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.0025, 0.0025)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: true)
        }
        locationManager.stopUpdatingLocation()
    }
}

//MARK: - Navigation
extension HouseViewController {
    
    @IBAction func unwindToHouseView(sender: UIStoryboardSegue){
        guard let sourceViewController = sender.source as? HouseSelectViewController else {
                fatalError("Unexpected sourceViewController")
        }
        self.constraintParameter = sourceViewController.constraintParameter
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is HouseContainerViewController:
            break
        case is UINavigationController:
            guard let rootDestination = segue.destination as? UINavigationController else {
                fatalError("Cannot downcast")
            }
            guard let destination = rootDestination.viewControllers.first as? HouseSelectViewController else{
                fatalError("Cannot downcast")
            }
                destination.constraintParameter = self.constraintParameter
        default:
            fatalError("Unexpected Destination! Destination is \(segue.destination)")
        }
    }
    
}


//MARK: - HandleMapSearch Protocal Implement
extension HouseViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        
        // clear existing pins
        if let searchAnnotation = self.searchAnnotation {
            self.mapView.removeAnnotation(searchAnnotation)
        }
        
        let searchAnnotation = SearchAnnotation()
        searchAnnotation.coordinate = placemark.coordinate
        self.searchAnnotation = searchAnnotation
       
        self.mapView.addAnnotation(searchAnnotation)
        
        let span = MKCoordinateSpanMake(0.025, 0.025)
        let region = MKCoordinateRegionMake(searchAnnotation.coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
}


//MARK: - UISearchBarDelegate Implement
extension HouseViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let result = resultSearchController?.searchResultsController as? LocationSearchTable else{
            fatalError("Unexpected search result controller \(String(describing: resultSearchController?.searchResultsController))")
        }
        let matchItems = result.matchingItems
        
        self.dropPinZoomIn(placemark: matchItems[0].placemark)
        
        self.dismiss(animated: true, completion: nil)
    }
}
