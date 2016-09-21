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
    enum FTShortcutIconType: Int {
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

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            performShortcutDelegate = false
        }
        return performShortcutDelegate
    }

    func applicationDidBecomeActive(application: UIApplication) {
        guard let shortcut = shortcutItem else { return }
        print("- Shortcut property has been set")
        handleShortcut(shortcut)
        self.shortcutItem = nil
    }
    
}

// MARK: - SHORCUTS

extension AppDelegate {
    
    func application(application: UIApplication, performActionForShortcutItem
        shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
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

