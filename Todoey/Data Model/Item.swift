//
//  Item.swift
//  Todoey
//
//  Created by Sean Anderson on 10/02/23.
//

import Foundation

struct Item: Encodable {
    var title: String = ""
    var done: Bool = false
}
