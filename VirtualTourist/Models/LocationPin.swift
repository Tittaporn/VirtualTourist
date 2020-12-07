//
//  LocationPin.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation
import MapKit

class LocationPin: MKPointAnnotation {
    var pin: PinLocation
    
    init(pin: PinLocation){
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
