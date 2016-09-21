//
//  AppDelegate.swift
//  FoodTracker
//
//  Created by Celia on 18/04/2016.
//  Copyright © 2016 Fanigan. All rights reserved.
//

import UIKit

let myShortcutNotificationKey = "com.foodTracker.shortcutNotificationKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    
    enum FTShortcutIconType : Int {
        case Add = 1, List, FirstMealDetails
        func description() -> String {
            switch self {
            case .Add:
                return "appshortcut.new-meal"
            case .List:
                return "appshortcut.meal-list"
            case .FirstMealDetails:
                return "appshortcut.first-meal-details"
            }
        }
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        var performShortcutDelegate = true
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            performShortcutDelegate = false
        }
        
        return performShortcutDelegate
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let shortcut = shortcutItem else { return }
        print("- Shortcut property has been set")
        
        handleShortcut(shortcut)
        self.shortcutItem = nil
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: SHORCUTS
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        print("Application performActionForShortcutItem")
        completionHandler(handleShortcut(shortcutItem))
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        let rootViewController = UIApplication.sharedApplication().windows[0].rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = UIViewController()
        var foundedVC = false
        let onTop = rootViewController.topViewController is MealTableViewController
        
        switch shortcutItem.type {
        case FTShortcutIconType.Add.description():
            
            if onTop {
                vc = rootViewController.topViewController!
                foundedVC = true
            } else {
                for aViewController in rootViewController.viewControllers {
                    if aViewController is MealTableViewController {
                        vc = aViewController
                        foundedVC = true
                        break
                    }
                }
                if !(vc is MealTableViewController) {
                    vc = storyboard.instantiateViewControllerWithIdentifier("NavigationTableMealViewController") as! UINavigationController
                }
            }
            (vc as! MealTableViewController).shortcutToAddition = true
            
        case FTShortcutIconType.List.description():
            
            if onTop {
                vc = rootViewController.topViewController!
                foundedVC = true
            } else {
                for aViewController in rootViewController.viewControllers {
                    if aViewController is MealTableViewController {
                        vc = aViewController
                        foundedVC = true
                        break
                    }
                }
                if !(vc is MealTableViewController) {
                    vc = storyboard.instantiateInitialViewController()!
                }
            }
            
        case FTShortcutIconType.FirstMealDetails.description():
            
            if onTop {
                vc = rootViewController.topViewController!
                foundedVC = true
            } else {
                for aViewController in rootViewController.viewControllers {
                    if aViewController is MealTableViewController {
                        vc = aViewController
                        foundedVC = true
                        break
                    }
                }
                if !(vc is MealTableViewController) {
                    vc = storyboard.instantiateViewControllerWithIdentifier("NavigationTableMealViewController") as! UINavigationController
                }
            }
            (vc as! MealTableViewController).shortcutToFirstMeal = true
        default:
            print("Shortcut without action")
        }
        
        // Display the selected view controller
        if (foundedVC && !onTop) {
            // VC already on stack but not on top
            rootViewController.popToViewController(vc, animated: true)
            
        } else if !foundedVC {
            // VC NOT on stack >> use navigationVC
            rootViewController.pushViewController(vc, animated: true)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(myShortcutNotificationKey, object: self)
        return foundedVC
    }
    
}

