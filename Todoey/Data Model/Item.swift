//
//  Item.swift
//  Todoey
//
//  Created by Sean Anderson on 27/02/23.
//

import Foundation
import RealmSwift

class ItemRealm: Object {
    dynamic var name: String = ""
    dynamic var done: Bool = false
    
    var parentCategory = LinkingObjects(fromType: CategoryRealm.self, property: "items")
}
