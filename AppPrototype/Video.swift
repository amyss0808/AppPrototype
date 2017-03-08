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
    var videoTitle: String
    var videoTime: String
    
    //MARK: - Initialization
    init(videoId: Int, videoTitle: String, videoTime: String) {
        self.videoId = videoId
        self.videoTime = videoTime
        self.videoTitle = videoTitle
    }
}
