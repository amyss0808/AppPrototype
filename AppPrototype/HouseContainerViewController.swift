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
    var houseList = [House]()
    var videoList = [Video]()
    var numberOfHouse: Int = 0
    var selectedAddress: [String] = [] {
        didSet{
            switch segmentControl.selectedSegmentIndex {
            case 0:
                loadHouseData()
            case 1:
                loadVideoData()
            default:
                fatalError("user tap unknown segement")
            }
        }
    }
    
    
    // MARK: Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        self.view.layer.cornerRadius = 7.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: IBAction
    @IBAction func segmentIndexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            loadHouseData()
            print("0")
        case 1:
            loadVideoData()
            print("1")
        default:
            fatalError("user tap unknown segement")
        }
    }
    
    
    //MARK: Private Function
    private func loadHouseData() {
        
        self.houseList.removeAll()
        
        var numberOfFinishedQueue: Int = 0
        
        for address in self.selectedAddress {
            let utf8Address = address.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/houseList/\(utf8Address!)").responseJSON { response in
                switch response.result {
                    
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    let jsonArray: Array = json.arrayValue
                    
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
                        })
                    }
                    
                    print(json)
                case .failure(let error):
                    print(error)
                    
                    numberOfFinishedQueue += 1
                    
                    if numberOfFinishedQueue == self.selectedAddress.count {
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                }
            }

        }
        
    }
    
    private func loadVideoData() {
        
        self.videoList.removeAll()
        
        var numberOfFinishedQueue: Int = 0
        
        for address in self.selectedAddress {
            let utf8Address = address.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/houseList/\(utf8Address!)").responseJSON { response in
                switch response.result {
                    
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    let jsonArray: Array = json.arrayValue
                    
                    for subJson in jsonArray {
                        
                        let video = Video(videoId: subJson["id"].intValue, videoTitle: subJson["title"].stringValue, videoTime: subJson["time"].stringValue)
                        self.videoList.append(video)

                    }
                    
                    numberOfFinishedQueue += 1
                    
                    if numberOfFinishedQueue == self.selectedAddress.count {
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                    
                    print(json)
                case .failure(let error):
                    
                    numberOfFinishedQueue += 1
                    
                    if numberOfFinishedQueue == self.selectedAddress.count {
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                    
                    print(error)
                }
            }
            
        }
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        
        switch segue.identifier ?? "" {
        case "houseDetail":
            guard let houseDetailController = segue.destination as? HouseDetailViewController else {
                fatalError("Unexpected Segue destination \(segue.destination)")
            }
            guard let selectedHouseCell = sender as? HouseTableViewCell else {
                fatalError("Unexpected Sender Cell \(sender)")
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
                fatalError("Unexpected Sender Cell \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedVideoCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            videoDetailController.videoId = videoList[indexPath.row].videoId
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }
    
}


//MARK: - UITableViewDelegate Implement
extension HouseContainerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            return 85.0
        case 1:
            return 63.0
        default:
            return 63.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        let roundedView = TableSubView(frame: CGRect(x: 7, y: 7, width: self.view.frame.size.width - 14 , height: cell.frame.size.height - 7))
        
        roundedView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        roundedView.layer.masksToBounds = false
        roundedView.layer.cornerRadius = 7.0
        roundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        roundedView.layer.shadowOpacity = 0.2
        
        for view in cell.contentView.subviews {
            guard view.isKind(of: TableSubView.self) else {
                continue
            }
            view.removeFromSuperview()
        }
        
        cell.contentView.addSubview(roundedView)
        cell.contentView.sendSubview(toBack: roundedView)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "houseCell", for: indexPath) as? HouseTableViewCell else {
                fatalError("error")
            }
            cell.houseTitle.text = houseList[indexPath.row].houseTitle
            cell.houseAddress.text = houseList[indexPath.row].houseAddress
            cell.houseTypeAndSquare.text = "\(houseList[indexPath.row].houseType)/\(houseList[indexPath.row].houseSquare)"
            cell.housePrice.text = houseList[indexPath.row].housePrice
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as? VideoTableViewCell else {
                fatalError("error")
            }
            cell.videoTitle.text = videoList[indexPath.row].videoTitle
            cell.videoTime.text = videoList[indexPath.row].videoTime
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "houseCell", for: indexPath) as? HouseTableViewCell else {
                fatalError("error")
            }
            return cell
        }
        
    }
}
