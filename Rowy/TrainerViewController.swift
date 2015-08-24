//
//  TrainerViewController.swift
//  Rowy
//
//  Created by Sebastian Sandtorv  on 30/07/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class TrainerViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    @IBOutlet weak var boat1Split: UILabel!
    @IBOutlet weak var boat2Split: UILabel!
    @IBOutlet weak var boat3Split: UILabel!
    @IBOutlet weak var boat4Split: UILabel!
    
    @IBOutlet weak var boat1AVGSplit: UILabel!
    @IBOutlet weak var boat2AVGSplit: UILabel!
    @IBOutlet weak var boat3AVGSplit: UILabel!
    @IBOutlet weak var boat4AVGSplit: UILabel!
    
    @IBOutlet weak var boat1Distance: UILabel!
    @IBOutlet weak var boat2Distance: UILabel!
    @IBOutlet weak var boat3Distance: UILabel!
    @IBOutlet weak var boat4Distance: UILabel!
    
    @IBOutlet weak var boat1Name: UILabel!
    @IBOutlet weak var boat2Name: UILabel!
    @IBOutlet weak var boat3Name: UILabel!
    @IBOutlet weak var boat4Name: UILabel!
    
    var startRowing:Bool = false
    var rowDistanceBool:Bool = false
    var rowDistanceLength:Int = 0
    var resetData:Bool = false
    
    var currentPlayer:String = UIDevice.currentDevice().name
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        title = "Rowy - trainer view"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Multipeer handling
    @IBAction func connectWithPlayer(sender: AnyObject) {
        
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
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
        
        if message.objectForKey("string")?.isEqualToString("New Rowing Session") == true{
            let alert = UIAlertController(title: "Rowy", message: "\(senderDisplayName) has started a new Rowing Session", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            var Player:String! = message.objectForKey("Player") as? String
            var Distance:Int! = message.objectForKey("Distance")?.integerValue
            var Split:Int! = message.objectForKey("Split")?.integerValue
            var AVGSplit:Int! = message.objectForKey("AVGSplit")?.integerValue
            (lm,ls) = secToMin(Split)
            (sm,ss) = secToMin(AVGSplit)
            println(find(peers, Player))
            if(find(peers, Player) == nil){
                peers.append(Player)
            }
            if (find(peers, Player) == 0){
                boat1Split.text = lm + ":" + ls
                boat1AVGSplit.text = sm + ":" + ss
                boat1Distance.text = String(Distance)
                boat1Name.text = Player
            } else if (find(peers, Player) == 1){
                boat2Split.text = lm + ":" + ls
                boat2AVGSplit.text = sm + ":" + ss
                boat2Distance.text = String(Distance)
                boat2Name.text = Player
            } else if (find(peers, Player) == 2){
                boat3Split.text = lm + ":" + ls
                boat3AVGSplit.text = sm + ":" + ss
                boat3Distance.text = String(Distance)
                boat3Name.text = Player
            } else if (find(peers, Player) == 3){
                boat4Split.text = lm + ":" + ls
                boat4AVGSplit.text = sm + ":" + ss
                boat4Distance.text = String(Distance)
                boat4Name.text = Player
            } else{
                println("too many rowers connected")
            }
        }
    }
    
    @IBAction func startRowing(sender: AnyObject) {
        startRowing = true
        sendData()
        startRowing = false
        rowDistanceLength = 0
        rowDistanceBool = false
        resetData = false
    }
    
    @IBAction func start500Meter(sender: AnyObject) {
        rowGivenDistance(500)
    }
    
    @IBAction func start1000Meter(sender: AnyObject) {
        rowGivenDistance(1000)
    }
    
    @IBAction func start2000Meter(sender: AnyObject) {
        rowGivenDistance(2000)
    }
    
    func rowGivenDistance(distanceToRow: Int){
        rowDistanceBool = true
        rowDistanceLength = distanceToRow
        resetData = true
        startRowing = true
        sendData()
        startRowing = false
    }
    
    @IBAction func resetData(sender: AnyObject) {
        resetData = true
        sendData()
        resetData = false
    }
    
    
    func sendData() {
        let messageDict = ["Start":startRowing, "RowDistanceBool":rowDistanceBool,"RowDistance":rowDistanceLength, "ResetData": resetData]
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
