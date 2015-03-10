//
//  FSViewController.swift
//  Speedy
//
//  Created by John Chou on 2/19/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit

class FSViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var friendScores: [(String, Int)]!
    var user : FBGraphUser!
    
    let evenCellColor = UIColor(red: CGFloat(43/255.0), green: CGFloat(176/255.0), blue: CGFloat(237/255.0), alpha: 1.0)
    let oddCellColor = UIColor(red: CGFloat(14/255.0), green: CGFloat(125/255.0), blue: CGFloat(206/255.0), alpha: 1.0)

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.friendScores == nil {
            return 0
        }
        return self.friendScores!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.backgroundColor = UIColor.clearColor()
        let cell = self.tableView.dequeueReusableCellWithIdentifier("PlayerCell") as PlayerCell
        
        let (name, score) = friendScores![indexPath.row]
        
        cell.nameLabel.text = name
        cell.nameLabel.textColor = UIColor.whiteColor()
        cell.scoreLabel.text = String(score)
        cell.scoreLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = indexPath.row % 2 == 0 ? evenCellColor : oddCellColor
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func convertToGrayScale(color: UIColor) -> UIColor{
        let colorComponents = CGColorGetComponents(color.CGColor)
        
        let red = colorComponents[0] * 0.2126
        let green = colorComponents[1] * 0.7152
        let blue = colorComponents[2] * 0.0722
        let alpha = colorComponents[3]
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}
