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
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    var info: String
    
    var pin: Pin
    
    init(name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, location: String, url: String, pin: Pin) {
        self.title = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.subtitle = url // updating based on the code review suggestion
        self.info = url
        self.pin = pin
    }
}
