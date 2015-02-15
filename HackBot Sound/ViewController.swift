//
//  ViewController.swift
//  HackBot Sound
//
//  Created by Jack Cook on 2/15/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController, GCDAsyncSocketDelegate, AVSpeechSynthesizerDelegate {
    
    var trackToPlay: SPTPartialTrack!
    
    var socket: GCDAsyncSocket!
    var tag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SSKeychain.passwordForService("hackbot", account: "spotify") != nil {
            authenticateSpotify()
        } else {
            let spotifyAuth = SPTAuth.defaultInstance()
            let spotifyLoginURL = spotifyAuth.loginURLForClientId(spotifyClientID, declaredRedirectURL: NSURL(string: spotifyCallbackURL), scopes: [SPTAuthStreamingScope, SPTAuthUserLibraryReadScope])
            UIApplication.sharedApplication().openURL(spotifyLoginURL)
        }
        
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        socket.connectToHost("irc.esper.net", onPort: 6667, error: nil)
        sendData("NICK hackbotsound\r\n")
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
            
            if args[0] == "!play" {
                args.removeAtIndex(0)
                let songTitle = " ".join(args)
                
                spotifyPlayer.stop(nil)
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.delegate = self
                let utterance = AVSpeechUtterance(string: "The party train is here. Get your dancing shoes on.")
                utterance.rate = 0.1
                synthesizer.speakUtterance(utterance)
                
                SPTRequest.performSearchWithQuery(songTitle, queryType: .QueryTypeTrack, session: spotifySession, callback: { (error, list) -> Void in
                    let lp = list as SPTListPage
                    
                    if let ts = lp.items {
                        self.trackToPlay = ts[0] as SPTPartialTrack
                    }
                })
            } else if args[0] == "!say" {
                args.removeAtIndex(0)
                let speechText = " ".join(args)
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.delegate = nil
                let utterance = AVSpeechUtterance(string: speechText)
                utterance.rate = AVSpeechUtteranceMinimumSpeechRate
                synthesizer.speakUtterance(utterance)
            }
        }
    
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        spotifyPlayer.playURI(trackToPlay.uri, callback: { (error) -> Void in
            if error != nil {
                println(error.localizedDescription)
            }
        })
    }
    
    func sendData(string: String) {
        socket.writeData("\(string)\r\n".dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: tag)
        tag += 1
    }
}
