//
//  ViewController.swift
//  Rowy
//
//  Created by Sebastian Sandtorv  on 01/07/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import UIKit
import CoreLocation
import MultipeerConnectivity

class RowerViewController: UIViewController, CLLocationManagerDelegate, MCBrowserViewControllerDelegate {

    var currentPlayer:String = UIDevice.currentDevice().name
    var appDelegate:AppDelegate!
    
    var timer: NSTimer!
    
    var startTime: NSDate!
    
    let location = CLLocationManager()
    var distanceCount:Double = 0
    var timeRowed:Double = 0
    var started: Bool = false
    
    var split:Int = 0
    var AVGsplit:Int = 0
    
    var distance:Int = 0
    
    var liveSplitString: String = ""
    var avgSplitString: String = ""
    
    var distanceCountdown: Bool = false
    var distanceToRow: Int = 0
    var distanceTime: Double = 0
    var distanceTimeInt: Int = 0
    
    @IBOutlet weak var startStopButton: UIBarButtonItem!
    
    // Labels outlet
    @IBOutlet weak var splitLive: UILabel!
    @IBOutlet weak var splitAVG: UILabel!
    @IBOutlet weak var tripDistance: UILabel!
    
    @IBOutlet weak var splitLiveTitle: UILabel!
    @IBOutlet weak var splitAVGTitle: UILabel!
    @IBOutlet weak var tripDistanceTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Delegates
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
  
        // Check if location services is enabled
        if(CLLocationManager.locationServicesEnabled()){
            location.startUpdatingLocation()
        } else{
            location.requestAlwaysAuthorization()
        }
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        resetData()
        startRowing()
        title = "Rowy - rower mode"
        
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
            location.startUpdatingLocation()
        } else {
            location.requestAlwaysAuthorization()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startRowing(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("sendData"), userInfo: nil, repeats: true)
        startTime = NSDate()
        started = true
    }
    
    
    func startRowingDistance(distance: Int){
        distanceToRow = distance
        timeRowed = 0
        startRowing()
        println("Should row distance \(distance)")
    }
    
    func stopRowing(){
        started = false
        resetData()
    }
    
    @IBAction func resetDataBtn(sender: AnyObject) {
        resetData()
    }
    func resetData() {
        locationsArray.removeAll()
        distanceCount = 0
        timeRowed = 0
        AVGsplit = 0
        split = 0
        distance = 0
        if(timer != nil){
            timer.invalidate()
        }
        startRowing()
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationsArray.append(locations[0] as! CLLocation)
        
        if (locationsArray.count > 1 && started){
            
            var sourceIndex = locationsArray.count - 1
            var destinationIndex = locationsArray.count - 2
            
            var avgSpeed = 0.0
            if(((locationsArray[sourceIndex].speed + locationsArray[destinationIndex].speed) / 2) > 0){
                avgSpeed = ((locationsArray[sourceIndex].speed + locationsArray[destinationIndex].speed) / 2)
                liveSplitString = secToMin(Int(500/avgSpeed))
                split = Int(500/avgSpeed)
                var distanceBetween: CLLocationDistance =
                locationsArray[sourceIndex].distanceFromLocation(locationsArray[destinationIndex])
                distanceCount += distanceBetween
            } else {
                liveSplitString = "00:00"
                split = 0
            }
            if(distanceCount > 0 && timeRowed > 0){
                AVGsplit = (Int(500/((distanceCount/timeRowed)*2)))
                if (AVGsplit > 3599){
                    AVGsplit = 3599
                }
                avgSplitString = secToMin(AVGsplit)
            } else {
                AVGsplit = 0
                timeRowed = 0
                avgSplitString = "00:00"
            }
            
        }
    }
    
    
    // MARK: Multipeer handling
    func peerChangedStateWithNotification(notification:NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.objectForKey("state") as! Int
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        if message.objectForKey("string")?.isEqualToString("NewSession") == true{
            let alert = UIAlertController(title: "New Rowing Session", message: "\(senderDisplayName) has invited you to a new Rowing Session", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            var Start:Bool = message.objectForKey("Start") as! Bool
            var RowDistance:Int! = message.objectForKey("RowDistance")?.integerValue
            var RowDistanceBool:Bool = message.objectForKey("RowDistanceBool") as! Bool
            var ResetData: Bool = message.objectForKey("ResetData") as! Bool
            distanceToRow = RowDistance
            distanceCountdown = RowDistanceBool
            if ResetData{
                resetData()
            }
            if Start{
                startRowing()
            }
            if(distanceCountdown){
                startRowingDistance(distanceToRow)
            }
        }
    }
    
    
    func sendData() {
        // Update Labels
        splitLive.text = liveSplitString
        splitAVG.text = avgSplitString
        
        if (distanceCountdown){
            tripDistanceTitle.text = "Distance left"
            var distanceLeft: Int = Int(distanceToRow-Int(distanceCount))
            tripDistance.text = "\(distanceLeft)m"
            if(distanceLeft < 1){
                distanceCountdown = false
                distanceTime = timeRowed
                var timeNow = NSDate()
                let timeElapsed = timeNow.timeIntervalSinceDate(startTime)
                let alert = UIAlertController(title: "You finished \(distanceToRow)m", message: "You rowed \(distanceToRow)m in \(secToMin(Int(timeElapsed)))!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)

            }
        } else {
            tripDistanceTitle.text = "Distance"
            tripDistance.text = "\(Int(distanceCount))m"
        }
        
        // Append time to rowed
        timeRowed += 0.5
    
        let messageDict = ["Player":currentPlayer, "Distance":Int(distanceCount), "Split":split, "AVGSplit":AVGsplit]
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var error:NSError?
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }

}
