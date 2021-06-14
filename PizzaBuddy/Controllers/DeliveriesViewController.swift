//
//  DeliveriesViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import UIKit
import RealmSwift
import SwipeCellKit
import CoreFoundation
import CoreLocation

class DeliveriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numberOfDeliveriesLabel: UILabel!
    
    let realm = try! Realm()
    
    var deliveries: List<Delivery>?
    var shifts: Results<Shift>?
    var currentShift: Shift?
    var myIndexPath: IndexPath?
    
    var currentTime = CFAbsoluteTimeGetCurrent()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDeliveries()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveries?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! MyDeliveryCell
        
        if let delivery = deliveries?[deliveries!.count - 1 - indexPath.row]{
                cell.textLabel?.text = delivery.address
                cell.textLabel?.textColor = UIColor.white
                if delivery.complete{
                    cell.backgroundColor = #colorLiteral(red: 0.568627451, green: 0.7411764706, blue: 0.2274509804, alpha: 1)
                    cell.rightLabel.text = "\(formatMoneyLabel(delivery.tip))"
                } else {
                    cell.backgroundColor = #colorLiteral(red: 1, green: 0.3176470588, blue: 0.3176470588, alpha: 1)
                    cell.rightLabel.text = "\(Int((currentTime - delivery.timeCreated) / 60)) min"
                }
            }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left{
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // Update model with deletion
                if let delivery = self.currentShift?.deliveries[self.deliveries!.count - 1 - indexPath.row] {
                    do {
                        try self.realm.write{
                            if delivery.complete {
                                self.currentShift?.tips -= delivery.tip
                                self.currentShift?.total -= delivery.tip
                            }
                            self.realm.delete(delivery)
                        }
                        self.loadDeliveries()
                    } catch {
                        print("Error saving folds \(error)")
                    }
                }
            }
            
            deleteAction.image = UIImage(named: "delete")
            
            return [deleteAction]
        } else{
            if let delivery = self.currentShift?.deliveries[self.deliveries!.count - 1 - indexPath.row] {
                if delivery.complete{
                    let resetAction = SwipeAction(style: .default, title: "Reset") { (action, indexPath) in
                        do {
                            try self.realm.write{
                                delivery.deliveryTime = 0
                                self.currentShift?.tips -= delivery.tip
                                self.currentShift?.total -= delivery.tip
                                delivery.complete = false
                                delivery.tip = 0
                            }
                            self.loadDeliveries()
                        } catch {
                            print("Error saving folds \(error)")
                        }
                    }
                    resetAction.image = UIImage(named: "reset")
                    resetAction.backgroundColor = #colorLiteral(red: 1, green: 0.3176470588, blue: 0.3176470588, alpha: 1)
                    
                    return [resetAction]
                } else {
                    let completeAction = SwipeAction(style: .default, title: "Complete") { (action, indexPath) in
                        self.myIndexPath = indexPath
                        self.performSegue(withIdentifier: "toCompletion", sender: nil)
//                        do {
//                            try self.realm.write {
//                                delivery.complete = true
//                            }
//                            self.loadDeliveries()
//                        } catch {
//                            print("Error saving folds \(error)")
//                        }
                    }
                    completeAction.image = UIImage(named: "complete")
                    completeAction.backgroundColor = #colorLiteral(red: 0.568627451, green: 0.7411764706, blue: 0.2274509804, alpha: 1)
                    
                    return [completeAction]
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .fill
        options.transitionStyle = .border
        return options
    }
    
    //MARK: - TableView Datasource Methods
    
    
    func loadDeliveries() {
        shifts = realm.objects(Shift.self)
        currentShift = shifts?.last
        deliveries = currentShift?.deliveries
        updateLabel()
        tableView.reloadData()
    }
    
    @IBAction func unwindFromAddressView(_ unwindSegue: UIStoryboardSegue) {
        loadDeliveries()
        // Use data from the view controller which initiated the unwind segue
    }
    
    func updateLabel() {
        var baseString = "My Deliveries ("
        baseString += String(deliveries?.count ?? 0)
        baseString += ")"
        numberOfDeliveriesLabel.text = baseString
    }
    
    func formatMoneyLabel(_ money: Double) -> String {
        var moneyString = "$"
        moneyString += String(format: "%.2f", money)
        return moneyString
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDelivery"{
            let destinationVC = segue.destination as! DeliveryViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedDelivery = currentShift?.deliveries[deliveries!.count - 1 - indexPath.row]
            }
        }
        if segue.identifier == "toCompletion" {
            if let indexPath = myIndexPath {
                let destinationVC = segue.destination as! CompleteDeliveryViewController
                destinationVC.delivery = currentShift?.deliveries[deliveries!.count - 1 - indexPath.row] ?? Delivery()
                destinationVC.shift = currentShift ?? Shift()
            }
            
        }
    }

    @IBAction func goToNewDelivery(_ sender: UIButton) {
        if !(CLLocationManager.authorizationStatus() == .denied){
            performSegue(withIdentifier: "toNewAddress", sender: UIButton())
        }
        print("DENIED")
    }
}

// Search bar methods
extension DeliveriesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(for: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count != 0 {
            performSearch(for: searchBar.text!)
        } else {
            loadDeliveries()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func performSearch(for text: String) {
        deliveries = currentShift?.deliveries
        if let myDeliveries = deliveries?.filter("address CONTAINS[cd] %@", text) {
            deliveries = List<Delivery>()
            for delivery in myDeliveries {
                deliveries?.append(delivery)
            }
        }
        tableView.reloadData()
    }
}

