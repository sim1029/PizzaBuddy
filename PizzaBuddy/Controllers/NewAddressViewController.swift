//
//  NewAddressViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/19/20.
//

import UIKit
import RealmSwift
import MapKit
import CoreLocation
import CoreFoundation

class NewAddressViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate, UISearchBarDelegate {
    
    let realm = try! Realm()
    
    var locationManager = CLLocationManager()
    var currentLoc: CLLocation!
    
    // Completer to make requests with
    var searchCompleter: MKLocalSearchCompleter?
    // Region to search addresses in
    var searchRegion: MKCoordinateRegion?
    // IDK what this does tbh
    var currentPlacemark: CLPlacemark?
    
    // Holds results from requests
    var completerResults: [MKLocalSearchCompletion]?
    
    var shifts: Results<Shift>?
    var shift: Shift?
    var address = ""
    
    var date = Date()
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var notesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        locationManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
            searchRegion = MKCoordinateRegion(center: currentLoc.coordinate, latitudinalMeters: 8046.72, longitudinalMeters: 8046.72)
        }

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(NewAddressViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewAddressViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.notesTextField.delegate = self
        
        shifts = realm.objects(Shift.self)
        shift = shifts?.last
        
        if let isWorking = shift?.working {
            if !isWorking {
                do {
                    try realm.write {
                        shift?.working = true
                        shift?.lastSavedTime = CFAbsoluteTimeGetCurrent()
                        shift?.dateCreated = dateFormatter.string(from: date)
                    }
                } catch {
                    print("Error writing to shift: \(error)")
                }
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.reloadData()
        
        // Create new search completer and update the delegate
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.region = MKCoordinateRegion(center: currentLoc.coordinate, latitudinalMeters: 48280.3, longitudinalMeters: 48280.3)
        
        addressSearchBar.delegate = self
    }
    
    // This calls everytime the text in the search bar changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter?.queryFragment = searchText
    }
    
    // Calls everytime the query fragment changes
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(address)
        let existingAddress = realm.objects(Address.self).filter("address = '\(address)'")
        if let existingAddress = existingAddress.first {
            do {
                try realm.write {
                    if notesTextField?.text != "" {
                        existingAddress.notes = notesTextField?.text ?? ""
                    }
                    let newDelivery = Delivery()
                    newDelivery.address = address ?? ""
                    newDelivery.notes = existingAddress.notes
                    newDelivery.timeCreated = CFAbsoluteTimeGetCurrent()
                    realm.add(newDelivery)
                    shift?.deliveries.append(newDelivery)
                    existingAddress.deliveries.append(newDelivery)
                }
            } catch {
                print("\(error)")
            }
        } else {
            do {
                try realm.write {
                    let newAddress = Address()
                    newAddress.address = address ?? ""
                    newAddress.notes = notesTextField?.text ?? ""
                    let newDelivery = Delivery()
                    newDelivery.address = address ?? ""
                    newDelivery.notes = newAddress.notes
                    newDelivery.timeCreated = CFAbsoluteTimeGetCurrent()
                    realm.add(newDelivery)
                    shift?.deliveries.append(newDelivery)
                    newAddress.deliveries.append(newDelivery)
                    realm.add(newAddress)
                }
            } catch{
                print("\(error)")
            }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Address")
        if let address = completerResults?[indexPath.row] {
            cell.textLabel?.text = address.title
            cell.detailTextLabel?.text = address.subtitle
            cell.backgroundColor = UIColor(named: "Red")
            cell.textLabel?.textColor = UIColor(named: "White")
            cell.textLabel?.font = UIFont(name: "Varela Round", size: 22)
            cell.detailTextLabel?.font = UIFont(name: "Varela Round", size: 14)
            cell.detailTextLabel?.textColor = UIColor(named: "White")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(completerResults?[indexPath.row].title)
//        address = completerResults?[indexPath.row].title
        
//        print(address)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        address = completerResults?[indexPath.row].title ?? ""
        let selection = completerResults?[indexPath.row]
        addressSearchBar.text = completerResults?[indexPath.row].title ?? ""
        completerResults = [MKLocalSearchCompletion]()
        completerResults?.append(selection ?? MKLocalSearchCompletion())
        tableView.reloadData()
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
