//
//  ViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/3/20.
//

import UIKit
import RealmSwift
import CoreFoundation

class HomeViewController: UIViewController {
    
    let realm = try! Realm()
    
    var timer = Timer()
    var currentTime = CFAbsoluteTimeGetCurrent()
    
    // Hold current shift
    var shift: Shift?
    
    // Hold profile
    var profiles: Results<Profile>?
    var profile: Profile?
    
    // Hold all shifts saved in the realm
    var shifts: Results<Shift>?
    
    var date = Date()
    let dateFormatter = DateFormatter()
    
    var totalMoney = 0.0
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var clockDisplay: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    // Used with the timer
    var counter = 0.0
    var lastSavedTime = 0.0
    
    // Is the current shift acive?
    var isWorking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Try to populate shifts results
        dateFormatter.dateFormat = "MM/dd/yyyy"
        loadProfile()
        if profiles?.first != nil {
            profile = profiles?.first
        } else {
            do {
                try realm.write {
                    profile = Profile()
                    realm.add(profile!)
                }
            } catch {
                print("\(error)")
            }
        }
        deliveryLabel.text = ""
        tipsLabel.text = ""
        totalLabel.text = ""
        
        shifts = realm.objects(Shift.self)
        // Check if there are no shifts created yet
        if shifts?.isEmpty == true {
            shift = Shift()
            do {
                try realm.write {
                    realm.add(shift!)
                }
            } catch {
                print("Error saving Shift: \(error)")
            }
        } else {
            // Set current shift to the last shift created
            shift = shifts!.last
            // Check if still working
            isWorking = shift?.working ?? false
            counter = shift?.timeWorked ?? 0.0
            lastSavedTime = shift?.lastSavedTime ?? 0.0
            if isWorking == true{
                loadLabels()
                startButton.setBackgroundImage(UIImage(named: "pizzaBikeStopAsset 21"), for: .normal)
                runTimer()
                counter += currentTime - lastSavedTime
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            }
        }
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    @IBAction func startStopPressed(_ sender: UIButton) {
        if isWorking{
            let refreshAlert = UIAlertController(title: "Confirm Stop", message: "Shift will end and cannot be accessed again", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                  print("Handle Ok logic here")
                self.timer.invalidate()
                self.isWorking = false
                sender.setBackgroundImage(UIImage(named: "pizzaBikeAsset 20"), for: .normal)
                self.saveShift(createNewShift: true)
                self.counter = 0.0
                self.clockDisplay.text = "00:00:00"
                self.deliveryLabel.text = ""
                self.tipsLabel.text = ""
                self.totalLabel.text = ""
            }))

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("Handle Cancel Logic here")
            }))

            present(refreshAlert, animated: true, completion: nil)
        } else {
            loadLabels()
            isWorking = true
            do {
                try realm.write {
                    shift?.dateCreated = dateFormatter.string(from: date)
                }
            } catch {
                print("Erorr saving date created: \(error)")
            }
            sender.setBackgroundImage(UIImage(named: "pizzaBikeStopAsset 21"), for: .normal)
            // Do something with timer
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func runTimer() {
        counter += 0.5
        
        let flooredCounter = Int(floor(counter))
        
        let hour = flooredCounter / 3600
        var hourString = "\(hour)"
        if hour < 10 {
            hourString = "0\(hour)"
        }
        
        let minute = (flooredCounter % 3600) / 60
        var minuteString = "\(minute)"
        if minute < 10 {
            minuteString = "0\(minute)"
        }
        
        let second = (flooredCounter % 3600) % 60
        var secondString = "\(second)"
        if second < 10 {
            secondString = "0\(second)"
        }
        
        clockDisplay.text = "\(hourString):\(minuteString):\(secondString)"
    }
    
    func saveShift(createNewShift: Bool){
        currentTime = CFAbsoluteTimeGetCurrent()
        do{
            try realm.write {
                shift?.working = isWorking
                shift?.timeWorked = counter
                shift?.lastSavedTime = currentTime
                shift?.total = totalMoney
                if createNewShift {
                    shift = Shift()
                    realm.add(shift!)
                }
            }
        } catch {
            print("Error saving shift: \(error)")
        }
    }
    
    func loadLabels() {
        if let myDeliveries = shift?.deliveries {
            let completedDeliveries = countCompletedDeliveries(myDeliveries)
            if completedDeliveries != 1 {
                deliveryLabel.text = "\(completedDeliveries) Deliveries"
            } else {
                deliveryLabel.text = "\(completedDeliveries) Delivery"
            }
        }
        tipsLabel.text = "\(formatMoneyLabel(shift?.tips ?? 0)) Tips"
        var completions = 0.0
        if let myDeliveries = shift?.deliveries {
            for delivery in myDeliveries {
                print(delivery.complete)
                if delivery.complete {
                    completions += 1.0
                }
            }
        }
        if let myProfile = profile {
            var total = completions * (myProfile.baseFee) + shift!.tips
            total += (counter / 3600) * myProfile.minimumWage
            totalLabel.text = "\(formatMoneyLabel(total)) Total"
            totalMoney = total
        }
    }
    
    func countCompletedDeliveries(_ deliveries: List<Delivery>) -> Int {
        var counter = 0
        for delivery in deliveries {
            if delivery.complete {
                counter += 1
            }
        }
        return counter
    }
    
    func formatMoneyLabel(_ money: Double) -> String {
        var moneyString = "$"
        moneyString += String(format: "%.2f", money)
        return moneyString
    }
    
    func loadProfile() {
        profiles = realm.objects(Profile.self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveShift(createNewShift: false)
    }

}

