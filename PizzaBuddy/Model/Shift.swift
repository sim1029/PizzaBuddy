//
//  Shift.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import Foundation
import RealmSwift

class Shift: Object {
    let deliveries = List<Delivery>()
    @objc dynamic var timeWorked = 0
}
