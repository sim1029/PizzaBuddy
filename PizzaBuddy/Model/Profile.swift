//
//  Profile.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 1/16/21.
//

import Foundation
import RealmSwift

class Profile: Object {
    @objc dynamic var baseFee = 0.0
    @objc dynamic var minimumWage = 0.0
}
