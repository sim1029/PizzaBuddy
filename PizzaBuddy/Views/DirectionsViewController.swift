//
//  DirectionsViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 1/5/21.
//

import UIKit
import MapKit
import RealmSwift
import CoreLocation

class DirectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topLabel: UILabel!
    
    let realm = try! Realm()
    
    var locationManager = CLLocationManager()
    var currentLoc: CLLocation!
    
    // HOME
    let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.704830, longitude: -79.981160))
    
    // SUPREMEO'S
    let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.692960, longitude: -79.998080))
    
    var stop = Delivery()
    
    var directions: [String]?
    var source = MKMapItem()
    var destination = MKMapItem()
    var index = 0
    
    let request = MKDirections.Request()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
        }
        let address = stop.address
        topLabel.text = address
        source = MKMapItem(placemark: MKPlacemark(coordinate: currentLoc.coordinate))
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            let location = placemark?.location
            self.destination = MKMapItem(placemark: MKPlacemark(coordinate: location!.coordinate))
            self.calculateDirections()
        }
//        directions = ["Turn Left", "Turn Right", "You are lost"]
//        tableView.reloadData()
//        print(currentLoc.coordinate)
    }
    
    func calculateDirections(){
//        print("Begin Calculating directions")
        request.source = source
        request.destination = destination
//        print(destination.placemark.coordinate)
//        request.source = MKMapItem(placemark: p1)
//        request.destination = MKMapItem(placemark: p2)
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else {return}
            self.directions = route.steps.map {$0.instructions}.filter {!$0.isEmpty}
//            if let currentDirections = self.directions {
//                for step in currentDirections {
//                    print(step)
//                }
//            }
            self.tableView.reloadData()
//            print("Done fetching direcitions")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Instruction", for: indexPath) as! DeliveryCell
        if let instruction = directions?[indexPath.row]{
            cell.leftLabel.text = instruction
            cell.graphic.image = UIImage(named: "PizzaSlice")
        }
        return cell
    }
    
}

