//
//  ProfileViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import UIKit
import FirebaseAuth
import RealmSwift

class ProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var baseFeeField: UITextField!
    @IBOutlet weak var minimumWageField: UITextField!
    
    let realm = try! Realm()
    
    var profiles: Results<Profile>?
    var profile = Profile()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profiles = realm.objects(Profile.self)
        profile = profiles?.first ?? Profile()
        print(profile.baseFee)
        print(profile.minimumWage)
        baseFeeField.delegate = self
        minimumWageField.delegate = self
        minimumWageField.tag = 1
        minimumWageField.text = formatMoneyLabel(profile.minimumWage)
        baseFeeField.text = formatMoneyLabel(profile.baseFee)
        // Do any additional setup after loading the view.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            do {
                try realm.write {
                    profile.baseFee = Double(textField.text!) ?? 0.0
                }
            } catch {
                print("\(error)")
            }
        } else {
            do {
                try realm.write {
                    profile.minimumWage = Double(textField.text!) ?? 0.0
                }
            } catch {
                print("\(error)")
            }
        }
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            performSegue(withIdentifier: "signOutSegue", sender: self)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    func formatMoneyLabel(_ money: Double) -> String {
        var moneyString = "$"
        moneyString += String(format: "%.2f", money)
        return moneyString
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
