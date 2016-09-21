//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by Celia on 18/04/2016.
//  Copyright © 2016 Fanigan. All rights reserved.
//

import XCTest
@testable import FoodTracker

class FoodTrackerTests: XCTestCase {

    // MARK: FoodTracker Tests
    
    // Tests to confirm that the Meal initializer returns when no name or a negative rating is provided.
    func testMealInitialization() {
        
        // Success case.
        let potentialItem = Meal(name: "Newest meal", photo: nil, rating: 5, address: nil)
        XCTAssertNotNil(potentialItem)
        
        // Failure cases.
        let noName = Meal(name: "", photo: nil, rating: 0, address: nil)
        XCTAssertNil(noName, "Empty name is invalid")
        
        let badRating = Meal(name: "Really bad rating", photo: nil, rating: -1, address: nil)
        XCTAssertNil(badRating, "Negative ratings are invalid, be positive")
        
    }
}
