//
//  DeliveryViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/9/20.
//

import UIKit
import RealmSwift

class DeliveryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var tipRating: UILabel!
    @IBOutlet weak var tip: UILabel!
    @IBOutlet weak var visits: UILabel!
    @IBOutlet weak var averageDeliveryTime: UILabel!
    @IBOutlet weak var notes: UILabel!
    
    let realm = try! Realm()
    
    var selectedDelivery : Delivery?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let delivery = selectedDelivery {
            loadDelivery(delivery)
        }
    }
    
    func loadDelivery(_ delivery: Delivery) {
        address?.text = delivery.address
        visits?.text = String(delivery.visits) + " Visits"
        notes?.text = delivery.notes
        tip?.text = "$\(delivery.tip) Tip"
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
