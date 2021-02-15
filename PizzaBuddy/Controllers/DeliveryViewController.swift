//
//  DeliveryViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import UIKit
import RealmSwift

class DeliveryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var tipRating: UILabel!
    @IBOutlet weak var tip: UILabel!
    @IBOutlet weak var visits: UILabel!
    @IBOutlet weak var averageDeliveryTime: UILabel!
    @IBOutlet weak var notes: UILabel!
    
    let realm = try! Realm()
    
    var selectedDelivery : Delivery?
    var avgTips = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let delivery = selectedDelivery {
            loadDelivery(delivery)
        }
    }
    
    func loadDelivery(_ delivery: Delivery) {
        address?.text = delivery.address
        if let existingAddress = realm.objects(Address.self).filter("address = '\(delivery.address)'").first {
            calculateDeliveryTime(existingAddress)
            if existingAddress.visits != 1{
                visits?.text = String(existingAddress.visits) + " Visits"
            } else {
                visits?.text = String(existingAddress.visits) + " Visit"
            }
            notes?.text = delivery.notes
            tip?.text = "\(formatMoneyLabel(delivery.tip)) Tip"
            if existingAddress.visits > 0 {
                formatAvgTime(existingAddress.avgDeliveryTime)
                getTipRating(existingAddress.avgTips)
            } else {
                tipRating.text = "???"
            }
        }
    }
    
    func calculateDeliveryTime(_ address: Address) {
        var completed = 0
        var deliveryTime = 0.0
        var totalTips = 0.0
        for delivery in address.deliveries {
            if delivery.complete {
                completed += 1
                deliveryTime += delivery.deliveryTime
                totalTips += delivery.tip
            }
        }
        if completed > 0 {
            deliveryTime = deliveryTime / Double(completed)
            totalTips = totalTips / Double(completed)
        }
        do{
            try realm.write {
                address.avgDeliveryTime = deliveryTime
                address.visits = completed
                address.avgTips = totalTips
            }
        } catch {
            print("\(error)")
        }
    }
    
    func formatMoneyLabel(_ money: Double) -> String {
        var moneyString = "$"
        moneyString += String(format: "%.2f", money)
        return moneyString
    }
    
    func getTipRating(_ avgTips: Double) {
        if avgTips > 15.0 {
            tipRating.text = "$$$$$"
        } else if avgTips > 10.0 {
            tipRating.text = "$$$$"
        } else if avgTips > 5.0 {
            tipRating.text = "$$$"
        } else if avgTips > 2.5 {
            tipRating.text = "$$"
        } else {
            tipRating.text = "$"
        }
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
        
        averageDeliveryTime.text = "\(minuteString):\(secondString) Avg"
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
