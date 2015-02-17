//
//  ViewController2.swift
//  Speedy
//
//  Created by John Chou on 1/23/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        println("In View controller 2")
        // Do any additional setup after loading the view.
    }

    @IBAction func toGameViewController(sender: AnyObject) {
        let newView = self.storyboard?.instantiateViewControllerWithIdentifier("game") as GameCenterController
        self.navigationController?.pushViewController(newView, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
