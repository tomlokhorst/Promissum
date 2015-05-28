//
//  TinyNetworkingPromiseTests.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-09.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import UIKit
import XCTest
import Promissum
import PromissumExtensions

class TinyNetworkingPromiseTests: XCTestCase {

  func testTinyNetworking() {
    let expectation = expectationWithDescription("Request not completed")

    let baseURL = NSURL(string: "https://api.github.com")!
    let repoResource = Resource(
      path: "/repos/tomlokhorst/Promissum",
      method: .GET,
      requestBody: nil,
      headers: [:],
      parse: decodeJSON)

    apiRequestPromise({ _ in }, baseURL, repoResource)
      .then { json in
        let name_ = json["name"] as? String
        if name_ == "Promissum" {
          expectation.fulfill()
        }
      }
      .catch { e in
        println(e.reason)
      }

    // Wait for 1 second for the request to finish
    waitForExpectationsWithTimeout(5.0, handler: nil)
  }
}
