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

open class Annotation: NSObject {
    
    open var coordinate = CLLocationCoordinate2D()
    open var title: String?
    open var id: Int = 0
    open var address = ""
    open var numberOfElement = 1
}

extension Annotation : MKAnnotation { }
