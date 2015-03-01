//
//  ViewController2.swift
//  Speedy
//
//  Created by John Chou on 1/23/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import Alamofire

class PageViewController: UIViewController, UIPageViewControllerDataSource {
    var user : FBGraphUser!
    var friendScoreMap: [String]!

    private let MAIN_SCREEN = "MainScreenPage"
    private let TABLE_SCREEN = "FriendScores"
    // (jchou) setting this constant is so annoying... just leave it lol
    private let viewsToNav = ["MainScreenPage",
        "FriendScores"];
    private var curIndexNav = 0
    private var pageViewController: UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendScoreMap = []
        println("In View controller 2")
        // should prevent getFriends from redundant calls
        getFriends(createPageViewController)
//        createPageViewController()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
        pageController.dataSource = self
        
//        if contentImages.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
//        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        println("PAGE VIEW BEFORE")
        /*let itemController = viewController as PageItemController
        
        if itemController.itemIndex > 0 {*/
        curIndexNav = (curIndexNav + 1) % viewsToNav.count
            return getItemController(curIndexNav)
//        }
        
//        return nil
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        println("PAGE VIEW AFTER")
        
        /*let itemController = viewController as PageItemController
        
        if itemController.itemIndex > 0 {*/
        curIndexNav = (curIndexNav + 1) % viewsToNav.count
        return getItemController(curIndexNav)
        //        }
        
//        return nil
    }
    private func getItemController(itemIndex: Int) -> UIViewController? {
        
//        if itemIndex < contentImages.count {
        
        if itemIndex < viewsToNav.count {
            println("navigating to : " + viewsToNav[itemIndex])
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier(viewsToNav[itemIndex]) as UIViewController
            if viewsToNav[itemIndex] == MAIN_SCREEN {
                let castController = pageItemController as IntroViewController
                castController.user = user
            } else if viewsToNav[itemIndex] == TABLE_SCREEN {
                let castController = pageItemController as FSViewController
                castController.friendScores = friendScoreMap
            }
        
//            pageItemController.itemIndex = itemIndex
//            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    func getFriends(handler: () -> Void) {
        
        var uri = "http://mathisspeedy.herokuapp.com/friend_scores/" + user.objectID
        Alamofire.request(.GET, uri)
            .responseJSON { (request, response, data, error) in
                println("request: \(request)")
                println("response: \(response)")
                println("data: \(data)")
                println("error: \(error)")
                if error != nil || data == nil ||  data!.objectForKey("friends") == nil {
                    println(" errors found")
                   
                } else {
                     println(data!.objectForKey("friends"))
                    var arr = data!.objectForKey("friends") as [AnyObject]
                    for f in arr {
                        var highscore = self.computeHighScore(f.objectForKey("score") as [Int])
                        var str = f.objectForKey("firstName") as? String
                        var str2 = f.objectForKey("lastName") as? String
                        var finalString = str! + " " + str2! + " : " + String(highscore)
//                        println("final string: " + finalString)
                        self.friendScoreMap.append( finalString)
                    }
                }
                handler()
                
        }
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


