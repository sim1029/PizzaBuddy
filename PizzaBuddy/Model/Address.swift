//
//  File.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 2/14/21.
//

import Foundation
import RealmSwift

class Address: Object {
    let deliveries = List<Delivery>()
    @objc dynamic var visits = 0
    @objc dynamic var address = ""
    @objc dynamic var avgDeliveryTime = 0.0
    @objc dynamic var notes = ""
    @objc dynamic var avgTips = 0.0
}
