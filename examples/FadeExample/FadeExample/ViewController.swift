//
//  ViewController.swift
//  FadeExample
//
//  Created by Tom Lokhorst on 2015-01-23.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import UIKit

import Alamofire
import CoreDataKit
import Promissum

class ViewController: UIViewController {

  @IBOutlet weak var loadButton: UIButton!

  @IBOutlet weak var detailsView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!

  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var errorLabel: UILabel!


  override func viewDidLoad() {
    super.viewDidLoad()

    // Details and erros are initially invisible
    detailsView.alpha = 0
    errorView.alpha = 0

    // Give the button a border, so the fade shows up better
    loadButton.layer.borderColor = loadButton.tintColor!.CGColor
    loadButton.layer.borderWidth = 1.0;
    loadButton.layer.cornerRadius = 3;
  }

  @IBAction func buttonTouchUp(sender: UIButton) {
    let url = "https://api.github.com/repos/tomlokhorst/Promissum"

    // Start loading the JSON
    let jsonPromise = Alamofire.request(.GET, url).responseJSONPromise()

    // Fade out the "load" button
    let fadeoutPromise = UIView.animatePromise(duration: 0.5) {
      self.loadButton.alpha = 0
    }.void()

    // When both fade out and JSON loading complete, continue on
    whenBoth(jsonPromise, fadeoutPromise)
      .map { json, _ in parseJson(json) }
      .flatMap(storeInCoreData)
      .flatMap(delay(0.5))
      .then { project in
        self.nameLabel.text = project.name
        self.descriptionLabel.text = project.descr

        UIView.animatePromise(duration: 0.5) {
          self.detailsView.alpha = 1
        }
      }
      .catch { e in
        self.errorLabel.text = e.localizedDescription
        self.errorView.alpha = 1
      }
  }
}

func parseJson(json: AnyObject) -> (name: String, description: String) {

  let name = json["name"] as String
  let description = json["description"] as String

  return (name, description)
}

func storeInCoreData(result: (name: String, description: String)) -> Promise<Project> {

  var project: Project!

  return CoreDataKit.performBlockOnBackgroundContextPromise { context in
    project = context.create(Project.self).value()
    project.name = result.name
    project.descr = result.description

    return .SaveToPersistentStore
  }.flatMap { _ in
    CoreDataKit.backgroundContext.find(project).toPromise()
  }
}
