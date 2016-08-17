//
//  MainMenuViewController.swift
//  Speedy
//
//  Created by Edward Chiou on 3/8/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import Alamofire

class MainMenuViewController: UITabBarController {
    var user : FBGraphUser!
    var friendScores: [(String, Int)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendScores = []
        
        let navVC = self.viewControllers![0] as UINavigationController
        let introVC = navVC.topViewController as IntroViewController
        introVC.user = user
        getFriends(loadAfterGetFriends)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadAfterGetFriends(){
        let friendScoreVC = self.viewControllers![1] as FSViewController
        friendScoreVC.friendScores = friendScores
    }

    func getFriends(handler: () -> Void) {
        var uri = "http://mathisspeedy.herokuapp.com/friend_scores/" + user.objectID
        Alamofire.request(.GET, uri)
            .responseJSON { (request, response, data, error) in
                //println("request: \(request)")
                //println("response: \(response)")
                //println("data: \(data)")
                //println("error: \(error)")
                if error != nil || data == nil ||  data!.objectForKey("friends") == nil {
                    println(" errors found")
                } else {
                     //println(data!.objectForKey("friends"))
                    var arr = data!.objectForKey("friends") as [AnyObject]
                    for f in arr {
                        var highscore = self.computeHighScore(f.objectForKey("score") as [Int])
                        var firstName = f.objectForKey("firstName") as? String
                        var lastName = f.objectForKey("lastName") as? String
                        var fullName = firstName! + " " + lastName!
                        println(highscore)
                        
                        let tuple = (fullName, highscore)
                        self.friendScores.append(tuple)
                    }
                    
                    self.friendScores.sort(self.sortFriendScores)
                }
                handler()
        }
    }
    
    func sortFriendScores(a: (String, Int), b: (String, Int)) -> Bool{
        let (aName, aScore) = a
        let (bName, bScore) = b
        
        return aScore > bScore
    }
    
    func computeHighScore(score: [Int])->Int {
        var max = 0
        if score.count == 0 {
            return max
        } else {
            for s in score {
                if s > max {
                    max = s
                }
            }
        }
        return max
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }

}
