//
//  MapViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/6/20.
//

import UIKit
import RealmSwift
import CoreFoundation

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
        let delivery = activeDeliveries[activeDeliveries.count - 1 - indexPath.row]
        cell.leftLabel.text = delivery.address
        cell.rightLabel.text = "\(Int((CFAbsoluteTimeGetCurrent() - delivery.timeCreated) / 60)) min"
        cell.currentlySelected = false
        cell.backgroundColor = UIColor(named: "Red")
        
        return cell
    }
    
    func loadDeliveries(){
        activeDeliveries.removeAll()
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
                destinationVC.stop = activeDeliveries[activeDeliveries.count - 1 - indexPath.row] ?? Delivery()
                destinationVC.shift = currentShift ?? Shift()
            }
        }
    }
    
    @IBAction func unwindFromAddressView(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDeliveries()
    }
    
}

