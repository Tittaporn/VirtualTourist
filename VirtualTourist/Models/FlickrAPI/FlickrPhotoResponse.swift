//
// FlickrPhotoResponse.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/4/20.
//

import Foundation

struct FlickrPhotoResponse: Codable {
    let id: String
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url = "url_m"
    }
}
    //    let id: String
//    let owener: String
//    let secret: String
//    let server: String
//    let title: String
//    let ispublic: Int
//    let isfriend: Int
//    let isfamily: Int
//}
