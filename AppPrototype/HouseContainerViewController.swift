//
//  HouseContainerViewController.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/24.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//MARK: - HouseContainerViewController Class
class HouseContainerViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewLabel: UILabel!
    
    var selectedAddress: [String] = [] {
        didSet{
            switch segmentControl.selectedSegmentIndex {
            case 0:
                self.loadingViewLabel.text = "資料重整中，請稍候..."
                self.loadingView.isHidden = false
                self.loadHouseData()
            case 1:
                self.loadingViewLabel.text = "資料重整中，請稍候..."
                self.loadingView.isHidden = false
                self.loadVideoData()
            default:
                fatalError("user tap unknown segement")
            }
        }
    }
    var numberOfHouse: Int = 0
    
    fileprivate var houseList = [House]()
    fileprivate var videoList = [Video]()
    fileprivate var numberOfVideo: Int = 0
    fileprivate var numberOfImageFinishedDownload: Int = 0
    
    // MARK: Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        self.loadingViewLabel.text = "資料重整中，請稍候..."
        self.loadingView.isHidden = false
    }

    
    //MARK: IBAction
    @IBAction func segmentIndexChanged(_ sender: UISegmentedControl) {
       
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.loadingViewLabel.text = "資料重整中，請稍候..."
            self.loadingView.isHidden = false
            self.loadHouseData()
        case 1:
            self.loadingViewLabel.text = "資料重整中，請稍候..."
            self.loadingView.isHidden = false
            self.loadVideoData()
        default:
            fatalError("user tap unknown segement")
        }
    
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
            
        case "houseDetail":
            guard let houseDetailController = segue.destination as? HouseDetailViewController else {
                fatalError("Unexpected Segue destination \(segue.destination)")
            }
            guard let selectedHouseCell = sender as? HouseTableViewCell else {
                fatalError("Unexpected Sender Cell \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedHouseCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            houseDetailController.houseIndex = houseList[indexPath.row].houseIndex
            
        case "videoDetail":
            guard let videoDetailController = segue.destination as? VideoDetailViewController else {
                fatalError("Unexpected Segue destination \(segue.destination)")
            }
            guard let selectedVideoCell = sender as? VideoTableViewCell else {
                fatalError("Unexpected Sender Cell \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedVideoCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
        
            videoDetailController.videoId = videoList[indexPath.row].videoId
 
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
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
    
}


    //MARK: - Load Data from Server
extension HouseContainerViewController {
    
    func loadHouseData() {
        
        self.loadingView.isHidden = false
        self.houseList.removeAll()
        
        var numberOfFinishedQueue: Int = 0
        
        for address in self.selectedAddress {
            let utf8Address = address.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/houseList/\(utf8Address!)").responseJSON { response in
                switch response.result {
                    
                case .success(let value):
                    
                    print("---Downloading House Data of \(address) Succeed---")
                    let jsonArray: Array = JSON(value).arrayValue
                    
                    for subJson in jsonArray {
                        
                        let rawSquare = subJson["square"].stringValue.replacingOccurrences(of: " ", with: "")
                        let square = rawSquare.substring(from: rawSquare.index(rawSquare.startIndex, offsetBy: 5))
                        
                        let rawType = subJson["type"].stringValue.replacingOccurrences(of: " ", with: "")
                        let type = rawType.substring(from: rawSquare.index(rawSquare.startIndex, offsetBy: 3))
                        
                        let house = House(houseIndex: subJson["id"].intValue, houseTitle: subJson["title"].stringValue, houseAddress: subJson["address"].stringValue, housePrice: subJson["price"].stringValue, houseSquare: square, houseType: type)
                        
                        self.houseList.append(house)
                    }
                    
                    numberOfFinishedQueue += 1
                    
                    if numberOfFinishedQueue == self.selectedAddress.count {
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                            self.loadingView.isHidden = true
                        })
                    }
                    
                case .failure(let error):
                  
                    print("---Downloading House Data of \(address) Failed---")
                    print(error)
                    
                    numberOfFinishedQueue += 1
                    
                    if numberOfFinishedQueue == self.selectedAddress.count {
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                            self.loadingView.isHidden = true
                        })
                    }
                }
            }
            
        }
        
    }
    
    func loadVideoData() {
        
        self.videoList.removeAll()
        self.numberOfVideo = 0
        self.numberOfImageFinishedDownload = 0
        
        var numberOfFinishedQueue = 0
        
        for address in self.selectedAddress {
            let utf8Address = address.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/videoList/\(utf8Address!)").responseJSON { response in
                switch response.result {
                    
                case .success(let value):
                    
                    print("---Downloading Video Data of \(address) Succeed---")
                    
                    let jsonArray: Array = JSON(value).arrayValue
                    
                    for subJson in jsonArray {
                        
                        let videoId = subJson["id"].intValue
                        
                        let youtube_id = subJson["youtube_id"].stringValue
                        
                        let videoTitleSeperatedByBottomLine = subJson["title"].stringValue.components(separatedBy: "_")
                        let videoTitle = videoTitleSeperatedByBottomLine[0]
                        
                        let videoTime = self.convertVideoTime(toChinese: subJson["time"].stringValue)
                        
                        let videoWeather = subJson["weather"].stringValue
                        
                        var videoElements: [String] = []
                        
                        if subJson["shop"].stringValue.isEmpty {
                            
                        } else {
                            videoElements += subJson["shop"].stringValue.components(separatedBy: ",")
                        }
                        
                        if subJson["facility"].stringValue.isEmpty {
                            
                        } else {
                            videoElements += subJson["facility"].stringValue.components(separatedBy: ",")
                        }
                        
                        let video = Video(videoId: videoId, imageData: nil, videoTitle: videoTitle, videoTime: videoTime, videoWeather: videoWeather, videoElements: videoElements)
                        
                        self.videoList.append(video)
                        
                        self.numberOfVideo += 1
                        
                        self.loadVideoImage(youtube_id: youtube_id, index: self.videoList.count - 1)
                    }
                    
                    numberOfFinishedQueue += 1
                    
                    if numberOfFinishedQueue == self.selectedAddress.count {
                        if self.videoList.isEmpty {
                            self.tableView.reloadData()
                            self.loadingViewLabel.text = "尚未有影片可供觀看"
                        }
                    }
                case .failure(let error):
                    
                    numberOfFinishedQueue += 1
                    
                    if numberOfFinishedQueue == self.selectedAddress.count {
                        if self.videoList.isEmpty {
                            self.tableView.reloadData()
                            self.loadingViewLabel.text = "尚未有影片可供觀看"
                        }
                    }
                    print("---Downloading Video Data of \(address) Failed---")
                    print(error)
                }
            }
            
        }
    }
    
    func loadVideoImage(youtube_id: String, index: Int) {
        
        Alamofire.request("https://img.youtube.com/vi/\(youtube_id)/0.jpg").response { response in
            
            if response.error == nil {
                
                print("---Downloading Video Image of No.\(index) Video Succeed---")
                
                if let data = response.data {
                    self.videoList[index].imageData = data
                }
                
                self.numberOfImageFinishedDownload += 1
                
                if self.numberOfImageFinishedDownload == self.numberOfVideo {
                    self.tableView.reloadData()
                    self.loadingView.isHidden = true
                    
                    print("---TableView Reloading Data Succeed---")
                }
                
            } else {
                
                print("---Downloading Video Image of No.\(index) Video Failed---")
                print(response.error!)
                
                self.numberOfImageFinishedDownload += 1
                
                if self.numberOfImageFinishedDownload == self.numberOfVideo {
                    self.tableView.reloadData()
                    self.loadingView.isHidden = true
                    
                    print("---TableView Reloading Data Succeed---")
                }
            }
            
        }
    }
}


//MARK: - UITableViewDelegate Implement
extension HouseContainerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

}


//MARK: - UITableViewDataSource Implement
extension HouseContainerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            return houseList.count
        case 1:
            return videoList.count
        default:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            guard let houseCell = tableView.dequeueReusableCell(withIdentifier: "houseCell", for: indexPath) as? HouseTableViewCell else {
                fatalError("error")
            }
            houseCell.houseTitle.text = self.houseList[indexPath.row].houseTitle
            houseCell.houseAddress.text = self.houseList[indexPath.row].houseAddress
            houseCell.houseTypeAndSquare.text = "\(self.houseList[indexPath.row].houseType)/\(houseList[indexPath.row].houseSquare)"
            houseCell.housePrice.text = houseList[indexPath.row].housePrice
            return houseCell
        case 1:
            
            guard let videoCell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as? VideoTableViewCell else {
                fatalError("error")
            }
            let video = self.videoList[indexPath.row]
            videoCell.videoTitle.text = video.videoTitle
            videoCell.videoTime.text = video.videoTime
            
            let videoElements = video.videoElements
            let numberOfElements = videoElements.count
            
            for elementLabel in videoCell.elementLabels {

                switch elementLabel.tag {
                    
                case 1:
                    if video.videoWeather.isEmpty {
                        elementLabel.isHidden = true
                    } else {
                        elementLabel.isHidden = false
                        elementLabel.text = video.videoWeather
                    }
                case 2:
                    if numberOfElements > 0 {
                        elementLabel.isHidden = false
                        elementLabel.text = videoElements[0]
                    } else {
                        elementLabel.isHidden = true
                    }
                case 3:
                    if numberOfElements > 1 {
                        elementLabel.isHidden = false
                        elementLabel.text = videoElements[1]
                    } else {
                        elementLabel.isHidden = true
                    }
                case 4:
                    if numberOfElements > 2 {
                        elementLabel.isHidden = false
                        elementLabel.text = videoElements[2]
                    } else {
                        elementLabel.isHidden = true
                    }
                case 5:
                    if numberOfElements >= 5 {
                        elementLabel.isHidden = false
                        elementLabel.text = "..."
                    } else if numberOfElements == 4 {
                        elementLabel.isHidden = false
                        elementLabel.text = videoElements[3]
                    } else {
                        elementLabel.isHidden = true
                    }
                default:
                    continue
                }
            }
            
            if let imageData = videoList[indexPath.row].imageData {
                videoCell.imgView.image = UIImage(data: imageData)
            }
            return videoCell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "houseCell", for: indexPath) as? HouseTableViewCell else {
                fatalError("error")
            }
            return cell
        }
    }
}
