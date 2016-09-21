//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Celia on 18/04/2016.
//  Copyright © 2016 Fanigan. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController, UIViewControllerPreviewingDelegate, MealViewControllerDelegate {
    
    // MARK: Properties
    
    var meals = [Meal]()
    var shortcutToAddition = false
    var shortcutToFirstMeal = false
    @IBOutlet weak var addMealBarButton: UIBarButtonItem!
    @IBOutlet var mealsTable: UITableView!
    // MARK: Live cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            meals += savedMeals
        } else {
            // Load the sample data.
            loadSampleMeals()
        }
        
        updateShortcutItems()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MealTableViewController.runShortcuts), name:
            myShortcutNotificationKey, object: nil)
        
        if( traitCollection.forceTouchCapability == .Available){
            registerForPreviewingWithDelegate(self, sourceView: view)
            
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateShortcutItems() {
        if !meals.isEmpty {
            let shortcut = UIApplicationShortcutItem(type: "appshortcut.first-meal-details",
                                                     localizedTitle: meals[0].name,
                                                     localizedSubtitle: "Dynamic Action",
                                                     icon: nil,
                                                     userInfo: nil)
            UIApplication.sharedApplication().shortcutItems = [shortcut]
        } else {
            UIApplication.sharedApplication().shortcutItems = []
        }
        
    }
    
    func runShortcuts() {
        
        if shortcutToFirstMeal {
            if !meals.isEmpty {
                let senderCell = mealsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                performSegueWithIdentifier("ShowDetail", sender: senderCell)
                shortcutToFirstMeal = false
            }
        } else if shortcutToAddition {
            performSegueWithIdentifier("AddItem", sender: addMealBarButton)
            shortcutToAddition = false
        }
    }

    func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")!
        let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4, address: nil)!
        
        let photo2 = UIImage(named: "meal2")!
        let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5, address: nil)!
        
        let photo3 = UIImage(named: "meal3")!
        let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3, address: "West Cromwell Road, SW59QJ, London")!
        
        meals += [meal1, meal2, meal3]
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MealTableViewCell

        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            meals.removeAtIndex(indexPath.row)
            saveMeals()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // MARK: - Navigation
     
     @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.sourceViewController as? MealViewController, meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                meals[selectedIndexPath.row] = meal
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)

            } else {
                // Add a new meal.
                let newIndexPath = NSIndexPath(forRow: meals.count, inSection: 0)
                meals.append(meal)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            
            // Save the meals.
            saveMeals()
        }
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowDetail" {
            let mealDetailViewController = segue.destinationViewController as! MealViewController
            // Get the cell that generated this segue.
            if let selectedMealCell = sender as? MealTableViewCell {
            
                let indexPath = tableView.indexPathForCell(selectedMealCell)!
                let selectedMeal = meals[indexPath.row]
                mealDetailViewController.meal = selectedMeal
            }
            
        } else if segue.identifier == "AddItem" {
            print("Adding new meal.")
        }
    }
    

    // MARK: NSCoding
    
    func saveMeals() {
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.meals, toFile: Meal.ArchiveURL.path!)
            self.updateShortcutItems()
            if !isSuccessfulSave {
                print("Failed to save meals...")
            }
        })
    }

    func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Meal.ArchiveURL.path!) as? [Meal]
    }
    
    // MARK: - 3D touch Peeking/Popping delegate
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = mealsTable?.indexPathForRowAtPoint(location) else { return nil }
        guard let cell = mealsTable?.cellForRowAtIndexPath(indexPath) else { return nil }
        
        guard let mealDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("MealViewController") as? MealViewController else { return nil }
        
        let selectedMeal = meals[indexPath.row]
        mealDetailViewController.meal = selectedMeal
        mealDetailViewController.delegate = self
        mealDetailViewController.preferredContentSize = CGSize(width: 0.0, height: 475)
        previewingContext.sourceRect = cell.frame
        
        
        return mealDetailViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        showViewController(viewControllerToCommit, sender: self)
        
    }
    
    // MARK: - MealViewControllerDelegate
    
    func deleteSelectedMeal(selectedMeal: Meal) {
        
        let mealIndex = meals.indexOf(selectedMeal)!
        meals.removeAtIndex(mealIndex)
        
        
        let mealIndexPath = NSIndexPath(forRow: mealIndex, inSection: 0)
        tableView.deleteRowsAtIndexPaths([mealIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        saveMeals()
        return
    }
    
}
