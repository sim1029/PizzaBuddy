//
//  ShiftViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 1/16/21.
//

import UIKit
import RealmSwift

class ShiftViewController: UIViewController {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var deliveriesLabel: UILabel!
    @IBOutlet weak var timeWorkedLabel: UILabel!
    @IBOutlet weak var avgTimeLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    let realm = try! Realm()
    
    var shift = Shift()
    
    override func viewDidLoad() {
        topLabel.text = shift.dateCreated
        let completedDeliveries = countCompletedDeliveries(shift.deliveries)
        if completedDeliveries != 1 {
            deliveriesLabel.text = "\(completedDeliveries) Deliveries"
        } else {
            deliveriesLabel.text = "\(completedDeliveries) Delivery"
        }
        formatTimeLabel(shift.timeWorked)
        let avgTime = shift.timeWorked / Double(completedDeliveries)
        formatAvgTime(avgTime)
        tipLabel.text = "\(formatMoneyLabel(shift.tips)) Tips"
        totalLabel.text = "\(formatMoneyLabel(shift.total)) Total"
    }
    
    func formatMoneyLabel(_ money: Double) -> String {
        var moneyString = "$"
        moneyString += String(format: "%.2f", money)
        return moneyString
    }
    
    func formatTimeLabel(_ timeWorked: Double) {
        
        let flooredCounter = Int(floor(timeWorked))
        
        let hour = flooredCounter / 3600
        var hourString = "\(hour)"
        if hour < 10 {
            hourString = "0\(hour)"
        }
        
        let minute = (flooredCounter % 3600) / 60
        var minuteString = "\(minute)"
        if minute < 10 {
            minuteString = "0\(minute)"
        }
        
        let second = (flooredCounter % 3600) % 60
        var secondString = "\(second)"
        if second < 10 {
            secondString = "0\(second)"
        }
        
        timeWorkedLabel.text = "\(hourString):\(minuteString):\(secondString) Worked"
    }
    
    func formatAvgTime(_ seconds: Double){
        
        let flooredCounter = Int(floor(seconds))
        
        let minute = (flooredCounter % 3600) / 60
        var minuteString = "\(minute)"
        if minute < 10 {
            minuteString = "0\(minute)"
        }
        
        let second = (flooredCounter % 3600) % 60
        var secondString = "\(second)"
        if second < 10 {
            secondString = "0\(second)"
        }
        
        avgTimeLabel.text = "\(minuteString):\(secondString) Avg"
        
    }
    
    func countCompletedDeliveries(_ deliveries: List<Delivery>) -> Int {
        var counter = 0
        for delivery in deliveries {
            if delivery.complete {
                counter += 1
            }
        }
        return counter
    }
}
