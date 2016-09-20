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
    loadButton.layer.borderColor = loadButton.tintColor!.cgColor
    loadButton.layer.borderWidth = 1.0;
    loadButton.layer.cornerRadius = 3;
  }

  @IBAction func buttonTouchUp(_ sender: UIButton) {
    let url = "https://api.github.com/repos/tomlokhorst/Promissum"

    // Start loading the JSON
    let jsonPromise = Alamofire.request(url)
      .responseJSONPromise()
      .mapError()

    // Fade out the "load" button
    let fadeoutPromise = UIView.animatePromise(withDuration: 0.5) {
        self.loadButton.alpha = 0
      }
      .mapVoid()
      .mapError()

    // When both fade out and JSON loading complete, continue on
    whenBoth(jsonPromise, fadeoutPromise)
      .map { response, _ in parse(json: response.result) }
      .flatMap(storeInCoreData)
      .delay(0.5)
      .then { project in
        self.nameLabel.text = project.name
        self.descriptionLabel.text = project.descr

        UIView.animate(withDuration: 0.5) {
          self.detailsView.alpha = 1
        }
      }
      .trap { error in
        self.errorLabel.text = "\(error)"
        self.errorView.alpha = 1
      }

  }
}

func parse(json: Any) -> (name: String, description: String) {

  let dict = json as AnyObject
  let name = dict["name"] as! String
  let description = dict["description"] as! String

  return (name, description)
}

func storeInCoreData(result: (name: String, description: String)) -> Promise<Project, Error> {

  var project: Project!

  return CDK.performOnBackgroundContextPromise { context in
      do {
        project = try context.create(Project.self)
        project.name = result.name
        project.descr = result.description

        return .saveToPersistentStore
      }
      catch {
        fatalError("Shouldn't happen")
      }
    }
    .map { _ -> Project in
      do {
        return try CDK.backgroundContext.find(Project.self, managedObjectID: project.objectID)
      }
      catch {
        fatalError("Shouldn't happen")
      }
    }
    .mapError()
}
