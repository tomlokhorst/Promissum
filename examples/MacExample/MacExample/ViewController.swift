//
//  ViewController.swift
//  MacExample
//
//  Created by Tom Lokhorst on 2015-03-01.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  @IBOutlet weak var loadButton: NSButton!

  @IBOutlet weak var detailsView: NSView!
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var descriptionField: NSTextField!

  @IBOutlet weak var errorField: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}

