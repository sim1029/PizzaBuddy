//
//  CompleteDeliveryViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 1/15/21.
//

import UIKit
import RealmSwift

class CompleteDeliveryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let realm = try! Realm()
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delivery = Delivery()
    var shift = Shift()
    
    override func viewDidLoad() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        topLabel.text = delivery.address
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 40
        } else {
            return 100
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            if row == 0 {
                return "$0"
            }else {
                return "$\(row)"
            }
        } else {
            if row == 0 {
                return ".00"
            } else {
                return ".\(row)"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let existingAddress = realm.objects(Address.self).filter("address = '\(delivery.address)'").first {
            saveDelivery(existingAddress)
        }
        if segue.destination.superclass == MapViewController.self {
            let destinationVC = segue.destination as! MapViewController
            destinationVC.viewDidLoad()
        }
    }
    
    func saveDelivery(_ address: Address) {
        do {
            try realm.write{
                delivery.complete = true
                let tip = (Double(pickerView.selectedRow(inComponent: 0) * 100) + Double(pickerView.selectedRow(inComponent: 1))) / 100
                delivery.tip = tip
                delivery.deliveryTime += CFAbsoluteTimeGetCurrent() - delivery.timeCreated
                shift.tips += tip
            }
        } catch {
            print("Error saving folds \(error)")
        }
        
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
                if notes.text == "" {
                    delivery.notes = address.notes
                } else {
                    address.notes = notes.text!
                    delivery.notes = notes.text!
                }
            }
        } catch {
            print("\(error)")
        }
    }
    
}
