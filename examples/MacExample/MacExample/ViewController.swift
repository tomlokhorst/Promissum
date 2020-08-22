//
//  ViewController.swift
//  MacExample
//
//  Created by Tom Lokhorst on 2015-03-01.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Cocoa
import Alamofire
import Promissum

class ViewController: NSViewController {

  @IBOutlet weak var loadButton: NSButton!

  @IBOutlet weak var detailsView: NSView!
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var descriptionField: NSTextField!

  @IBOutlet weak var errorField: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Details and erros are initially invisible
    detailsView.alphaValue = 0
    errorField.alphaValue = 0
  }

  @IBAction func buttonAction(_ sender: NSButton) {
    let url = "https://api.github.com/repos/tomlokhorst/Promissum"

    // Start loading the JSON
    let projectResponsePromise = AF.request(url)
      .responseDecodablePromise(of: Project.self)
      .mapError()

    // Fade out the "load" button
    self.loadButton.isEnabled = false
    let fadeoutPromise = NSAnimationContext.runAnimationGroupPromise { context in
        context.duration = 0.5
        self.loadButton.animator().alphaValue = 0
      }
      .mapError()

    // When both fade out and JSON loading complete, continue on
    whenBoth(projectResponsePromise, fadeoutPromise)
      .map { response, _ in response.result }
      .delay(0.5)
      .then { project in
        self.nameField.stringValue = project.name
        self.descriptionField.stringValue = project.description

        _ = NSAnimationContext.runAnimationGroupPromise { context in
          context.duration = 0.5
          self.detailsView.animator().alphaValue = 1
        }
      }
      .trap { error in
        self.errorField.stringValue = "\(error)"
        self.errorField.alphaValue = 1
      }
  }
}

struct Project: Decodable {
  let name: String
  let description: String
}
