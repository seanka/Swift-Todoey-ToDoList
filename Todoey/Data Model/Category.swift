//
//  Category.swift
//  Todoey
//
//  Created by Sean Anderson on 27/02/23.
//

import Foundation
import RealmSwift

class CategoryRealm: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    let itemsRealm = List<ItemRealm>()
}
