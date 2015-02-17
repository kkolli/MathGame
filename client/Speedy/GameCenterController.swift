//
//  GameCenterController.swift
//  Speedy
//
//  Created by Krishna Kolli on 2/12/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit

class GameCenterController: UIViewController {
    /// GameCenter
    var gameCenter: GameCenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameCenter = GameCenter(rootViewController: self)
        self.gameCenter.loginToGameCenter() {
            (result: Bool) in
            if result {
                /* Player is loggedin Game Center OR Open Windows for login in Game Center */
                println("Logged in")
                
            } else {
                /* Player is not logged in Game Center */
                println("Not Logged in")
                //TODO: Need to add navigation for our app between Views
            }
        }
    }
}