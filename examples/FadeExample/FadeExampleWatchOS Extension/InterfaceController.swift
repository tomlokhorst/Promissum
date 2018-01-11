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

  @IBOutlet var label: WKInterfaceLabel!

  override func willActivate() {
    super.willActivate()

    label.setTextColor(UIColor.white)
    label.setText("...")
    
    let url = "https://api.github.com/repos/tomlokhorst/Promissum"
    
    // Start loading the JSON
    Alamofire.request(url)
      .responseJSONPromise()
      .map { self.parse($0.result) }
      .then { [weak label] p in
        label?.setTextColor(UIColor.white)
        label?.setText(p.description)
      }
      .trap { [weak label] error in
        label?.setTextColor(UIColor.red)
        label?.setText("\(error)")
      }
  }

  func parse(_ json: Any) -> (name: String, description: String) {

    let dict = json as! [String: Any]
    let name = dict["name"] as! String
    let description = dict["description"] as! String

    return (name, description)
  }
}

struct Project: Decodable {
  let description: String
}
