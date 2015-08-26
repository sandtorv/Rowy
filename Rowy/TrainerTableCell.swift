//
//  TrainerTableCell.swift
//  Rowy
//
//  Created by Sebastian Sandtorv  on 03/08/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import Foundation
import UIKit

class trainerTableCell: UITableViewCell {
    
    @IBOutlet weak var rowerNameLabel:  UILabel!
    @IBOutlet weak var splitLabel:  UILabel!
    @IBOutlet weak var AVGSplitLabel:  UILabel!
    @IBOutlet weak var distanceLabel:  UILabel!
    
    @IBOutlet weak var liveSplitTitle: UILabel!
    @IBOutlet weak var AVGSplitTitle: UILabel!
    @IBOutlet weak var distanceTitle: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            let thatFont: UIFont = UIFont(name: "HelveticaNeue", size: 18)!
            liveSplitTitle.font = thatFont
            AVGSplitTitle.font = thatFont
            distanceTitle.font = thatFont
            
            let thisFont: UIFont = UIFont(name: "HelveticaNeue", size: 28)!
            rowerNameLabel.font = thisFont
            splitLabel.font = thisFont
            AVGSplitLabel.font = thisFont
            distanceLabel.font = thisFont
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}