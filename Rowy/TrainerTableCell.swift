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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
