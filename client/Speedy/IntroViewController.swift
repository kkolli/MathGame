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
    @IBOutlet weak var fbProfilePic: UIImageView!
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
        userSetup()
        // Do any additional setup after loading the view.
    }
    
    func userSetup(){
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
        uri = "http://graph.facebook.com/\(user.objectID)/picture?type=large"
        let url = NSURL(string:uri)
        let urlRequest = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            // Display the image
            let image = UIImage(data: data)
            self.fbProfilePic.image = image
            
        }    }

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
