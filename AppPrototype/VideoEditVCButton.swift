//
//  CheckBox.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/16.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class VideoEditVCButton: UIButton {
    
    // MARK: - Properties
    var isChoosed: Bool = false {
        didSet {
            if isChoosed == true {
                self.backgroundColor = UIColor(red: 75/255, green: 104/255, blue: 157/255, alpha: 1)
            } else {
                self.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
            }
        }
    }
    
    
    // MARK: - View Functions
    // called when the view is loaded from IB
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.isChoosed = false
    }
}
