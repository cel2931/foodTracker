//
//  MapViewController.swift
//  FoodTracker
//
//  Created by Celia on 19/05/2016.
//  Copyright © 2016 Fanigan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: Properties
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2000
    var restaurantAnotation: Restaurant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        saveButton.enabled = false

//        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MapViewController.cancel), name:
//            UIApplicationWillResignActiveNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    

    // MARK: - Navigation
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let initialLocation:CLLocationCoordinate2D = manager.location!.coordinate
        centerMapOnLocation(initialLocation)
        mapView.showsUserLocation = true
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
//    optional func mapView(mapView: MKMapView,
//                   viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        
//    }
    
    
    // MARK: LocationManager helpers
 
    @IBAction func selectRestaurantWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        
        if !mapView.annotations.isEmpty {
            for anotation in mapView.annotations {
                mapView.removeAnnotation(anotation)
            }
        }

        let touchLocation = sender.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        
        restaurantAnotation =  Restaurant(coordinate: locationCoordinate, title:"The RTE" ,subtitle:"American")
        calculateAddressForRestaurant(restaurantAnotation!)
        mapView.addAnnotation(restaurantAnotation!)
        saveButton.enabled = true
    }
    
    
    func calculateAddressForRestaurant(selectedRestaurant: Restaurant) {
        let geoCoder = CLGeocoder()
        let touchCoordinate = selectedRestaurant.coordinate
        
        let location = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? String {
                selectedRestaurant.street = street
            }
            if let city = placeMark.addressDictionary!["City"] as? String {
                selectedRestaurant.city = city
            }
            if let zip = placeMark.addressDictionary!["ZIP"] as? String {
                selectedRestaurant.zip = zip
            }
            if let country = placeMark.addressDictionary!["Country"] as? String {
                selectedRestaurant.country = country
            }
            
        })
    }

}
