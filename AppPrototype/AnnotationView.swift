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
    
    private var configuration: AnnotationViewConfiguration
    
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
            updateSize()
        }
    }
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.configuration = AnnotationViewConfiguration.default()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.configuration = AnnotationViewConfiguration.default()
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
        backgroundColor = UIColor.clear
        layer.borderColor = UIColor.white.cgColor
        addSubview(countLabel)
    }
    
    private func updateSize() {
        if let annotation = self.annotation as? Annotation {
            
            let count:Int = annotation.numberOfElement
            
            let template = configuration.templateForCount(count: count)
            
            switch template.displayMode {
            case .Image(let imageName):
                image = UIImage(named: imageName)
                break
            case .SolidColor(let sideLength, let color):
                backgroundColor	= color
                frame = CGRect(origin: frame.origin, size: CGSize(width: sideLength, height: sideLength))
                break
            }
            
            layer.borderWidth = template.borderWidth
            countLabel.font = template.font
            countLabel.text = "\(count)"
            
            setNeedsLayout()
        }
    }
}
