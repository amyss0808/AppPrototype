//
//  AnnotationView.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/3/17.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import MapKit

class AnnotationView: MKAnnotationView {
    
    public let countLabel: UILabel = {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 2
        label.numberOfLines = 1
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    public override var annotation: MKAnnotation? {
        didSet {
            updateCount()
        }
    }
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        countLabel.frame = bounds
        layer.cornerRadius = bounds.size.width / 2
    }
    
    private func setupView() {
        layer.borderWidth = 3
        frame = CGRect(origin:  frame.origin, size: CGSize(width: 34, height: 34))
        backgroundColor = UIColor.darkGray
        layer.borderColor = UIColor.white.cgColor
        addSubview(countLabel)
    }
    
    private func updateCount() {
        if let annotation = self.annotation as? Annotation {
            countLabel.text = String(annotation.numberOfElement)
        }
        setNeedsLayout()
    }
    
}
