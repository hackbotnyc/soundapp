//
//  ViewController.swift
//  HackBot Sound
//
//  Created by Jack Cook on 2/15/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GCDAsyncSocketDelegate {

    var socket: GCDAsyncSocket!
    var tag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        socket.connectToHost("irc.esper.net", onPort: 6667, error: nil)
        sendData("NICK hackbot\r\n")
        sendData("USER hackbot irc.esper.net bla :HackBot\r\n")
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        var message = NSString(data: data, encoding: NSUTF8StringEncoding)!
        message = message.stringByReplacingOccurrencesOfString("\n", withString: "")
        print(message)
        
        var args = message.componentsSeparatedByString(" ") as [String]
        
        if args[0] as NSString == "PING" {
            sendData("PONG \(args[1])")
        }
        
        if message.rangeOfString(":End of /MOTD command").location != NSNotFound {
            sendData("JOIN #hackcooper")
        }
        
        if args.count >= 4 {
            args.removeAtIndex(0)
            args.removeAtIndex(0)
            args.removeAtIndex(0)
            args[0] = args[0].stringByReplacingOccurrencesOfString(":", withString: "")
            
            if args[0] == "!say" {
                args.removeAtIndex(0)
                let speechText = " ".join(args)
            }
        }
    
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        println("partial data")
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("connected")
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        println("disconnect")
    }
    
    func sendData(string: String) {
        socket.writeData("\(string)\r\n".dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: tag)
        tag += 1
    }
}
