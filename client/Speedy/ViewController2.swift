//
//  ViewController2.swift
//  Speedy
//
//  Created by John Chou on 1/23/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit

class ViewController2: UIViewController, UIPageViewControllerDataSource {
    var user : FBGraphUser!

    private let MAIN_SCREEN = "MainScreenPage"
    private let TABLE_SCREEN = "FriendsTable"
    // (jchou) setting this constant is so annoying... just leave it lol
    private let viewsToNav = ["MainScreenPage",
        "FriendsTable"];
    private var curIndexNav = 0
    private var pageViewController: UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("In View controller 2")
        createPageViewController()
        
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
                let castController = pageItemController as FriendsTableViewController
                castController.user = user
            }
        
//            pageItemController.itemIndex = itemIndex
//            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        
        return nil
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


