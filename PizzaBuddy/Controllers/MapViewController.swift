//
//  MapViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/6/20.
//

import UIKit
import RealmSwift

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    
    let realm = try! Realm()
    
    var shifts: Results<Shift>?
    var currentShift: Shift?
    var deliveries: List<Delivery>?
    var activeDeliveries = List<Delivery>()
    
    var selections = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        loadDeliveries()
        
        topLabel?.text = "Select destination:"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeDeliveries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! DeliveryCell
        let delivery = activeDeliveries[indexPath.row]
        cell.leftLabel.text = delivery.address
        cell.rightLabel.text = ""
        cell.currentlySelected = false
        cell.backgroundColor = UIColor(named: "Red")
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//
//        let cell = tableView.cellForRow(at: indexPath) as! DeliveryCell
//
//        if !cell.currentlySelected {
//
//            selections += 1
//
//            cell.rightLabel.text = "\(selections)"
//
//            topLabel?.text = "Select destination #\(selections+1)"
//
//            cell.currentlySelected = true
//        }
//    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        tableView.reloadData()
        selections = 0
        topLabel?.text = "Select destination #\(selections+1)"
    }
    
    func loadDeliveries(){
        shifts = realm.objects(Shift.self)
        currentShift = shifts?.last
        deliveries = currentShift?.deliveries
        for delivery in deliveries! {
            if !delivery.complete {
//                print(delivery.address)
                activeDeliveries.append(delivery)
            }
        }
        for delivery in activeDeliveries {
            print(delivery.address)
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDirections"{
            let destinationVC = segue.destination as! DirectionsViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.stop = activeDeliveries[indexPath.row] ?? Delivery()
            }
        }
    }
    
    @IBAction func unwindFromAddressView(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
    }
    
}

