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
        callPersistedLcation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
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
        let annotationPin = MapModel(name: annotation.title!, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, country: annotation.subtitle!, pin: location)
        self.mapView.addAnnotation(annotationPin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else { return }
        let pinAnnotation: MapModel = sender as! MapModel
        photoAlbumViewController.pin = pinAnnotation.pin
        photoAlbumViewController.dataController = dataController
    }
    
    func refreshData() {
        // clear all annotations to get new data
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // fetch all pins
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
           
        dataController.viewContext.perform {
            do {
                let pins = try self.dataController.viewContext.fetch(request)
                self.mapView.addAnnotations(pins.map { pin in MapModel(name: pin.locationName!, latitude: pin.latitude, longitude: pin.longitude, country: pin.country!, pin: pin) })
            } catch {
                print("Error fetching Pins: \(error)")
            }
        }
    }
    
}

extension TravelLocationMapViewController: MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // var view: MKMarkerAnnotationView
        let reuseId = "pin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
        let pinAnnotation = annotation as! MapModel
        pinAnnotation.title = pinAnnotation.pin.locationName
        pinAnnotation.subtitle = pinAnnotation.pin.country
    
        print("\(String(describing: pinAnnotation.title)) \(String(describing: pinAnnotation.subtitle))")
   
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            view!.canShowCallout = true
            view!.pinTintColor = UIColor.red
            view!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            view!.annotation = annotation
        }
        
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("mapView on tap function call")
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {
                return
            }
        if let annotation = view.annotation as? MapModel {
            self.performSegue(withIdentifier: "showPhotoAlbum", sender: annotation)
        }
    }
    
    func saveMapLocation() {
       let mapRegion = [
        "latitude" : mapView.region.center.latitude,
        "longitude" : mapView.region.center.longitude,
        "latitudeDelta" : mapView.region.span.latitudeDelta,
        "longitudeDelta" : mapView.region.span.longitudeDelta
       ]
       UserDefaults.standard.set(mapRegion, forKey: regionKey)
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
       self.saveMapLocation()
    }

    func callPersistedLcation() {
       if let mapRegin = UserDefaults.standard.dictionary(forKey: regionKey) {
           let location = mapRegin as! [String: CLLocationDegrees]
           let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
           let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
           
           mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
       }
    }
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
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 100000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}


