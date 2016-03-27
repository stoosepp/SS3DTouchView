//
//  ViewController.swift
//  SS3DTouchView
//
//  Created by Stoo on 2016-01-08.
//  Copyright © 2016 Monotreme. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SSForceButtonDelegate {

    @IBOutlet weak var forceLabel: UILabel!
    @IBOutlet weak var forceButton: ForceButton!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        forceButton.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    func updateForceLabel(currentforceValue: CGFloat) {
        forceLabel.text = (String(format:"%.2f", currentforceValue)) + "%"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  @IBAction func updateButton(sender: AnyObject) {
    print(sender.selectedSegmentIndex)
    switch sender.selectedSegmentIndex {
    case 0:
        print("Shadow Above Selected")
        forceButton.maxShadowOffset = CGSize(width: 10, height: 10)
        forceButton.maxShadowRadius = 10.0
        forceButton.minShadowRadius = 2.0
        forceButton.initializeButton(.ShadowAbove)
    case 1:
        print("Shadow Below Selected")
        forceButton.maxShadowOffset = CGSize(width: 0, height: 0)
        forceButton.maxShadowRadius = 5.0
        forceButton.minShadowRadius = 1.0
        forceButton.initializeButton(.ShadowBelow)
    case 2:
        print("Flat Shadow Above Selected")
        forceButton.maxShadowOffset = CGSize(width: 20, height: 20)
        forceButton.initializeButton(.FlatShadowAbove)
    case 3:
        forceButton.maxShadowRadius = 100
        forceButton.initializeButton(.Pincushion)
    case 4:
        forceButton.initializeButton(.SquareTopBorder)
    case 5:
        forceButton.initializeButton(.CircleBorder)
    case 6:
        forceButton.initializeButton(.BarnDoor)
    default:
        print("Nothing Selected")
    }
    
        }
    
    @IBAction func toggleBottomHit(sender: UISwitch) {
        if sender.on
        {
            forceButton.bottomHit = true
        }
        else
        {
            forceButton.bottomHit = false
        }
    }
}

