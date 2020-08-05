//
//  MapViewController.swift
//  PizzaBuddy
//
//  Created by Simon Schueller on 7/6/20.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let request = MKDirections.Request()
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        setUpMapView()
    }
    
    @IBAction func unwindFromAddressView(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
    }
    
    func currentLocation() {
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       if #available(iOS 11.0, *) {
          locationManager.showsBackgroundLocationIndicator = true
       } else {
          // Fallback on earlier versions
       }
       locationManager.startUpdatingLocation()
    }
    
    func setUpMapView() {
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        currentLocation()
        request.source = MKMapItem.forCurrentLocation()
        let long = -79.983130
        let lat = 40.701180
        let riteAid = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        request.destination = MKMapItem.init(placemark: MKPlacemark.init(coordinate: riteAid))
        let directions = MKDirections.init(request: request)
        directions.calculate { (res, error) in
            if error == nil {
                print("Route Info: ")
                if let route = res?.routes.first {
                    self.mapView.addOverlay(route.polyline)
                }
            } else {
                print("Error calculating directions \(error)")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Make sure we are rendering a polyline.
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }

        // Create a specialized polyline renderer and set the polyline properties.
        let polylineRenderer = MKPolylineRenderer(overlay: polyline)
        polylineRenderer.strokeColor = UIColor.systemOrange
        polylineRenderer.lineWidth = 3
        return polylineRenderer
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

extension MapViewController: CLLocationManagerDelegate {
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
      let location = locations.last! as CLLocation
      let currentLocation = location.coordinate
      let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
      mapView.setRegion(coordinateRegion, animated: true)
      locationManager.stopUpdatingLocation()
   }
    
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print(error.localizedDescription)
   }
}
