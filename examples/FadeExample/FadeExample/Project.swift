//
//  Project.swift
//  FadeExample
//
//  Created by Tom Lokhorst on 2015-01-25.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit

class Project: NSManagedObject, NamedManagedObject {

  class var entityName: String { return "Project" }

  @NSManaged var name: String
  @NSManaged var descr: String
}
