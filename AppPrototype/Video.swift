//
//  Video.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/21.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class Video {
    
    //MARK: - Properties
    var videoId: Int
    var imageData: Data?
    var videoTitle: String
    var videoTime: String
    var videoWeather: String
    var videoElements: [String]
    
    //MARK: - Initialization
    init(videoId: Int, imageData: Data?, videoTitle: String, videoTime: String, videoWeather: String, videoElements: [String]) {
        
        self.videoId = videoId
        self.imageData = imageData
        self.videoTitle = videoTitle
        self.videoTime = videoTime
        self.videoWeather = videoWeather
        self.videoElements = videoElements
    }
}
