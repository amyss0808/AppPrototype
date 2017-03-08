//
//  HousePin.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/21.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class HousePin {
    
    //MARK: - Properties
    var latitude: Double
    var longitude: Double
    var address: String
    
    // MARK: - Initilization
    init(latitude: Double, longitude: Double, address: String) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
