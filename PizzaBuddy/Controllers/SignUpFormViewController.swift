//
//  SignUpFormViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/14/20.
//

import UIKit
import FirebaseAuth

class SignUpFormViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        infoLabel.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailInputField.delegate = self
        self.passwordInputField.delegate = self
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        if let password = passwordInputField.text {
            if(isValidEmail(email: emailInputField.text) && password.count > 4){
                Auth.auth().createUser(withEmail: emailInputField.text!, password: password) { (authResult, error) in
                    if(error == nil){
                        self.performSegue(withIdentifier: "signUpSegue", sender: self)
                    } else {
                        self.infoLabel.text = "Error! Please try again"
                    }
                }
            }
        }
    }
    
    
    // validate an email for the right format
    func isValidEmail(email:String?) -> Bool {
        
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
//    // validate Password FormatSwift
//    func isValidPassword(testStr:String?) -> Bool {
//        guard testStr != nil else { return false }
//
//        // at least one uppercase,
//        // at least one digit
//        // at least one lowercase
//        // 8 characters total
//        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
//        return passwordTest.evaluate(with: testStr)
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
