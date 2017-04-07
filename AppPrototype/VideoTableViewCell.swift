//
//  VideoTableViewCell.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/21.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    //MARK: - Properties
    @IBOutlet weak var videoTime: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var roundedView: UIView!
    
    @IBOutlet var elementLabels: [UILabel]!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        roundedView.layer.backgroundColor = UIColor(red: 94.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.5).cgColor
        roundedView.layer.masksToBounds = false
        roundedView.layer.cornerRadius = 7.0
        roundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        roundedView.layer.shadowOpacity = 0.2
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
