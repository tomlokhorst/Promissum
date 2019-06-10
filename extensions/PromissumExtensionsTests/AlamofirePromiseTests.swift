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
import PromissumAlamofire

class AlamofirePromiseTests: XCTestCase {

  func testAlamofire() {
    let exp = expectation(description: "Request not completed")

    let url = "https://api.github.com/repos/tomlokhorst/Promissum"

    Alamofire.request(url)
      .responseJSONPromise()
      .then { response in
        if let dict = response.result as? [String: AnyObject],
          let name = dict["name"] as? String,
          name == "Promissum"
        {
          exp.fulfill()
        }
      }
      .trap { e in
        print(e)
      }

    // Wait for 1 second for the download to be cancelled
    waitForExpectations(timeout: 5.0, handler: nil)
  }
}
