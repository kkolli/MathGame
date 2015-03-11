//
//  SummaryViewController.swift
//  Speedy
//
//  Created by John Chou on 3/5/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import Alamofire

class SummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var score: Int!
    var operatorsUsed: [Operator]!
    var numTargetNumbersMatched: Int!
    var user : FBGraphUser!
    var appDelegate:AppDelegate!
    var keys: [String] = []
    var vals: [Int] = []
    
    let evenCellColor = UIColor(red: CGFloat(43/255.0), green: CGFloat(176/255.0), blue: CGFloat(237/255.0), alpha: 1.0)
    let oddCellColor = UIColor(red: CGFloat(14/255.0), green: CGFloat(125/255.0), blue: CGFloat(206/255.0), alpha: 1.0)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.user = appDelegate.user
        
        addScore()
        addTargetNumberCount()
        countOperators()
        postScore(String(score))
    }

    @IBAction func ToMainMenu(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return keys.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.backgroundColor = UIColor.clearColor()
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SummaryCell") as SummaryCell
        
        let key = keys[indexPath.row]
        let value = vals[indexPath.row]
        
        println(value)
        cell.keyLabel.text = key
        cell.keyLabel.textColor = UIColor.whiteColor()
        cell.valueLabel.text = String(value)
        cell.valueLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = indexPath.row % 2 == 0 ? evenCellColor : oddCellColor
        
        return cell
    }
    
    func addScore(){
        keys.append("Score")
        vals.append(score)
    }
    
    func addTargetNumberCount(){
        keys.append("Target Number count")
        vals.append(numTargetNumbersMatched)
    }
    
    func countOperators(){
        let operators = ["Addition count",
                        "Subtraction count",
                        "Multiplication count",
                        "Division count"]
        var counts = [Int](count: 4, repeatedValue: 0)
        
        for oper in operatorsUsed {
            switch oper {
            case .PLUS: counts[0]++
            case .MINUS: counts[1]++
            case .MULTIPLY: counts[2]++
            case .DIVIDE: counts[3]++
            default: break
            }
        }

        keys += operators
        vals += counts
    }
    
    func postScore(score:String){
        var uri = "http://mathisspeedy.herokuapp.com/HighScores/" + user.objectID
        let parameters = [
            "score": score
        ]
        Alamofire.request(.POST, uri, parameters: parameters, encoding: .JSON)
    }
}
