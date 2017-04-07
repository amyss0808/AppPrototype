//
//  Annotation.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/3/17.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Annotation: NSObject {
    
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var id: Int = 0
    var address = ""
    var numberOfElement = 1
}

extension Annotation : MKAnnotation { }
