//
//  ViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/3/20.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var clockDisplay: UILabel!
    
    var start = false
    
    @IBAction func startStopPressed(_ sender: UIButton) {
        start.toggle()
        if start {
            sender.setBackgroundImage(UIImage(named: "pizzaBikeStopAsset 21"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "pizzaBikeAsset 20"), for: .normal)
        }
        
        var seconds = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in

            seconds += 1
            
            self.clockDisplay.text = self.formatClock(time: seconds)

            if self.start != true {
                timer.invalidate()
                self.clockDisplay.text = self.formatClock(time: 0)
            }
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

