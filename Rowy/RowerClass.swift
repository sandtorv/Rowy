//
//  rowerDataClass.swift
//  Rowy
//
//  Created by Sebastian Sandtorv  on 03/08/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import Foundation

class Rower  {
    
    var rowerName = ""
    var liveSplit = 0
    var avgsplit = 0
    var distance = 0
    
    func createUser(RowerName: String, LiveSplit: Int, AVGSplit: Int, Distance: Int){
        rowerName = RowerName
        liveSplit = LiveSplit
        avgsplit = AVGSplit
        distance = Distance
    }
    
    func updateData(LiveSplit: Int, AVGSplit: Int, Distance: Int){
        liveSplit = LiveSplit
        avgsplit = AVGSplit
        distance = Distance
    }
    
}