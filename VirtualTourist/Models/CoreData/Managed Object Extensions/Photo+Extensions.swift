//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        // initiate the creationDate with the photo creation time
        creationDate = Date()
    }
}
