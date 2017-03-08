//
//  HouseTableViewCell.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/21.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class HouseTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var houseTitle: UILabel!
    @IBOutlet weak var houseAddress: UILabel!
    @IBOutlet weak var houseTypeAndSquare: UILabel!
    @IBOutlet weak var housePrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
