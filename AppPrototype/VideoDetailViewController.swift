//
//  VideoDetailViewController.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/22.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit

class VideoDetailViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var videoDescriptionView: UIView!
    @IBOutlet weak var videoTime: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet var videoElementLabels: [UILabel]!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var videoId :Int = 0 {
        didSet{
            self.loadVideoDetail()
        }
    }
    
    //MARK: Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    //MARK: Private Function
    func convertVideoTime(toChinese videoTime: String) -> String {
        
        switch videoTime {
        case "morning":
            return "早上"
        case "afternoon":
            return "下午"
        case "night":
            return "晚上"
        case "midnight":
            return "凌晨"
        default:
            return ""
        }
    }
    
    func changeElementsUI(elements: [String]) {
        
//        let numberOfElements = elements.count
//        
//        for elementLabel in self.videoElementLabels {
//            
//            let tagNumber = elementLabel.tag
//            
//            if tagNumber == 0 {
//                if numberOfElements > 0 {
//                    elementLabel.text = elements[0]
//                } else {
//                    elementLabel.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5)
//                }
//            } else if tagNumber > 0 && tagNumber <= 11 {
//                if numberOfElements > tagNumber - 1 {
//                    elementLabel.text = elements[tagNumber - 1]
//                } else {
//                    elementLabel.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5)
//                }
//            } else if elementLabel.tag == 12 {
//                elementLabel.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5)
//            } else {
//                fatalError("unknown element label tag be found")
//            }
//            
//        }
        
        for (index, elementLabel) in self.videoElementLabels.enumerated() {
            if index == 0 {
                elementLabel.backgroundColor = UIColor(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
                elementLabel.text = elements[0]
            } else {
                for element in elements {
                    if elementLabel.text == element {
                        elementLabel.layer.cornerRadius = 10
                        elementLabel.backgroundColor = UIColor(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
                        break
                    } else {
                        elementLabel.layer.cornerRadius = 10
                        elementLabel.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 1)
                    }
                }
            }
        }
    }
    
    // MARK: - Task Functions
    func configureMapView(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        let centerLatitude = (startCoordinate.latitude + endCoordinate.latitude)/2
        let centerLongitude = (startCoordinate.longitude + endCoordinate.longitude)/2
        let centerlocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(centerlocation, 550, 550)
        
        mapView.setRegion(region, animated: false)
    }
    
    
    func loadStartEndPins(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        let startPin = MKPointAnnotation()
        startPin.coordinate = startCoordinate
        
        let endPin = MKPointAnnotation()
        endPin.coordinate = endCoordinate
        
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
}


extension VideoDetailViewController {
    func loadVideoDetail() {
        
        
        var videoElements: [String] = []
        
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/video/\(videoId)").responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                let videoTitleSeperatedByBottomLine = json["title"].stringValue.components(separatedBy: "_")
                let videoTitle = videoTitleSeperatedByBottomLine[0]
                let videoTime = self.convertVideoTime(toChinese: json["time"].stringValue)
                let youtubeId = json["youtube_id"].stringValue
                let url = URL(string: "https://www.youtube.com/embed/\(youtubeId)?playsinline=1")
                
                let start_geometry = json["start_geometry"].arrayValue
                let startCoordinate = CLLocationCoordinate2D(latitude: start_geometry[0].doubleValue, longitude: start_geometry[1].doubleValue)
                
                let end_geometry = json["end_geometry"].arrayValue
                let endCoordinate = CLLocationCoordinate2D(latitude: end_geometry[0].doubleValue, longitude: end_geometry[1].doubleValue)
                
                let videoWeather = json["weather"].stringValue
                    videoElements.append(videoWeather)
                
                if !json["shop"].stringValue.isEmpty {
                    videoElements += json["shop"].stringValue.components(separatedBy: ",")
                }
                
                if !json["facility"].stringValue.isEmpty {
                    videoElements += json["facility"].stringValue.components(separatedBy: ",")
                }
                
                DispatchQueue.main.async(execute: {
                    
                    self.changeElementsUI(elements: videoElements)
                    self.videoTitle.text = videoTitle
                    self.videoTime.text = videoTime
                    self.configureMapView(startCoordinate: startCoordinate, endCoordinate: endCoordinate)
                    self.loadStartEndPins(startCoordinate: startCoordinate, endCoordinate: endCoordinate)
                    self.videoView.allowsInlineMediaPlayback = true
                    self.videoView.loadRequest(URLRequest(url: url!))
                })
                print(json)
            case .failure(let error):
                print(error)
            }
        }
    }

}
