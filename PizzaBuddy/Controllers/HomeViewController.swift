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
    
    // Hold all shifts saved in the realm
    var shifts: Results<Shift>?
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var clockDisplay: UILabel!
    
    // Used with the timer
    var counter = 0.0
    var lastSavedTime = 0.0
    
    // Is the current shift acive?
    var isWorking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Try to populate shifts results
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
            timer.invalidate()
            isWorking = false
            sender.setBackgroundImage(UIImage(named: "pizzaBikeAsset 20"), for: .normal)
            saveShift(createNewShift: true)
            counter = 0.0
            clockDisplay.text = "00:00:00"
        } else {
            isWorking = true
            sender.setBackgroundImage(UIImage(named: "pizzaBikeStopAsset 21"), for: .normal)
            // Do something with timer
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        }

//            let alert = UIAlertController(title: "Confirm Stop", message: "Are you sure you want to end the current shift?", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Shift will end if pressed"), style: .default, handler: { _ in
//                self.working.toggle()
//            }))
//            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancels the action"), style: .cancel, handler: { _ in
//            }))
//            self.present(alert, animated: true) {
//                <#code#>
        
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
                if createNewShift {
                    shift = Shift()
                    realm.add(shift!)
                }
            }
        } catch {
            print("Error saving shift: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveShift(createNewShift: false)
    }

}

