//
//  MapModel.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-19.
//

import Foundation
import MapKit

class MapModel: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    var pin: Pin
    
    init(name: String, latitude: Double, longitude: Double, country: String, pin: Pin) {
        self.title = name
        self.subtitle = country
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.pin = pin
        super.init()
    }
}
