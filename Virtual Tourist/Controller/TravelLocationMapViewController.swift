//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-14.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData

class TravelLocationMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin?
    let regionKey: String = "persistedMapRegion"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.requestWhenInUseAuthorization()
        
        // initialize user's location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        
        // callPersistedLcation() // TODO
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // refreshData() // TODO
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            // Get the coordinates of the tapped location on the map.
            let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            print("On long press: ", locationCoordinate)
            saveGeoCoordination(from: locationCoordinate)
        }
    }
    
    // get Geo position and store value Pin viewContext
    func saveGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPos = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            annotation.title = placemark.name ?? "Not Known"
            annotation.subtitle = placemark.country
            annotation.coordinate = coordinate
            self.copyLocation(annotation)
        }
    }
    
    func copyLocation(_ annotation: MKPointAnnotation) {
        let location = Pin(context: dataController.viewContext)
        location.createdDate = Date()
        location.longitude = annotation.coordinate.longitude
        location.latitude = annotation.coordinate.latitude
        location.locationName = annotation.title
        location.country = annotation.subtitle
        location.pages = 0
        try? dataController.viewContext.save()
        let annotationPin = MapModel(name: annotation.title!, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, location: "", url: annotation.subtitle!, pin: location)
        self.mapView.addAnnotation(annotationPin)
    }
    
}

extension TravelLocationMapViewController: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        var view: MKMarkerAnnotationView
//        // TODO
//        return view
//    }
//
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        // TODO
//    }

}

extension TravelLocationMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
//            locationManager.requestLocation()
            print("Location Authorization status = ", status)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            UserDefaults.standard.setValue(locValue.latitude, forKey: "Latitude")
            UserDefaults.standard.setValue(locValue.longitude, forKey: "Longitude")
            UserDefaults.standard.synchronize()
            mapView.centerToLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }
    
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}


