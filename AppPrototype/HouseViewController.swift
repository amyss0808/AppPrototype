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
    var housePinList = [HousePin]()
    var address: String = ""
    let locationManager = CLLocationManager()
    
    // for search
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    
    //MARK: Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.mapType = .standard
      
        loadPin()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = mapView
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Test", style: .done, target: nil, action: nil)
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.handleMapSearchDelegate = self
        resultSearchController?.searchBar.delegate = self
        
        containerView.isHidden = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: Private Functions
    private func loadPin() {
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/videoRoadList").responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                let jsonArray: Array = json.arrayValue
                
                for (_,subJson):(String, JSON) in json {
                    let pin = HousePin(latitude: subJson["lat"].doubleValue, longitude: subJson["lng"].doubleValue, address: subJson["address"].stringValue)
                    self.housePinList.append(pin)
                }
                
                if jsonArray.count == self.housePinList.count {
                    DispatchQueue.main.async(execute: {
                        for (index, pin) in self.housePinList.enumerated() {
                            print("addAnnotation \(index)")
                            let annotation = HousePointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
                            annotation.index = index
                            self.mapView.addAnnotation(annotation)
                        }
                    })
                }
            case .failure(let error):
                print("Connecting to server failed.")
                print(error)
            }
        }
    }
    
    //MARK: IBAction
    @IBAction func getUserLocation(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
}


//MARK: - MKMapViewDelegate Implement
extension HouseViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        switch view.annotation {

        case is HousePointAnnotation:
            
            containerView.isHidden = false
            
            guard let selectedAnnotation = view.annotation as? HousePointAnnotation else {
                fatalError("the selected annotation is not HousePointAnnotaion type")
            }
            
            let index = selectedAnnotation.index
            let selectedAddress = housePinList[index].address
            
            if let controller = self.childViewControllers[0] as? HouseContainerViewController {
                controller.selectedAddress = selectedAddress
            }
            print("\(selectedAddress) The address has been passed to HouseContainerViewController")
            
        default:
            break
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        switch view.annotation {
        case is HousePointAnnotation:
            containerView.isHidden = true
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is HousePointAnnotation:
            let pinView = MKAnnotationView()
            pinView.isHidden = true
            pinView.image = UIImage(named: "home")
            return pinView
        default:
            return nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if mapView.region.span.latitudeDelta + mapView.region.span.longitudeDelta > 0.9 {
        
            let annotationsInVisibleMapRect = mapView.annotations(in: mapView.visibleMapRect)
            
            for annotation in annotationsInVisibleMapRect {
                guard let confirmedAnnotation = annotation as? HousePointAnnotation else {
                    continue
                }
                mapView.view(for: confirmedAnnotation)?.isHidden = true
            }
        } else {
        
        let annotationsInVisibleMapRect = mapView.annotations(in: mapView.visibleMapRect)
        
        for annotation in annotationsInVisibleMapRect {
            guard let confirmedAnnotation = annotation as? HousePointAnnotation else {
                continue
            }
            mapView.view(for: confirmedAnnotation)?.isHidden = false
        }
        }
        
    }
}


//MARK: - CLLocaitonManagerDelegate Implement
extension HouseViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: true)
        }
        locationManager.stopUpdatingLocation()
    }
}


//MARK: - HandleMapSearch Protocal Implement
extension HouseViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        //        mapView.removeAnnotations(mapView.annotations)
        let annotation = SearchPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
}


//MARK: - UISearchBarDelegate Implement
extension HouseViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let result = resultSearchController?.searchResultsController as? LocationSearchTable else{
            fatalError("Unexpected search result controller \(resultSearchController?.searchResultsController)")
        }
        let matchItems = result.matchingItems
        
        self.dropPinZoomIn(placemark: matchItems[0].placemark)
        
        dismiss(animated: true, completion: nil)
    }
}
