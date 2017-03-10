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
    @IBOutlet weak var houseDescriptionViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var squareView: UIView!
    @IBOutlet weak var squareTitleView: UIView!
    @IBOutlet weak var squareTitleLabel: UILabel!
    @IBOutlet weak var squareViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailTitleView: UIView!
    @IBOutlet weak var detailViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var communityView: UIView!
    @IBOutlet weak var communityTitleView: UIView!
    @IBOutlet weak var communityTitleLabel: UILabel!
    @IBOutlet weak var communityDescriptionLabel: UILabel!
    @IBOutlet weak var communityViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var communityTitleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var communityTitleLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var verticalSpaceBetweenMapCommunity: NSLayoutConstraint!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapTitleView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var verticalSpaceBetweenCommunitySurronding: NSLayoutConstraint!
    @IBOutlet weak var surrondingView: UIView!
    @IBOutlet weak var surrondingTitleView: UIView!
    @IBOutlet weak var surrondingTitleLabel: UILabel!
    @IBOutlet weak var surrondingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var surrondingTitleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var surrondingTitleLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var urlButton: UIButton!
    
    var houseUrl: String = ""
    var houseIndex :Int = 0 {
        didSet{
            loadHouseDetail()
        }
    }
    var imagesArray : [String] = [String]() {
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

        squareView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        squareView.layer.masksToBounds = false
        squareView.layer.cornerRadius = 7.0
        squareView.layer.shadowOffset = CGSize(width: -1, height: 1)
        squareView.layer.shadowOpacity = 0.2
        
        detailView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        detailView.layer.masksToBounds = false
        detailView.layer.cornerRadius = 7.0
        detailView.layer.shadowOffset = CGSize(width: -1, height: 1)
        detailView.layer.shadowOpacity = 0.2
        
        communityView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        communityView.layer.masksToBounds = false
        communityView.layer.cornerRadius = 7.0
        communityView.layer.shadowOffset = CGSize(width: -1, height: 1)
        communityView.layer.shadowOpacity = 0.2
        
        mapContainerView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        mapContainerView.layer.masksToBounds = false
        mapContainerView.layer.cornerRadius = 7.0
        mapContainerView.layer.shadowOffset = CGSize(width: -1, height: 1)
        mapContainerView.layer.shadowOpacity = 0.2
        self.mapView.mapType = .standard
        
        surrondingView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        surrondingView.layer.masksToBounds = false
        surrondingView.layer.cornerRadius = 7.0
        surrondingView.layer.shadowOffset = CGSize(width: -1, height: 1)
        surrondingView.layer.shadowOpacity = 0.2
        
        urlButton.layer.cornerRadius = 4
        urlButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        urlButton.layer.shadowOpacity = 0.2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: Private Functions
    func loadHouseDetail() {
        var detailArray :[(key: String, value: String)] = []
        var communityArray :[(key: String, value: String)] = []
        var surrondingArray :[(key: String, value: String)] = []
        var squareArray :[(key: String, value: String)] = []
        
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/house/\(houseIndex)").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let title = json["title"].stringValue.replacingOccurrences(of: " ", with: "")
                
                let description = json["description"].stringValue.replacingOccurrences(of: " " , with: "")
                
                let address = json["address"].stringValue.replacingOccurrences(of: " ", with: "")
                detailArray.append((key: "地址", value: address))
                
                let price = json["price"].stringValue.replacingOccurrences(of: " ", with: "")
                detailArray.append((key: "總價", value: price))
                
                let typeData = json["type"].stringValue.replacingOccurrences(of: " ", with: "")
                let typeArray = typeData.components(separatedBy: "：")
                detailArray.append((key: typeArray[0], value: typeArray[1]))
                
                let url = json["url"].stringValue
                
                let pictureData = json["picture"].stringValue.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: " ", with: "")
                self.imagesArray = pictureData.components(separatedBy: ",")
                
                let information = json["information"].stringValue.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(說明)", with: "")
                var informationArray = information.components(separatedBy: "@")
                if let typeIndex = informationArray.index(where: { $0.contains("類型") }) {
                    informationArray.remove(at: typeIndex)
                }
                
                for index in 2..<informationArray.count {
                    if informationArray[index].contains("坪") || informationArray[index].contains("格局"){
                        let squareTuple = informationArray[index].components(separatedBy: ":")
                        squareArray.append((key: squareTuple[0], value: squareTuple[1]))
                    } else {
                        let informationTuple = informationArray[index].components(separatedBy: ":")
                        detailArray.append((key: informationTuple[0], value: informationTuple[1]))
                    }
                }
                
                let community = json["community"].dictionaryObject ?? nil
                if let communityDic = community {
                    if let communityName = communityDic["name"] as? String, let communityDescription = communityDic["description"] as? String {
                        communityArray.append((key: "社區名稱", value: communityName))
                        communityArray.append((key: "社區介紹", value: communityDescription))
                    } else {
                        communityArray.removeAll()
                    }
                } else {
                    communityArray.removeAll()
                }
                
                let lifeData = json["life"].stringValue.replacingOccurrences(of: " ", with: "")
                if !lifeData.isEmpty {
                    let lifeArray = lifeData.components(separatedBy: ",")
                    for life in lifeArray {
                        let lifeTuple = life.components(separatedBy: ":")
                        surrondingArray.append((key: lifeTuple[0], value: lifeTuple[1]))
                    }
                } else {
                    surrondingArray.removeAll()
                }
                
                let location = json["locationPoint"].arrayValue
                let latitude = location[0].floatValue
                let longitude = location[1].floatValue
                
                
                    DispatchQueue.main.async(execute: {
                        
                        self.houseTitleLabel.text = title
                        self.housePriceLabel.text = price
                        self.houseAddressLabel.text = address
                        
                        self.houseDescriptionLabel.text = description
                        self.houseDescriptionLabel.sizeToFit()
                        self.houseDescriptionViewConstraint.constant = CGFloat(36) + self.houseDescriptionLabel.frame.height
                        
                        self.changeSquareUI(squareArray: squareArray)
                        
                        self.changeDetailUI(detailArray: detailArray)
                        
                        if communityArray.isEmpty {
                            self.communityViewHeightConstraint.constant = 0
                            self.communityTitleLabelHeightConstraint.constant = 0
                            self.communityTitleViewHeightConstraint.constant = 0
                            self.verticalSpaceBetweenMapCommunity.constant = 0
                        } else {
                            self.changeCommunityUI(communityArray: communityArray)
                        }
                        
                        self.houseLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                        
                        if surrondingArray.isEmpty {
                            self.surrondingViewHeightConstraint.constant = 0
                            self.surrondingTitleViewHeight.constant = 0
                            self.surrondingTitleLabelHeight.constant = 0
                            self.verticalSpaceBetweenCommunitySurronding.constant = 0
                        } else {
                            self.changeSurrondingUI(surrondingArray: surrondingArray)
                        }
                        
                        self.houseUrl = url
                    })

            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadImages() {
        
        var sizeIndex = 0
        
        for (index, imageUrl) in self.imagesArray.enumerated() {
            
            Alamofire.request(imageUrl).response { response in
                if response.error == nil {
                    if let data = response.data {
                        let imageView = UIImageView(image: UIImage(data: data, scale: 1 ))
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
        let span = MKCoordinateSpanMake(0.0015, 0.0015)
        let region = MKCoordinateRegionMake(self.houseLocation, span)
        mapView.setRegion(region, animated: false)
        
        let houseAnnotation = MKPointAnnotation()
        houseAnnotation.coordinate = self.houseLocation
        mapView.addAnnotation(houseAnnotation)
    }
    
    func changeCommunityUI(communityArray: [(key: String, value: String)]) {
        
        for communityTuple in communityArray {
            switch communityTuple.key {
                case "社區名稱":
                    let yPosition = self.communityTitleView.frame.height + CGFloat(8)
                    
                    let keyLabel = UILabel()
                    keyLabel.text = communityTuple.key
                    keyLabel.textColor = UIColor(red: 201.0/255.0, green: 201.0/255.0, blue: 201.0/255.0, alpha: 1)
                    keyLabel.sizeToFit()
                    keyLabel.frame = CGRect(x: 12, y: yPosition, width: keyLabel.frame.width, height: keyLabel.frame.height)
                    keyLabel.textAlignment = .left
                    self.communityView.addSubview(keyLabel)
                    
                    let valueLabel = UILabel()
                    valueLabel.text = communityTuple.value
                    valueLabel.textColor = .white
                    valueLabel.sizeToFit()
                    let xPositionOfValue = self.communityView.frame.width - 12 - valueLabel.frame.width
                    valueLabel.frame = CGRect(x: xPositionOfValue, y: yPosition, width: valueLabel.frame.width, height: valueLabel.frame.height)
                    self.communityView.addSubview(valueLabel)
                
                case "社區介紹":
                    let keyLabel = UILabel()
                    keyLabel.text = communityTuple.key
                    keyLabel.textColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1)
                    keyLabel.sizeToFit()
                    keyLabel.frame = CGRect(x: 12, y: self.communityTitleView.frame.height + CGFloat(16) + CGFloat(20), width: keyLabel.frame.width, height: keyLabel.frame.height)
                    keyLabel.textAlignment = .left
                    self.communityView.addSubview(keyLabel)
                
                    self.communityDescriptionLabel.text = communityTuple.value
                    self.communityDescriptionLabel.sizeToFit()
            default:
                    break
            }
        }
        self.communityViewHeightConstraint.constant = CGFloat(100) + self.communityDescriptionLabel.frame.height
    }
    
    func changeSurrondingUI(surrondingArray :[(key: String, value: String)]) {
       
        for (index, surronding) in surrondingArray.enumerated() {
            
            let yPosition = self.surrondingTitleView.frame.height + CGFloat((index + 1) * 8) + CGFloat(index * 20)
            
            let keyLabel = UILabel()
            keyLabel.text = surronding.key
            keyLabel.textColor = UIColor(red: 201.0/255.0, green: 201.0/255.0, blue: 201.0/255.0, alpha: 1)
            keyLabel.sizeToFit()
            keyLabel.frame = CGRect(x: 12, y: yPosition, width: keyLabel.frame.width, height: keyLabel.frame.height)
            keyLabel.textAlignment = .left
            self.surrondingView.addSubview(keyLabel)
            
            let valueLabel = UILabel()
            valueLabel.text = surronding.value
            valueLabel.textColor = .white
            valueLabel.sizeToFit()
            let xPositionOfValue = self.surrondingView.frame.width - 12 - valueLabel.frame.width
            valueLabel.frame = CGRect(x: xPositionOfValue, y: yPosition, width: valueLabel.frame.width, height: valueLabel.frame.height)
            self.surrondingView.addSubview(valueLabel)
        }
        self.surrondingViewHeightConstraint.constant = self.surrondingTitleView.frame.height + CGFloat(surrondingArray.count * 28 + 8)
    }
    
    func changeDetailUI(detailArray :[(key: String, value: String)]) {
        
        for (index, detail) in detailArray.enumerated() {
            
            let yPosition = self.detailTitleView.frame.height + CGFloat((index + 1) * 8) + CGFloat(index * 20)
            
            let keyLabel = UILabel()
            keyLabel.text = detail.key
            keyLabel.textColor = UIColor(red: 201.0/255.0, green: 201.0/255.0, blue: 201.0/255.0, alpha: 1)
            keyLabel.sizeToFit()
            keyLabel.frame = CGRect(x: 12, y: yPosition, width: keyLabel.frame.width, height: keyLabel.frame.height)
            keyLabel.textAlignment = .left
            self.detailView.addSubview(keyLabel)
            
            if detail.key.contains("障礙空間") && detail.value.components(separatedBy: "、").count > 1{
                for (index, value) in detail.value.components(separatedBy: "、").enumerated() {
                    print(value)
                    let valueLabel = UILabel()
                    valueLabel.text = value
                    valueLabel.textColor = .white
                    valueLabel.sizeToFit()
                    let xPositionOfValue = self.detailView.frame.width - 12 - valueLabel.frame.width
                    valueLabel.frame = CGRect(x: xPositionOfValue, y: yPosition + CGFloat(index * 28), width: valueLabel.frame.width, height: valueLabel.frame.height)
                    self.detailView.addSubview(valueLabel)
                }
                
                self.detailViewHeightConstraint.constant = self.detailTitleView.frame.height + CGFloat((detailArray.count + 1) * 28 + 8)
                
            } else {
                let valueLabel = UILabel()
                valueLabel.text = detail.value
                valueLabel.textColor = .white
                valueLabel.sizeToFit()
                let xPositionOfValue = self.detailView.frame.width - 12 - valueLabel.frame.width
                valueLabel.frame = CGRect(x: xPositionOfValue, y: yPosition, width: valueLabel.frame.width, height: valueLabel.frame.height)
                self.detailView.addSubview(valueLabel)
                
                self.detailViewHeightConstraint.constant = self.detailTitleView.frame.height + CGFloat(detailArray.count * 28 + 8)
            }
            
            
        }
        
    }
    
    func changeSquareUI(squareArray :[(key: String, value: String)]) {
        
        for (index, detail) in squareArray.enumerated() {
            
            let yPosition = self.squareTitleView.frame.height + CGFloat((index + 1) * 8) + CGFloat(index * 20)
            
            let keyLabel = UILabel()
            keyLabel.text = detail.key
            keyLabel.textColor = UIColor(red: 201.0/255.0, green: 201.0/255.0, blue: 201.0/255.0, alpha: 1)
            keyLabel.sizeToFit()
            keyLabel.frame = CGRect(x: 12, y: yPosition, width: keyLabel.frame.width, height: keyLabel.frame.height)
            keyLabel.textAlignment = .left
            self.squareView.addSubview(keyLabel)
            
            let valueLabel = UILabel()
            valueLabel.text = detail.value
            valueLabel.textColor = .white
            valueLabel.sizeToFit()
            let xPositionOfValue = self.detailView.frame.width - 12 - valueLabel.frame.width
            valueLabel.frame = CGRect(x: xPositionOfValue, y: yPosition, width: valueLabel.frame.width, height: valueLabel.frame.height)
            self.squareView.addSubview(valueLabel)
        }
        self.squareViewHeightConstraint.constant = self.squareTitleView.frame.height + CGFloat(squareArray.count * 28 + 8)

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
