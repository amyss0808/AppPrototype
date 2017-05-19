//
//  Task.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/9.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class Task {
    var taskId: String
    var taskTitle: String
    var taskDistance: String
    var taskDuration: String
    var taskStartPointLatitude: Double
    var taskStartPointLongitude: Double
    var taskEndPointLatitude: Double
    var taskEndPointLongitude: Double
    var taskIsNear: Bool
    
    
    init(taskId: String, taskTitle: String, taskDistance: String, taskDuration: String, taskStartPointLatitude: Double, taskStartPointLongitude: Double, taskEndPointLatitude: Double, taskEndPointLongitude: Double, taskIsNear: Bool) {
        
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.taskDistance = taskDistance
        self.taskDuration = taskDuration
        self.taskStartPointLatitude = taskStartPointLatitude
        self.taskStartPointLongitude = taskStartPointLongitude
        self.taskEndPointLatitude = taskEndPointLatitude
        self.taskEndPointLongitude = taskEndPointLongitude
        self.taskIsNear = taskIsNear
    }
    
}


