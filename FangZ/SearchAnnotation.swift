//
//  SearchAnnotation.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/24.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

open class SearchAnnotation: NSObject {
    
    open var coordinate = CLLocationCoordinate2D()
}

extension SearchAnnotation : MKAnnotation { }
