//
//  VideoEditViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/7.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class VideoEditViewController: UIViewController {
    
    // MARK: - Navigation Properties
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    var test = ""
    
    
    // MARK: - Button Outlets
    @IBOutlet var publicFacilityBttns: [MultipleChoiceButton]!
    @IBOutlet var storeBttns: [MultipleChoiceButton]!
    @IBOutlet var weatherBttns: [MultipleChoiceButton]!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        doneBarButton.target = self.presented
//        doneBarButton.action = #selector(TaskDetailViewController.doneEditing)
//
//        
//        cancelBarButton.target = TaskDetailViewController()
//        cancelBarButton.action = #selector(TaskDetailViewController.cancelEditing)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for bttn in publicFacilityBttns {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(bttn.titleLabel?.text)")
                    return
                }
                print("\(bttnTitle)")
            }
        }
        
        for bttn in storeBttns {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(bttn.titleLabel?.text)")
                    return
                }
                print("\(bttnTitle)")
            }
        }
        
        for bttn in weatherBttns {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    print("The button has no titleLabel: \(bttn.titleLabel?.text)")
                    return
                }
                print("\(bttnTitle)")
            }
        }
    }
    
    
    
    @IBAction func multipleChoiceBttnTapped(_ sender: MultipleChoiceButton) {
        
        // default "isChoosed" = false
        if sender.isChoosed {
            sender.isChoosed = false
        } else {
            sender.isChoosed = true
        }
    }
    
    
    @IBAction func SingleChoiceBttnTapped(_ sender: MultipleChoiceButton) {
        
        // default "isChoosed" = false
        sender.isChoosed = true
        
        for bttn in weatherBttns {
            if bttn.tag != sender.tag {
                bttn.isChoosed = false
            }
        }
    }
    
    
    func doneButtonStatus() {
        var count = 0
        for bttn in weatherBttns {
            if bttn.isChoosed == false {
                count += 1
            }
        }
        if count == weatherBttns.count {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    
    @IBAction func doneEditing(_ sender: UIBarButtonItem) {
        print("done")
        print("\(test)")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func CancelEditing(_ sender: UIBarButtonItem) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
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
