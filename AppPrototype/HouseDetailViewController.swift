//
//  HouseDetailViewController.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/22.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit

class HouseDetailViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var housePriceLabel: UILabel!
    @IBOutlet weak var houseTitleLabel: UILabel!
    @IBOutlet weak var houseAddressLabel: UILabel!
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var houseDescriptionView: UIView!
    @IBOutlet weak var houseDescriptionLabel: UILabel!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewTitle: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var detailViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailTitleView: UIView!
    @IBOutlet weak var mapTitleView: UIView!
    var houseUrl: String = ""
    var houseIndex :Int = 0 {
        didSet{
            loadHouseDetail()
        }
    }
    var imagesArray : [String] = ["http://album.s3.hicloud.net.tw/02153D/A.JPG?t=1488366676","http://album.s3.hicloud.net.tw/68209V/A.JPG?t=1488366711","http://album.s3.hicloud.net.tw/22863X/A.JPG?t=1488366405","http://album.s3.hicloud.net.tw/65815E/A.JPG?t=1488366548"] {
        didSet {
            loadImages()
        }
    }
    var houseLocation : CLLocationCoordinate2D = CLLocationCoordinate2D() {
        didSet {
            loadHouseLocation()
        }
    }
    
    
    //MARK: Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        houseDescriptionView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        mapTitleView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        detailTitleView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor

        mapContainerView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        mapContainerView.layer.masksToBounds = false
        mapContainerView.layer.cornerRadius = 7.0
        mapContainerView.layer.shadowOffset = CGSize(width: -1, height: 1)
        mapContainerView.layer.shadowOpacity = 0.2
        
        detailView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        detailView.layer.masksToBounds = false
        detailView.layer.cornerRadius = 7.0
        detailView.layer.shadowOffset = CGSize(width: -1, height: 1)
        detailView.layer.shadowOpacity = 0.2
        
        urlButton.layer.cornerRadius = 4
        urlButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        urlButton.layer.shadowOpacity = 0.2
        
        loadImages()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: Private Functions
    func loadHouseDetail() {
        
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/house/\(houseIndex)").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var houseDetailArray: [(key: String, value: String)] = []
      
                let typeData = json["type"].stringValue.replacingOccurrences(of: " ", with: "")
                let typeArray = typeData.components(separatedBy: "：")
                houseDetailArray.append((key:typeArray[0], value: typeArray[1]))
                
                let patternData = json["pattern"].stringValue.replacingOccurrences(of: " ", with: "")
                let patternArray = patternData.components(separatedBy: "：")
                houseDetailArray.append((key: patternArray[0], value: patternArray[1]))
                
                let registeredSquareData = json["registeredSquare"].stringValue.replacingOccurrences(of: " ", with: "")
                let registeredSquareArray = registeredSquareData.components(separatedBy: "：")
                houseDetailArray.append((key: registeredSquareArray[0], value: registeredSquareArray[1]))

                let statusData = json["status"].stringValue.replacingOccurrences(of: " ", with: "")
                let statusArrayByComma = statusData.components(separatedBy: ",")
                for status in statusArrayByComma {
                    let statusArray = status.components(separatedBy: "：")
                    houseDetailArray.append((key:statusArray[0], value:statusArray[1]))
                }
                
                let location = json["locationPoint"].arrayValue
                let latitude = location[0].floatValue
                let longitude = location[1].floatValue
                self.houseLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                
                
                    DispatchQueue.main.async(execute: {
                        self.houseTitleLabel.text = json["title"].stringValue
                        self.housePriceLabel.text = json["price"].stringValue
                        self.houseAddressLabel.text = json["address"].stringValue
                        self.houseDescriptionLabel.text = json["description"].stringValue
                        self.houseUrl = json["url"].stringValue
                        
                        for (index, detail) in houseDetailArray.enumerated() {
                            
                            let yPosition = self.detailViewTitle.frame.height + CGFloat((index + 1) * 8) + CGFloat(index * 20)
                            
                            let keyLabel = UILabel()
                            keyLabel.text = detail.key
                            keyLabel.textColor = UIColor(red: 178.0/255.0, green: 223.0/255.0, blue: 238.0/255.0, alpha: 1)
                            keyLabel.sizeToFit()
                            keyLabel.frame = CGRect(x: 12, y: yPosition, width: keyLabel.frame.width, height: keyLabel.frame.height)
                            keyLabel.textAlignment = .left
                            self.detailView.addSubview(keyLabel)
                            print(keyLabel.frame)
                            
                            let valueLabel = UILabel()
                            valueLabel.text = detail.value
                            valueLabel.textColor = .white
                            valueLabel.sizeToFit()
                            let xPositionOfValue = self.detailView.frame.width - 12 - valueLabel.frame.width
                            valueLabel.frame = CGRect(x: xPositionOfValue, y: yPosition, width: valueLabel.frame.width, height: valueLabel.frame.height)
                            print(valueLabel.frame)
                            self.detailView.addSubview(valueLabel)
                        }
                        self.detailViewHeightConstraint.constant = self.detailViewTitle.frame.height + CGFloat(houseDetailArray.count * 28 + 4)
                        

                    })
                
                print(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadImages() {
        
        var sizeIndex = 0
        
        for (index, imageUrl) in self.imagesArray.enumerated() {
            
            Alamofire.request(imageUrl).response { response in
                
                print(response.error ?? "nil")
                
                if response.error == nil {
                    if let data = response.data {
                        let imageView = UIImageView(image: UIImage(data: data, scale: 1 ))
                        print(index)
                        imageView.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.imagesScrollView.frame.width, height: self.imagesScrollView.frame.height)
                        imageView.contentMode = .scaleToFill
                        self.imagesScrollView.contentSize.width = self.imagesScrollView.frame.width * CGFloat(sizeIndex + 1)
                        self.imagesScrollView.addSubview(imageView)
                        sizeIndex += 1
                    } else {
                        print(response.error!)
                    }
                }
                
            }
            
        }
    }
    
    func loadHouseLocation() {
        let span = MKCoordinateSpanMake(0.0025, 0.0025)
        let region = MKCoordinateRegionMake(self.houseLocation, span)
        mapView.setRegion(region, animated: false)
        
        let houseAnnotation = MKPointAnnotation()
        houseAnnotation.coordinate = self.houseLocation
        mapView.addAnnotation(houseAnnotation)
    }
    
    
//     MARK: IBAction
    @IBAction func tappedUrlButton(_ sender: UIButton) {
    
        if !houseUrl.isEmpty {
            UIApplication.shared.open(URL(string: houseUrl)!)
        } else {
            loadHouseDetail()
        }
    
    }

}
