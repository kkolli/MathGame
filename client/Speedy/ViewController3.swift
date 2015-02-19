//
//  ViewController3.swift
//  Speedy
//
//  Created by John Chou on 2/19/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    @IBOutlet weak var IntroLabel: UILabel!
    var user : FBGraphUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        println("in intro view controller")
        if user == nil {
            println("can't get the user")
        } else {
            IntroLabel.text = "Hello " + user.first_name + "!"
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
