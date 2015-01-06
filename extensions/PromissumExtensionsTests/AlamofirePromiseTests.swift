//
//  AlamofirePromiseTests.swift
//  PromissumExtensionsTests
//
//  Created by Tom Lokhorst on 2015-01-06.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import UIKit
import XCTest
import Alamofire
import Promissum
import PromissumExtensions

class AlamofirePromiseTests: XCTestCase {

  func testAlamofire() {
    let expectation = expectationWithDescription("Request not completed")

    let url = "https://api.github.com/repos/tomlokhorst/Promissum"

    Alamofire.request(.GET, url).responseJSONPromise()
      .thenVoid { json in
        let name_ = json["name"] as? String
        if name_ == "Promissum" {
          expectation.fulfill()
        }
      }
      .catchVoid { e in
        println(e)
      }

    // Wait for 1 second for the download to be cancelled
    waitForExpectationsWithTimeout(5.0, handler: nil)
  }
}
