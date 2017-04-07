//
//  StartEndPointAnnotation.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/4/7.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MapKit

enum Pointposition: String {
    case start
    case end
}


class StartEndPointAnnotation: MKPointAnnotation {

    let position: Pointposition
    
    init(position: Pointposition) {
        self.position = position
    }
}
