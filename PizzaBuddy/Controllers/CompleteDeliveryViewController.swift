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
        saveDelivery()
    }
    
    func saveDelivery() {
        do {
            try realm.write{
                delivery.complete = true
                print(pickerView.selectedRow(inComponent: 0))
                print(pickerView.selectedRow(inComponent: 1))
                delivery.tip = (Double(pickerView.selectedRow(inComponent: 0) * 100) + Double(pickerView.selectedRow(inComponent: 1))) / 100
                delivery.visits += 1
                delivery.notes = notes.text ?? ""
            }
        } catch {
            print("Error saving folds \(error)")
        }
    }
    
}
