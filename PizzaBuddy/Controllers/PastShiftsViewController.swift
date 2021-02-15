//
//  PastShiftsViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 1/16/21.
//

import UIKit
import RealmSwift
import SwipeCellKit

class PastShiftsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var shifts: Results<Shift>?
    
    override func viewDidLoad() {
        loadShifts()
    }
    
    func loadShifts() {
        shifts = realm.objects(Shift.self).filter("dateCreated != ''")
        topLabel.text = "My Shifts (\(shifts?.count ?? 0))"
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // Update model with deletion
                if let shift = self.shifts?[self.shifts!.count - 1 - indexPath.row] {
                    do {
                        try self.realm.write{
                            self.realm.delete(shift)
                        }
                        self.loadShifts()
                    } catch {
                        print("Error saving Shifts \(error)")
                    }
                }
            }
            
            deleteAction.image = UIImage(named: "delete")
            
            return [deleteAction]
        }
        return [SwipeAction]()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shifts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyDeliveryCell", for: indexPath) as! MyDeliveryCell
        
        if let shift = shifts?[shifts!.count - 1 - indexPath.row] {
            cell.textLabel?.text = "\(shift.dateCreated)"
            cell.textLabel?.textColor = UIColor(named: "White")
            cell.rightLabel.text = "\(formatMoneyLabel(shift.total))"
            cell.delegate = self
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShift" {
            let destinationVC = segue.destination as! ShiftViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.shift = shifts?[shifts!.count - 1 - indexPath.row] ?? Shift()
            }
        }
    }
    
    func formatMoneyLabel(_ money: Double) -> String {
        var moneyString = "$"
        moneyString += String(format: "%.2f", money)
        return moneyString
    }
    
}


extension PastShiftsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(for: searchBar.text!)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count != 0 {
            performSearch(for: searchBar.text!)
        } else {
            loadShifts()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

    func performSearch(for text: String) {
        shifts = realm.objects(Shift.self).filter("dateCreated != ''")
        shifts = shifts?.filter("dateCreated CONTAINS[cd] %@", text)
        tableView.reloadData()
    }
}
