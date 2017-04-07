//
//  AnnotationCluster.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/3/17.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MapKit

class AnnotationCluster: NSObject {
    
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
    
    var annotations: [MKAnnotation] = []
}

extension AnnotationCluster : MKAnnotation { }
