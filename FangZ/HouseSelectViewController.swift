//
//  HouseSelectViewController.swift
//  FangZ
//
//  Created by 鍾妘 on 2017/5/4.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class HouseSelectViewController: UIViewController {
    
    @IBOutlet var sectionViews: [UIView]!
    
    @IBOutlet var storeButtons: [VideoEditVCButton]!
    @IBOutlet var publicFacilityButtons: [VideoEditVCButton]!
    @IBOutlet var environmentButtons: [VideoEditVCButton]!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var constraintParameter: Dictionary<String, String> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.decorateSectionViews()
        self.updateButtonStatus()
    }
    
    private func decorateSectionViews() {
        for view in self.sectionViews {
            view.layer.cornerRadius = 8
            view.layer.shadowOffset = CGSize(width: -1, height: 1)
            view.layer.shadowOpacity = 0.2
        }
    }
    
    private func updateButtonStatus() {
        var numberOfNothing = 0
        for (_, value) in self.constraintParameter {
            if value == "nothing" {
                numberOfNothing += 1
            } else {
                continue
            }
        }
        guard !self.constraintParameter.isEmpty, numberOfNothing != 3 else {
            return
        }
        
        if let storeStr = self.constraintParameter["shop"] , storeStr != "nothing" {
            let storeArray = storeStr.components(separatedBy: ",")
            for store in storeArray {
                for storeBttn in self.storeButtons {
                    guard let bttnTitle = storeBttn.titleLabel?.text else {
                        fatalError("The \(storeBttn.tag) button in facility doesn't have title!")
                    }
                    if store == bttnTitle {
                        storeBttn.isChoosed = true
                        break
                    } else {
                        continue
                    }
                }
            }
        }
        
        if let facilityStr = self.constraintParameter["facility"] , facilityStr != "nothing" {
            let facilityArray = facilityStr.components(separatedBy: ",")
            for facility in facilityArray {
                for facilityBttn in self.publicFacilityButtons {
                    guard let bttnTitle = facilityBttn.titleLabel?.text else {
                        fatalError("The \(facilityBttn.tag) button in facility doesn't have title!")
                    }
                    if facility == bttnTitle {
                        facilityBttn.isChoosed = true
                        break
                    } else {
                        continue
                    }
                }
            }
        }
        
        if let environmentStr = self.constraintParameter["environment"] , environmentStr != "nothing" {
            let environmentArray = environmentStr.components(separatedBy: ",")
            for environment in environmentArray {
                for environmentBttn in self.environmentButtons {
                    guard let bttnTitle = environmentBttn.titleLabel?.text else {
                        fatalError("The \(environmentBttn.tag) button in facility doesn't have title!")
                    }
                    if environment == bttnTitle {
                        environmentBttn.isChoosed = true
                        break
                    } else {
                        continue
                    }
                }
            }
        }
    }
    
    private func createconstraintParameter () -> Dictionary<String, String>{
        var stores: String = ""
        var publicFacilities: String = ""
        var environment: String = ""
        
        for bttn in self.storeButtons {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    fatalError("The \(bttn.tag) button in stores doesn't have title!")
                }
                stores += bttnTitle + ","
            }
        }
        
        if stores.isEmpty {
            stores = "nothing"
        } else {
            stores = String(stores.characters.dropLast())
        }
        
        for bttn in self.publicFacilityButtons {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    fatalError("The \(bttn.tag) button in facility doesn't have title!")
                }
                publicFacilities += bttnTitle + ","
            }
        }
        
        if publicFacilities.isEmpty {
            publicFacilities = "nothing"
        } else {
            publicFacilities = String(publicFacilities.characters.dropLast())
        }
        
        for bttn in self.environmentButtons {
            if bttn.isChoosed {
                guard let bttnTitle = bttn.titleLabel?.text else {
                    fatalError("The \(bttn.tag) button in environment doesn't have title!")
                }
                environment += bttnTitle + ","
            }
        }
        
        if environment.isEmpty {
            environment = "nothing"
        } else {
            environment = String(environment.characters.dropLast())
        }
        
       return ["shop": stores, "facility": publicFacilities, "environment": environment]
    }
    
    @IBAction func tagButtonTapped(_ sender: VideoEditVCButton) {
        // default: isChoosed == false
        if sender.isChoosed == true {
            sender.isChoosed = false
        } else {
            sender.isChoosed = true
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        for storeBttn in self.storeButtons {
            storeBttn.isChoosed = false
        }
        for facilityBttn in self.publicFacilityButtons {
            facilityBttn.isChoosed = false
        }
        for environmentBttn in self.environmentButtons {
            environmentBttn.isChoosed = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button == searchButton else {
            fatalError("Unexpected Sender trigger houseSelectViewController prepare function")
        }
        self.constraintParameter = self.createconstraintParameter()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
