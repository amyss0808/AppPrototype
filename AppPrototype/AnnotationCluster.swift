//
//  AnnotationCluster.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/3/17.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MapKit

open class AnnotationCluster: NSObject {
    
    open var coordinate = CLLocationCoordinate2D()
    open var title: String?
    open var subtitle: String?
    
    open var annotations: [MKAnnotation] = []
}

extension AnnotationCluster : MKAnnotation { }
