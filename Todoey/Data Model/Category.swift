//
//  Category.swift
//  Todoey
//
//  Created by Sean Anderson on 27/02/23.
//

import Foundation
import RealmSwift

class CategoryRealm: Object {
    dynamic var name: String = ""
    
    let items = List<ItemRealm>()
}
