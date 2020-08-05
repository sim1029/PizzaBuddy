//
//  DeliveriesViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import UIKit
import RealmSwift

class DeliveriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var deliveries: Results<Delivery>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadDeliveries()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveries?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath)
                if let delivery = deliveries?[indexPath.row]{
                    cell.textLabel?.text = delivery.address
        
        //            cell.backgroundColor =
                    cell.textLabel?.textColor = UIColor.white
                }
                return cell
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
        tableView.reloadData()
    }
    
    @IBAction func unwindFromAddressView(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        loadDeliveries()
        // Use data from the view controller which initiated the unwind segue
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
