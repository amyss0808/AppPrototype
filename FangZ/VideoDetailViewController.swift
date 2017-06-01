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
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet weak var videoDescriptionView: UIView!
    @IBOutlet weak var videoDescriptionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoTime: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    
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
        
        let elementWidth = (self.view.frame.width - 56) / 4
        
        for (index, element) in elements.enumerated() {
            let elementLabel = UILabel()
            elementLabel.layer.masksToBounds = true
            elementLabel.layer.cornerRadius = 6
            elementLabel.backgroundColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
            elementLabel.text = element
            elementLabel.baselineAdjustment = .alignCenters
            elementLabel.textAlignment = .center
            elementLabel.textColor = .white
            
            let position = self.calculateXYPosition(where: index)
            print(position.elementXPosition)
            print(position.elementYPosition)
            elementLabel.frame = CGRect(x: position.elementXPosition, y: position.elementYPosition, width: Int(elementWidth), height: 25)
            self.videoDescriptionView.addSubview(elementLabel)
        }
        
        self.videoDescriptionViewHeightConstraint.constant = CGFloat(Int((elements.count - 1) / 4 + 1) * 33 + 8)

    }
    
    func calculateXYPosition(where index: Int) -> (elementXPosition: Int, elementYPosition: Int){
        
        let elementWidth = Int((self.view.frame.width - 56) / 4)
        
        let row = index / 4
        let column = index % 4
        
        let elementXPosition = 8 + column * (elementWidth + 8)
        let elementYPosition = 8 + row * 33
        
        return (elementXPosition: elementXPosition, elementYPosition: elementYPosition)
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
        let startPin = StartEndPointAnnotation(position: .start)
        startPin.coordinate = startCoordinate
        
        let endPin = StartEndPointAnnotation(position: .end)
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
                let endPointAnnotationView = self.setImage(for: startEndPointAnnotation, reuseId, with: "end pin")
                
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
}


extension VideoDetailViewController {
    
    func loadVideoDetail() {
        
        var videoElements: [String] = []
        
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/video/\(self.videoId)").responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                print("---Downloading No. \(self.videoId) Video Succeed")
                
                let videoTitleSeperatedByBottomLine = json["title"].stringValue.components(separatedBy: "_")
                let videoTitle = videoTitleSeperatedByBottomLine[0]
                
                let videoTime = self.convertVideoTime(toChinese: json["time"].stringValue)
                
                let youtubeId = json["youtube_id"].stringValue
                
                let url = URL(string: "https://www.youtube.com/embed/\(youtubeId)?playsinline=1")
                
                let startCoordinate = CLLocationCoordinate2D(latitude: json["start_geometry"].arrayValue[0].doubleValue, longitude: json["start_geometry"].arrayValue[1].doubleValue)
                
                let endCoordinate = CLLocationCoordinate2D(latitude: json["end_geometry"].arrayValue[0].doubleValue, longitude: json["end_geometry"].arrayValue[1].doubleValue)
                
                let videoWeather = json["weather"].stringValue
                    videoElements.append(videoWeather)
                
                if !json["shop"].stringValue.isEmpty {
                    videoElements += json["shop"].stringValue.components(separatedBy: ",")
                }
                
                if !json["facility"].stringValue.isEmpty {
                    videoElements += json["facility"].stringValue.components(separatedBy: ",")
                }
                
                if !json["environment"].stringValue.isEmpty {
                    videoElements += json["environment"].stringValue.components(separatedBy: ",")
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
                
            case .failure(let error):
                print("---Downloading No. \(self.videoId) Video Fail")
                print(error)
            }
        }
    }

}
