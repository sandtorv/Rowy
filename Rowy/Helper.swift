//
//  LocationHelper.swift
//  Rowy
//
//  Created by Sebastian Sandtorv  on 02/07/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import Foundation
import CoreLocation

var initialLocation = CLLocation()

extension Double{
    // lengths
    var km: Double { return self * 1_000.0 }
    var m:  Double { return self }
    var cm: Double { return self / 100.0 }
    var mm: Double { return self / 1_000.0 }
    var ft: Double { return self / 3.28084 }
    
    // decimals
    var oneDec: Double {return (round(10*self)/10)}
    var twoDec: Double {return (round(100*self)/100)}
}


// Helper functions
func secToMin (seconds : Int) -> String {
    var num1: String = twoDigits((seconds % 3600) / 60)
    var num2: String = twoDigits((seconds % 3600) % 60)
    return num1 + ":" + num2
}

func twoDigits(num: Int) -> String{
    if(num < 10){
        return "0" + String(num)
    } else{
        return String(num)
    }
}

func average(numbers: [Int]) -> Double {
    var sum = 0
    for number in numbers {
        sum += number
    }
    var  ave : Double = Double(sum) / Double(numbers.count)
    return ave
}