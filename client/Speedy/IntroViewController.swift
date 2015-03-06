//
//  ViewController3.swift
//  Speedy
//
//  Created by John Chou on 2/19/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import Alamofire

class IntroViewController: UIViewController {
    @IBOutlet weak var IntroLabel: UILabel!
    var user : FBGraphUser!
    @IBOutlet weak var yourHighScore: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        println("in intro view controller")
        if user == nil {
            println("can't get the user")
        } else {
            IntroLabel.text = "Hello " + user.first_name + "!"
            
        }
        getHighscores()
        // Do any additional setup after loading the view.
    }
    
    func getHighscores(){
        var uri = "http://mathisspeedy.herokuapp.com/HighScores/" + user.objectID
        Alamofire.request(.GET, uri)
            .responseJSON { (request, response, data, error) in
                println("request: \(request)")
                println("response: \(response)")
                println("data: \(data)")
                println("error: \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}
