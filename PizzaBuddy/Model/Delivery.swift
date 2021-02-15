//
//  Delivery.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import Foundation
import RealmSwift

class Delivery: Object {
    @objc dynamic var address = ""
    @objc dynamic var tip = 0.0
    @objc dynamic var deliveryTime = 0.0
    @objc dynamic var timeCreated = 0.0
    @objc dynamic var notes = ""
    @objc dynamic var complete = false
}
