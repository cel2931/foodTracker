//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Celia on 18/04/2016.
//  Copyright © 2016 Fanigan. All rights reserved.
//

import UIKit

protocol MealViewControllerDelegate {
    func deleteSelectedMeal(selectedMeal :Meal)
}

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate = MealViewControllerDelegate?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MealViewController.dismissAddNewMealView), name:
            UIApplicationWillResignActiveNotification, object: nil)
    }

    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet var restAddress: UILabel!
  
    
    /*
     This value is either passed by 'MealTableViewController' in 'prepareForSegue(_:sender:)'
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    
    /*
     This value is either passed by 'MealTableViewController' in 'prepareForSegue(_:sender:)'
     or constructed as part of adding a new meal.
     */
    var restaurant: Restaurant?

    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let rating = ratingControl.rating
            let address = restAddress.text
            
            
            // Set the meal to be passed to MealTableViewController after the unwind segue.
            meal = Meal(name: name, photo: photo, rating: rating, address: address)
        }
    }
    
    @IBAction func unwindToMealDetail(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.sourceViewController as? MapViewController, restaurant = sourceViewController.restaurantAnotation {
            let selectedAddress = self.prettyPrint(restaurant)
            if !selectedAddress.isEmpty {
                restAddress.text = selectedAddress
            }
        }
    }
    
    func dismissAddNewMealView() {
        
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            self.dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMealName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    
    // MARK: - 3D touch Peeking/Popping actions
    
   override func previewActionItems() -> [UIPreviewActionItem] {
        
        return [UIPreviewAction(title: "Delete",
                                style: .Destructive,
                                handler:  {
            (action, viewController) in (viewController as? MealViewController)?.deleteMeal(self.meal!)
        })]
    }
    
    func deleteMeal(selectedMeal: Meal) {
        self.delegate?.deleteSelectedMeal(selectedMeal)
    }

    // MARK: Label Helper
    
    func prettyPrint(restaurant: Restaurant) -> String {
        
        var newAddress: String = ""
        if let street = restaurant.street {
            newAddress += street + ", "
        }
        
        if let zipCode = restaurant.zip {
            newAddress += zipCode + "\n"
            
        }
        if let city = restaurant.city {
            newAddress += city + ", "
            
        }
        if let country = restaurant.country {
            newAddress += country
            
        }
        return newAddress
    }
}

