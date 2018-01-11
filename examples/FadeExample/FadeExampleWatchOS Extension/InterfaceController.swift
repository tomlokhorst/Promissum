//
//  InterfaceController.swift
//  FadeExampleWatchOS Extension
//
//  Created by Tomas Harkema on 11-01-18.
//  Copyright © 2018 Tom Lokhorst. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import Promissum

class InterfaceController: WKInterfaceController {
  override func willActivate() {
    super.willActivate()
    
    let url = "https://api.github.com/repos/tomlokhorst/Promissum"
    
    // Start loading the JSON
    Alamofire.request(url)
      .responseJSONPromise()
      .then {
        print($0)
      }
      .trap {
        print($0)
      }
  }
}
