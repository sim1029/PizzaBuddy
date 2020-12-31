//
//  ViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/3/20.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    let realm = try! Realm()
    
    // Hold current shift
    var shift: Shift?
    
    // Hold all shifts saved in the realm
    var shifts: Results<Shift>?
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var clockDisplay: UILabel!
    
    // Used with the timer
    var seconds = 0
    
    // Is the current shift acive?
    var working = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Try to populate shifts results
        shifts = realm.objects(Shift.self)
        // Check if there are no shifts created yet
        if shifts?.isEmpty == true {
            shift = Shift()
        } else {
            // Set current shift to the last shift created
            shift = shifts!.last
            // Check if still working
            working = shift?.working ?? false
            if working == true{
                working.toggle()
                startStopPressed(startButton)
            }
        }
//        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
    @IBAction func startStopPressed(_ sender: UIButton) {
        working.toggle()
        if working == true {
            sender.setBackgroundImage(UIImage(named: "pizzaBikeStopAsset 21"), for: .normal)
            seconds = shift?.timeWorked ?? 0
        } else {
            sender.setBackgroundImage(UIImage(named: "pizzaBikeAsset 20"), for: .normal)
            do{
                try realm.write {
                    shift?.working = false
                    shift?.timeWorked = seconds
                    seconds = 0
                    shift = Shift()
                    realm.add(shift!)
                }
            } catch {
                print("Error saving Shift: \(error)")
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in

            self.seconds += 1
            
            self.clockDisplay.text = self.formatClock(time: self.seconds)

            if self.working != true {
                timer.invalidate()
                self.clockDisplay.text = self.formatClock(time: 0)
            }
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        do {
            try realm.write {
                shift?.timeWorked = seconds
                shift?.working = working
            }
        } catch {
            print("Error saving seconds: \(error)")
        }
    }
    
    func formatClock(time seconds: Int) -> String {
        var s = seconds
        var m = 0
        var h = 0
        var ss: String
        var ms: String
        var hs: String
        
        if(s >= 60) {
            m = s / 60
            s %= 60
        }
        if(m > 60){
            h = m / 60
            m %= 60
        }
        
        if(s/10 != 0){
            ss = ":" + String(s)
        } else {
            ss = ":0" + String(s)
        }
        
        if(m/10 != 0){
            ms = ":" + String(m)
        } else {
            ms = ":0" + String(m)
        }
        
        if(h/10 != 0){
            hs = "" + String(h)
        } else {
            hs = "0" + String(h)
        }
        
        return hs + ms + ss
    }
    
    func countSeconds(){
        
    }

}

