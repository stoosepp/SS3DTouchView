//
//  ViewController.swift
//  SS3DTouchView
//
//  Created by Stoo on 2016-01-08.
//  Copyright © 2016 Monotreme. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SSForceButtonDelegate {

    @IBOutlet weak var forceLabel: UILabel!
    @IBOutlet weak var forceButton: ForceButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var selectedIndexPath:IndexPath?
    var compareButtonRect:CGRect!
   
    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        forceButton.delegate = self
        compareButtonRect = CGRect()
        compareButtonRect = compareButton.frame
        updateButton(0)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func updateForceLabel(_ currentforceValue: CGFloat) {
        forceLabel.text = (String(format:"%.2f", currentforceValue)) + "%"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  func updateButton(_ type: Int) {
    resetCompareButton()
    if forceButton.frame.origin.y != compareButton.frame.origin.y{
        forceButton.frame.origin = CGPoint(x: forceButton.frame.origin.x + forceButton.maxShadowOffset.width, y: forceButton.frame.origin.y + forceButton.maxShadowOffset.height)

    }
    
    switch type {
    case 0:
        print("Drop Shadow Selected")
        forceButton.maxShadowOffset = CGSize(width: 0, height: 40)
        forceButton.maxShadowRadius = 10.0
        forceButton.minShadowRadius = 2.0
        forceButton.initializeButton(.dropShadow)
        compareButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        compareButton.layer.shadowColor = UIColor.gray.cgColor
        compareButton.layer.shadowOpacity = 0.8
        compareButton.layer.shadowRadius = 2
    case 1:
        print("Inner Shadow Selected")
        forceButton.maxShadowOffset = CGSize(width: 0, height: 0)
        forceButton.maxShadowRadius = 5.0
        forceButton.minShadowRadius = 1.0
        forceButton.initializeButton(.innerShadow)
    case 2:
        print("Flat Shadow Selected")
        forceButton.maxShadowOffset = CGSize(width: 10, height: 10)
        forceButton.initializeButton(.flatShadow)
    case 3:
        print("Size Scale Selected")
        forceButton.initializeButton(.sizeScale)
        compareButton.frame.size = CGSize(width: compareButton.frame.size.width/2, height: compareButton.frame.size.height/2)
        compareButton.frame.origin = compareButtonRect.origin
    case 4:
        print("Depth Of FieldSelected")
        forceButton.initializeButton(.depthOfField)
        //compareButton.blurView(5)
    case 5:
        forceButton.initializeButton(.color)
        compareButton.backgroundColor = UIColor.lightGray
        print("Color Selected")
    case 6:
        forceButton.initializeButton(.progressBar)
    case 7:
        forceButton.initializeButton(.circleProgress)
    case 8:
        forceButton.maxShadowRadius = 100
        forceButton.initializeButton(.pincushion)
        forceButton.bgColor = UIColor.clear
    case 9:
        forceButton.initializeButton(.barnDoor)
    default:
        print("Nothing Selected")
    }
    }
    
    func resetCompareButton(){

        //compareButton.removeBlur()
        print("Compare button is \(compareButton)")
        compareButton.layer.shadowOffset.width = 0.0
        compareButton.layer.shadowOffset.height = 0.0
        compareButton.layer.shadowRadius = 0.0
        if compareButton.frame.size.height < 50{
            compareButton.frame.size = forceButton.frame.size
        }
        compareButton.backgroundColor = UIColor.darkGray
        compareButton.frame.origin = compareButtonRect.origin
    }
    
    @IBAction func toggleBottomHit(_ sender: UISwitch) {
        if sender.isOn
        {
            forceButton.bottomHit = true
        }
        else
        {
            forceButton.bottomHit = false
        }
    }
    //MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Shadows"
        case 1:
            return "Misc"
        case 2:
            return "Quantified"
        case 3:
            return "Fun"
        default:
            return "None"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return 2
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "TouchTypeCell")! as UITableViewCell
        var title = ""
        switch indexPath.section {
        case 0://Shadows
            switch indexPath.row {
            case 0:
                title = "Drop Shadow"
            case 1:
                title = "Inner Shadow"
            case 2:
                title = "Flat Shadow"
            default:
                title = "None"
            }
        case 1://Misc
            switch indexPath.row {
            case 0:
                title = "Size / Scale"
            case 1:
                title = "Depth of Field"
            case 2:
                title = "Color"
            default:
                title = "None"
            }
        case 2://Quantified
            switch indexPath.row {
            case 0:
                title = "Progress Bar"
            case 1:
                title = "Circle Progress"

            default:
                title = "None"
            }
        case 3://Fun
            switch indexPath.row {
            case 0:
                title = "Pincushion"
            case 1:
                title = "Barn Door"
            default:
                title = "None"
            }
        default:
            title = "None"
        }
        if selectedIndexPath == nil{
            selectedIndexPath = IndexPath(row: 0, section: 0)
        }
        
        if indexPath == selectedIndexPath{
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        cell.textLabel?.text = title
        
        return cell
    }
    
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var buttonType = 0
        switch indexPath.section {
        case 0://Shadows
            switch indexPath.row {
            case 0:
                title = "Drop Shadow"
                buttonType = ForceButtonType.dropShadow.rawValue
            case 1:
                title = "Inner Shadow"
                buttonType = ForceButtonType.innerShadow.rawValue
            case 2:
                title = "Flat Shadow"
                buttonType = ForceButtonType.flatShadow.rawValue
            default:
                title = "None"
                buttonType = ForceButtonType.none.rawValue
            }
        case 1://Misc
            switch indexPath.row {
            case 0:
                title = "Size / Scale"
                buttonType = ForceButtonType.sizeScale.rawValue
            case 1:
                title = "Depth of Field"
                buttonType = ForceButtonType.depthOfField.rawValue
            case 2:
                title = "Color"
                buttonType = ForceButtonType.color.rawValue
            default:
                title = "None"
                buttonType = ForceButtonType.none.rawValue
            }
        case 2://Quantified
            switch indexPath.row {
            case 0:
                title = "Progress Bar"
                buttonType = ForceButtonType.progressBar.rawValue
            case 1:
                title = "Circle Progress"
                buttonType = ForceButtonType.circleProgress.rawValue
                
            default:
                title = "None"
                buttonType = ForceButtonType.none.rawValue
            }
        case 3://Fun
            switch indexPath.row {
            case 0:
                title = "Pincushion"
                buttonType = ForceButtonType.pincushion.rawValue
            case 1:
                title = "Barn Door"
                buttonType = ForceButtonType.barnDoor.rawValue
            default:
                title = "None"
            }
        default:
            title = "None"
        }
        if selectedIndexPath != indexPath{
            updateButton(buttonType)
            selectedIndexPath = indexPath
        }
        
        print("Tapped Cell")
        tableView.reloadData()
    }
}

