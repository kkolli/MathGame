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
        self.gameCenter = GameCenter(rootViewController: self)
        self.gameCenter.loginToGameCenter()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
}