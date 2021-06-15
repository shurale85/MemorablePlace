//
//  ViewController.swift
//  MemorablePlace
//
//  Created by NewUSER on 06.02.2021.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
        
        uilpgr.minimumPressDuration = 2
        
        map.addGestureRecognizer(uilpgr)
    
        if activePlaces == -1 {
            
            manager.delegate = self
            
            manager.desiredAccuracy = kCLLocationAccuracyBest
            
            manager.requestWhenInUseAuthorization()
            
            manager.startUpdatingLocation()
        }
        
        else {
            if places.count > activePlaces {
                
                if let name = places[activePlaces]["name"] {
                    
                    if let lat = places[activePlaces]["lat"] {
                        
                        if let lon = places[activePlaces]["lon"] {
                            
                            if let latitude = Double(lat) {
                                
                                if let longitude = Double(lon) {
                                    
                                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    
                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude:  longitude)
                                    
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    
                                    self.map.setRegion(region, animated: true)
                                    
                                    let annotation = MKPointAnnotation()
                                    
                                    annotation.coordinate = coordinate
                                    
                                    annotation.title = name
                                    
                                    self.map.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = gestureRecognizer.location(in: self.map)
            
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom:self.map)
                        
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            var title = ""
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler : { (placemarks, error) in
                
                if error != nil {
                    
                    print(error)
                } else {
                    
                    if let placemark = placemarks?[0] {
                        
                        if let sub = placemark.subThoroughfare {
                            
                            title += sub + " "
                        }
                        
                        if let througFare = placemark.thoroughfare {
                            
                            title += througFare + " "
                        }
                    }
                }
                if title == "" {
                    
                    title = "Added \(NSDate())"
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = "Temp title"
                self.map.addAnnotation(annotation)
                places.append(["name" : title, "lat" : String(newCoordinate.latitude), "lon" : String(newCoordinate.longitude)])
                UserDefaults.standard.set(places, forKey: "places")
            })
            
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.map.setRegion(region, animated: true)
    }

}

