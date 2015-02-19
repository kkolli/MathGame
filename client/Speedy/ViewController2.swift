//
//  ViewController2.swift
//  Speedy
//
//  Created by John Chou on 1/23/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import Alamofire

class ViewController2: UIViewController {
    var user : FBGraphUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        println("In View controller 2")
        
        if user == nil {
            println("there's an error with retrieving friends")
        } else {
            displayFriends()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayFriends() {
        var uri = "http://mathisspeedy.herokuapp.com/friend_scores/" + user.objectID
        Alamofire.request(.GET, uri)
            .responseJSON { (request, response, data, error) in
                println("request: \(request)")
                println("response: \(response)")
                println("data: \(data)")
                println("error: \(error)")
                if error != nil {
                    println(" errors found")
                } else {
                   
                }
                
        }
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
