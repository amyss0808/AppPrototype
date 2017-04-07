//
//  TaskContainerViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/7.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit
import os.log

class TaskContainerViewController: UIViewController {
    
    // MARK: - Task Detail Properties
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDuration: UILabel!
    @IBOutlet weak var taskDistance: UILabel!
    var task: Task?
    
    
    // MARK: - View Outlets
    @IBOutlet weak var taskDetailView: UIView!
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskDetailView.layer.cornerRadius = 6
    }
    
    
    
    // MARK: - Task Detail Functions
    func loadTaskDetail(of taskId: Int, isNear: Bool) {
        let url = "http://140.119.19.33:8080/SoslabProjectServer/task/\(taskId)"
        
        Alamofire.request(url, method: .get).validate().responseJSON(completionHandler: { response in
            switch response.result {
            
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                let id = json["id"].stringValue
                let distance = json["distance"].stringValue
                let title = json["title"].stringValue.components(separatedBy: "_")[0]
                let duration = json["duration"].stringValue
                
                let startPoint = json["start_point"].dictionaryValue
                guard let startLat = startPoint["lat"]?.doubleValue else {
                    fatalError("latitude in start point is nil")
                }
                guard let startLng = startPoint["lng"]?.doubleValue else {
                    fatalError("longitude in start point is nil")
                }
                
                
                let endPoint = json["end_point"].dictionaryValue
                guard let endLat = endPoint["lat"]?.doubleValue else {
                    fatalError("latitude in end point is nil")
                }
                guard let endLng = endPoint["lng"]?.doubleValue else {
                    fatalError("longitude in end point is nil")
                }

                
                self.task = Task(taskId: id, taskTitle: title, taskDistance: distance, taskDuration: duration, taskStartPointLatitude: startLat, taskStartPointLongitude: startLng, taskEndPointLatitude: endLat, taskEndPointLongitude: endLng, taskIsNear: isNear)
                
                self.taskTitle.text = title
                self.taskDistance.text = distance
                self.taskDuration.text = duration
                
            case .failure(let error):
                print("load task detail error because: \(error)")
            }
        })
    }
    
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "buttonShowTaskDetail":
            guard let taskDetailVC = segue.destination as? TaskDetailViewController else {
                fatalError("The destination view controller: \(segue.destination) of this segue is not TaskDetailViewController")
            }
            guard let mytask = self.task else {
                fatalError("In prepare for segue: self.task is \(String(describing: self.task))")
            }
            taskDetailVC.task = mytask
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}
