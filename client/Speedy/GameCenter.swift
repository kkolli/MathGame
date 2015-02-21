//
//  GameCenter.swift
//  Speedy
//
//  Created by Krishna Kolli on 2/12/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation
import GameKit

protocol delegateGameCenter {
    //  var delegateViewController: UIViewController { get set }
}
/**
GameCenter iOS
*/
class GameCenter: NSObject, GKGameCenterControllerDelegate {
    
    /// The local player object.
    let gameCenterPlayer = GKLocalPlayer.localPlayer()
    /// player can use GameCenter
    var canUseGameCenter:Bool = false {
        didSet {
            /* load prev. achievments form Game Center */
            if canUseGameCenter == true { gameCenterLoadAchievements() }
        }}
    /// Achievements of player
    var gameCenterAchievements=[String:GKAchievement]()
    /// ViewController MainView
    var vc: UIViewController
    
    /**
    Constructor
    */
    init(rootViewController viewC: UIViewController) {
        self.isOpen = true
        self.vc = viewC
        super.init()
        loginToGameCenter()
    }
    var isOpen = false
    /**
    Login to GameCenter
    */
    func loginToGameCenter() {
        self.gameCenterPlayer.authenticateHandler = {(var gameCenterVC:UIViewController!, var gameCenterError:NSError!) -> Void in
            
            if gameCenterVC != nil {
                
                self.vc.presentViewController(gameCenterVC, animated: true, completion: { () -> Void in
                    
                })
                
            } else if self.gameCenterPlayer.authenticated == true {
                self.canUseGameCenter = true
            } else  {
                self.canUseGameCenter = false
            }
            
            if gameCenterError != nil {
                println("Game Center error: \(gameCenterError)")
            }
            self.isOpen = false
        }
    }
    /**
    Dismiss Game Center when player open
    :param: GKGameCenterViewController
    
    Override of GKGameCenterControllerDelegate
    */
    internal func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    Load achievement in cache
    */
    private func gameCenterLoadAchievements(){
        if canUseGameCenter == true {
            /* load all prev. achievements for GameCenter for the user to progress can be added */
            var allAchievements=[GKAchievement]()
            
            GKAchievement.loadAchievementsWithCompletionHandler({ (allAchievements, error:NSError!) -> Void in
                if error != nil{
                    println("Game Center: could not load achievements, error: \(error)")
                } else {
                    for anAchievement in allAchievements  {
                        if let oneAchievement = anAchievement as? GKAchievement {
                            self.gameCenterAchievements[oneAchievement.identifier] = oneAchievement
                        }
                    }
                }
            })
        }
    }
    /**
    If achievement is Finished
    :param: achievementIdentifier
    */
    func isAchievementFinished(achievementIdentifier uAchievementId:String) -> Bool{
        if canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenterAchievements[uAchievementId]
            if let achievement = lookupAchievement {
                if achievement.percentComplete == 100 {
                    return true
                }
            } else {
                gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                return isAchievementFinished(achievementIdentifier: uAchievementId)
            }
        }
        return false
    }
    /**
    Add progress to an achievement
    
    :param: Progress achievement Double (ex: 10% = 10.00)
    :param: ID Achievement
    */
    func addProgressToAnAchievement(progress uProgress:Double,achievementIdentifier uAchievementId:String) {
        if canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenterAchievements[uAchievementId]
            
            if let achievement = lookupAchievement {
                if achievement.percentComplete != 100 {
                    achievement.percentComplete = uProgress
                    
                    if uProgress == 100.0  {
                        /* show banner only if achievement is fully granted (progress is 100%) */
                        achievement.showsCompletionBanner=true
                    }
                    
                    /* try to report the progress to the Game Center */
                    GKAchievement.reportAchievements([achievement], withCompletionHandler:  {(var error:NSError!) -> Void in
                        if error != nil {
                            println("Couldn't save achievement (\(uAchievementId)) progress to \(uProgress) %")
                        }
                    })
                }
                /* Is Finish */
            } else {
                /* never added  progress for this achievement, create achievement now, recall to add progress */
                println("No achievement with ID (\(uAchievementId)) was found, no progress for this one was recoreded yet. Create achievement now.")
                gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                /* recursive recall this func now that the achievement exist */
                addProgressToAnAchievement(progress: uProgress, achievementIdentifier: uAchievementId)
            }
        }
    }
    /**
    Reports a given score to Game Center
    
    :param: the Score
    :param: leaderboard identifier
    */
    func reportScore(score uScore: Int,leaderboardIdentifier uleaderboardIdentifier: String ) {
        if canUseGameCenter == true {
            var scoreReporter = GKScore(leaderboardIdentifier: uleaderboardIdentifier)
            scoreReporter.value = Int64(uScore)
            var scoreArray: [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, {(error : NSError!) -> Void in
                if error != nil {
                    NSLog(error.localizedDescription)
                }
            })
        }
    }
    /**
    Remove One Achievements
    
    :param: ID Achievement
    */
    func resetAchievements(achievementIdentifier uAchievementId:String) {
        if canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenterAchievements[uAchievementId]
            
            if let achievement = lookupAchievement {
                GKAchievement.resetAchievementsWithCompletionHandler({ (var error:NSError!) -> Void in
                    if error != nil {
                        println("Couldn't Reset achievement (\(uAchievementId))")
                    } else {
                        println("Reset achievement (\(uAchievementId))")
                    }
                })
                
            } else {
                println("No achievement with ID (\(uAchievementId)) was found, no progress for this one was recoreded yet. Create achievement now.")
                gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                /* recursive recall this func now that the achievement exist */
                self.resetAchievements(achievementIdentifier: uAchievementId)
            }
        }
    }
    /**
    Remove All Achievements
    */
    func resetAllAchievements() {
        if canUseGameCenter == true {
            
            for lookupAchievement in gameCenterAchievements {
                var achievementID = lookupAchievement.0
                var lookupAchievement:GKAchievement? =  lookupAchievement.1
                
                if let achievement = lookupAchievement {
                    GKAchievement.resetAchievementsWithCompletionHandler({ (var error:NSError!) -> Void in
                        if error != nil {
                            println("Couldn't Reset achievement (\(achievementID))")
                        } else {
                            println("Reset achievement (\(achievementID))")
                        }
                    })
                    
                } else {
                    println("No achievement with ID (\(achievementID)) was found, no progress for this one was recoreded yet. Create achievement now.")
                    gameCenterAchievements[achievementID] = GKAchievement(identifier: achievementID)
                    /* recursive recall this func now that the achievement exist */
                    self.resetAchievements(achievementIdentifier: achievementID)
                }
            }
        }
    }
    /**
    Show Game Center Player
    */
    func showGameCenter() {
        if canUseGameCenter == true {
            var gc = GKGameCenterViewController()
            gc.gameCenterDelegate = self
            self.vc.presentViewController(gc, animated: true, completion: nil)
        }
    }
}
