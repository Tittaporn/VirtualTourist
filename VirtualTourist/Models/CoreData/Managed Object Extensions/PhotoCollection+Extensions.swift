//
//  PhotoCollection+Extensions.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation
import CoreData

extension PhotoCollection{
    // helper property to check if the photoCollection is empty
    var isEmpty: Bool{
        return photos?.count ?? 0 == 0
    }
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        // initiate the creationDate with the photoCollection creation time
        creationDate = Date()
    }
}
