//
//  FlickrSearchResponse.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation

struct FlickrSaerchResponse: Codable {
    let photos: FlickPhotosResponse
    let stat: String
    
    enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
}
