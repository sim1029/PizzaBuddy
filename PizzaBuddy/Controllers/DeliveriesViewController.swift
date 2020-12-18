//
//  DeliveriesViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import UIKit
import RealmSwift
import SwipeCellKit

class DeliveriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numberOfDeliveriesLabel: UILabel!
    
    let realm = try! Realm()
    
    var deliveries: Results<Delivery>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Seed the deliveries data base (DELETE WHEN DONE TESTING)
        loadDeliveries()
        
        if deliveries?.count ?? 0 == 0{
            let newDelivery = Delivery()
            newDelivery.address = "123 Sample address Ln"
            newDelivery.notes = "Sample note 1"
            newDelivery.complete = true
            
            let newDelivery1 = Delivery()
            newDelivery1.address = "231 Sample address Ln"
            newDelivery1.notes = "Sample note 2"
            
            let newDelivery2 = Delivery()
            newDelivery2.address = "312 Sample address Ln"
            newDelivery2.notes = "Sample note 3"
            
            do {
                try realm.write{
                    realm.add(newDelivery)
                    realm.add(newDelivery1)
                    realm.add(newDelivery2)
                }
            } catch {
                print("Error saving folds \(error)")
            }
            
        }
        
        //STOP DELETING HERE! (But delete the comment yo)
        loadDeliveries()

        // Do any additional setup after loading the view
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveries?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! SwipeTableViewCell
        
            if let delivery = deliveries?[indexPath.row]{
                cell.textLabel?.text = delivery.address
                cell.textLabel?.textColor = UIColor.white
                if delivery.complete{
                    cell.backgroundColor = #colorLiteral(red: 0.568627451, green: 0.7411764706, blue: 0.2274509804, alpha: 1)
                } else {
                    cell.backgroundColor = #colorLiteral(red: 1, green: 0.3176470588, blue: 0.3176470588, alpha: 1)
                }
            }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left{
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // Update model with deletion
                if let delivery = self.deliveries?[indexPath.row]{
                    do {
                        try self.realm.write{
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
            if let delivery = self.deliveries?[indexPath.row]{
                if delivery.complete{
                    let resetAction = SwipeAction(style: .default, title: "Reset") { (action, indexPath) in
                        do {
                            try self.realm.write{
                                delivery.complete = false
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
                        do {
                            try self.realm.write {
                                delivery.complete = true
                            }
                            self.loadDeliveries()
                        } catch {
                            print("Error saving folds \(error)")
                        }
                    }
                    completeAction.image = UIImage(named: "complete")
                    completeAction.backgroundColor = #colorLiteral(red: 0.568627451, green: 0.7411764706, blue: 0.2274509804, alpha: 1)
                    
                    return [completeAction]
                }
            }
//            let completeAction = SwipeAction(style: .default, title: "Complete") { (action, indexPath) in
//                if let delivery = self.deliveries?[indexPath.row]{
//                    do {
//                        try self.realm.write{
//                            delivery.complete = true
//                        }
//                        self.loadDeliveries()
//                    } catch {
//                        print("Error saving folds \(error)")
//                    }
//                }
//            }
//
//            completeAction.image = UIImage(named: "complete")
//            completeAction.backgroundColor = #colorLiteral(red: 0.568627451, green: 0.7411764706, blue: 0.2274509804, alpha: 1)
            
//            return [completeAction]
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
    
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return deliveries?.count ?? 1
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath)
//        if let delivery = deliveries?[indexPath.row]{
//            cell.textLabel?.text = delivery.address
//
////            cell.backgroundColor =
//            cell.textLabel?.textColor = UIColor.white
//        }
//        return cell
//    }
    
    func loadDeliveries() {
        deliveries = realm.objects(Delivery.self)
        updateLabel()
        tableView.reloadData()
    }
    
    @IBAction func unwindFromAddressView(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        loadDeliveries()
        // Use data from the view controller which initiated the unwind segue
    }
    
    func updateLabel() {
        var baseString = "My Deliveries ("
        baseString += String(deliveries?.count ?? 0)
        baseString += ")"
        numberOfDeliveriesLabel.text = baseString
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

