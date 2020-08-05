//
//  NewAddressViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/19/20.
//

import UIKit
import RealmSwift

class NewAddressViewController: UIViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var notesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(NewAddressViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewAddressViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.addressTextField.delegate = self
        self.notesTextField.delegate = self
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newDelivery = Delivery()
        newDelivery.address = addressTextField.text!
        newDelivery.notes = notesTextField.text!
        saveDelivery(delivery: newDelivery)
    }
    
    func saveDelivery(delivery: Delivery) {
        do {
            try realm.write{
                realm.add(delivery)
            }
        } catch {
            print("Error saving folds \(error)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
        self.view.frame.origin.y = popupView.frame.origin.y - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
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
