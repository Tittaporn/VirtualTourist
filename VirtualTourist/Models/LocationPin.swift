//
//  LocationPin.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation
import MapKit
// custom MKAnnotation that store a Pin
class LocationPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pin: PinLocation
    
    init(pin: PinLocation) {
        self.pin = pin
        coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.latitude)
        super.init()
        
    }
}
