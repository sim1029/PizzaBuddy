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
    @objc dynamic var timeWorked : Float64 = 0.0
    @objc dynamic var working = false
    @objc dynamic var lastSavedTime : Float64 = 0.0
    @objc dynamic var tips = 0.0
}
