//
//  TrainerTableView.swift
//  Rowy
//
//  Created by Sebastian Sandtorv  on 03/08/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

var peersTablerray:[String] = []

class TrainerTableViewController: UIViewController, UITableViewDelegate, MCBrowserViewControllerDelegate {
    
    var rowerArray: [Rower] = []
    var peers:[String] = []
    
    var newRower = Rower()
    
    @IBOutlet weak var tableView: UITableView!
    
    var startRowing:Bool = false
    var rowDistanceBool:Bool = false
    var rowDistanceLength:Int = 0
    var resetData:Bool = false
    
    var currentPlayer:String = UIDevice.currentDevice().name
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Rowy table"
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.layoutMargins = UIEdgeInsetsZero
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadData()
    }
    
    func reloadData(){
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewControllerxw
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowerArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! trainerTableCell
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        } else{
            cell.backgroundColor = .whiteColor()
        }
        cell.tintColor = .lightGrayColor()
        cell.rowerNameLabel.text = "\(peers[indexPath.row])"
        cell.splitLabel.text = "\(secToMin(rowerArray[indexPath.row].liveSplit))"
        cell.AVGSplitLabel.text = "\(secToMin(rowerArray[indexPath.row].avgsplit))"
        cell.distanceLabel.text = "\(rowerArray[indexPath.row].distance)m"
        return cell
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
        
        if message.objectForKey("string")?.isEqualToString("NewSession") == true{
            let alert = UIAlertController(title: "Rowy", message: "\(senderDisplayName) has started a new Rowing Session", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            var RowerName:String! = message.objectForKey("Player") as? String
            var Distance:Int! = message.objectForKey("Distance")?.integerValue
            var Split:Int! = message.objectForKey("Split")?.integerValue
            var AVGSplit:Int! = message.objectForKey("AVGSplit")?.integerValue
            if(find(peers, RowerName) == nil){
                peers.append(RowerName)
                newRower.createUser(RowerName, LiveSplit: Split, AVGSplit: AVGSplit, Distance: Distance)
                rowerArray.append(newRower)
            }
            if (find(peers, RowerName) != nil){
                var updateRower = Rower()
                var pos: Int! = find(peers, RowerName)
                updateRower.updateData(Split, AVGSplit: AVGSplit, Distance: Distance)
                rowerArray[pos] = updateRower
            } else{
                println("Something funky happend")
            }
            reloadData()
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
        if(peers.count > 0){
            rowDistanceBool = true
            rowDistanceLength = distanceToRow
            resetData = true
            startRowing(self)
        }
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
    @IBAction func showHelp(sender: AnyObject) {
        let alert = UIAlertController(title: "How to use",
            message:"Start by clicking the Connect Rowers button to connect all rowers (max. 7). When this is done you will see live performance data from all rowers. \n \n To start rowing a given distance for all boats, select the distance to row in the bottom right corner. The clock will start counting when the rower start to row. \n \n Remeber to turn on Bluetooth and WiFi to communicate with the boats!",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
}