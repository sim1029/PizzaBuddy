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
    @objc dynamic var deliveryTime = 0
    @objc dynamic var visits = 0
    @objc dynamic var notes = ""
}
