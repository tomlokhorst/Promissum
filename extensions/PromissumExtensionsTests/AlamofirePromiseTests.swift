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
//import Promissum
import PromissumExtensions

class AlamofirePromiseTests: XCTestCase {

  func testAlamofire() {
    let expectation = expectationWithDescription("Request not completed")

    let url = "https://api.github.com/repos/tomlokhorst/Promissum"

    Alamofire.request(.GET, url).responseJSONPromise()
      .then { val in
        if let dict = val.value as? [String: AnyObject],
          let name = dict["name"] as? String
          where name == "Promissum" {
          expectation.fulfill()
        }
      }
      .trap { e in
        print(e)
      }

    // Wait for 1 second for the download to be cancelled
    waitForExpectationsWithTimeout(5.0, handler: nil)
  }
}
