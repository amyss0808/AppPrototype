//
//  VideoEditViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/7.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class VideoEditViewController: UIViewController {
    
    // MARK: - Button Outlets
    @IBOutlet weak var convenienceStore: MultipleChoiceButton!
    @IBOutlet weak var supermarket: MultipleChoiceButton!
    @IBOutlet weak var hospital: MultipleChoiceButton!
    @IBOutlet weak var breakfast: MultipleChoiceButton!
    @IBOutlet weak var restaurant: MultipleChoiceButton!
    @IBOutlet weak var gasStation: MultipleChoiceButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var multipleChoicebttns = [MultipleChoiceButton]()
        multipleChoicebttns = [convenienceStore, supermarket, hospital, breakfast, restaurant, gasStation]
    
        
        for bttn in multipleChoicebttns {
            if bttn.isChoosed {
                print("\(bttn.getButtonTitle())")
            }
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
