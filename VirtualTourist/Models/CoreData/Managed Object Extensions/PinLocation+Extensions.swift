//
//  PinLocation+Extensions.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation
import CoreData

extension PinLocation {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        // initiate the creationDate with the pin creation time
        creationDate = Date()
        // initiate an empty PhotoCollection associate with the pin recently created
        collection = PhotoCollection(context: managedObjectContext!)
    }
}
