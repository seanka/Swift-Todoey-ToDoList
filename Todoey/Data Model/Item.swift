//
//  Item.swift
//  Todoey
//
//  Created by Sean Anderson on 27/02/23.
//

import Foundation
import RealmSwift

class ItemRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    let parentCategoryRealm = LinkingObjects(fromType: CategoryRealm.self, property: "itemsRealm")
}
