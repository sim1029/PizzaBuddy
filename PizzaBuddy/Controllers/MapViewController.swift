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
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    
    let realm = try! Realm()
    
    var deliveries: Results<Delivery>?
    
    var selections = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        loadDeliveries()
        
        topLabel?.text = "Select destination #\(selections+1)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveries?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! DeliveryCell
        if let delivery = deliveries?[indexPath.row]{
            cell.leftLabel.text = delivery.address
            cell.rightLabel.text = ""
            cell.currentlySelected = false
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.6919776201, blue: 0, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let cell = tableView.cellForRow(at: indexPath) as! DeliveryCell
        
        if !cell.currentlySelected {
            selections += 1
            
            cell.rightLabel.text = "\(selections)"
            
            topLabel?.text = "Select destination #\(selections+1)"
            
            cell.currentlySelected = true
        }
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        tableView.reloadData()
        selections = 0
        topLabel?.text = "Select destination #\(selections+1)"
    }
    
    func loadDeliveries(){
        deliveries = realm.objects(Delivery.self)
        tableView.reloadData()
    }
    
    @IBAction func unwindFromAddressView(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
    }
    
}

