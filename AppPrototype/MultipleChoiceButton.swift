//
//  CheckBox.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/16.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class MultipleChoiceButton: UIButton {
    
    var isChoosed: Bool = false {
        didSet {
            if isChoosed == true {
                self.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            } else {
                self.backgroundColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1)
            }
        }
    }
    
    
    
    // called when the view is loaded from IB
    override func awakeFromNib() {
        self.layer.cornerRadius = 4
        self.isChoosed = false
    }
    
    
 

    func getButtonTitle() -> String? {
        return self.titleLabel?.text
    }
    
}
