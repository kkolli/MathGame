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
    var appDelegate:AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup the user instance
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        println("in intro view controller")
        if user == nil {
            self.user = appDelegate.user
        }
        IntroLabel.text = "Hello " + user.first_name + "!"

        getHighscores()
        // Do any additional setup after loading the view.
    }
    
    func getHighscores(){
        var uri = "http://mathisspeedy.herokuapp.com/OneHighScore/" + user.objectID
        Alamofire.request(.GET, uri)
            .responseJSON { (request, response, data, error) in
                println("request: \(request)")
                println("response: \(response)")
                println("data: \(data)")
                println("error: \(error)")
                if error != nil || data == nil ||  data!.objectForKey("highscore") == nil {
                    println(" errors found")
                } else {
                    var highscoreValue:NSInteger = data!.objectForKey("highscore") as NSInteger
                    println(highscoreValue)
                    self.yourHighScore.text = "Your Score: " + String(highscoreValue)
                    
                }
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
