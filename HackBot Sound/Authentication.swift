//
//  Authentication.swift
//  HackBot Sound
//
//  Created by Jack Cook on 2/15/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import Foundation

var spotifySession: SPTSession!
var spotifyPlayer: SPTAudioStreamingController!

let spotifyClientID = "a6baf690124b4790b088065c475547e2"
let spotifyCallbackURL = "hackbot-login://spotify"
let spotifyTokenSwapURL = "http://104.236.207.39:1234/swap"
let spotifyTokenRefreshURL = "http://104.236.207.39:1234/refresh"

func authenticateSpotifyWithURL(url: NSURL) {
    if SPTAuth.defaultInstance().canHandleURL(url, withDeclaredRedirectURL: NSURL(string: spotifyCallbackURL)) {
        SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, tokenSwapServiceEndpointAtURL: NSURL(string: spotifyTokenSwapURL), callback: { (error, session) -> Void in
            if error != nil {
                println("Auth from url error: \(error.localizedDescription)")
                return
            }
            
            let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
            let sessionString = sessionData.base64EncodedStringWithOptions(nil)
//            SSKeychain.setPassword(sessionString, forService: "harmonize", account: "spotify")
            
            spotifySession = session
            spotifyPlayer = SPTAudioStreamingController(clientId: spotifyClientID)
            
            spotifyPlayer.loginWithSession(spotifySession, callback: nil)
        })
    }
}
