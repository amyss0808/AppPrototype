//
//  House.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/21.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class House {
    
    // MARK: - Properties
    var houseIndex: Int
    var houseTitle: String
    var houseAddress: String
    var housePrice: String
    var houseSquare: String
    var houseType: String
    
    // MARK: - Initialization
    init(houseIndex: Int, houseTitle: String, houseAddress: String, housePrice: String, houseSquare: String, houseType: String) {
        self.houseIndex = houseIndex
        self.houseTitle = houseTitle
        self.houseAddress = houseAddress
        self.housePrice = housePrice
        self.houseSquare = houseSquare
        self.houseType = houseType
    }
    
}
