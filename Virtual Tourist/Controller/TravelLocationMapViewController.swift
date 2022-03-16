//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-14.
//

import UIKit
import MapKit

class TravelLocationMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        FlickrAPIClient.getPhotosForSelectedLocation(latitude: 44.923639311481736, longitude: -93.32636418719535, pageNum: 1, completion: handlePhotosResponse(success:error:))
    }

    func handlePhotosResponse(success: [PhotoResponse]?, error: Error?) {
        print("handlePhotosResponse")
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

