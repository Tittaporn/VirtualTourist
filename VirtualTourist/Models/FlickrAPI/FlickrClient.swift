//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/4/20.
//

import Foundation
import UIKit

class FlickrClient {
    static let shared = FlickrClient()
    static let apiKey = "4ded05561aa160f1e270ead2bdb4d70f"
    private init() {}
    enum Endpoints {
        static let baseForsearch = "https://www.flickr.com/services/rest/?method="
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
      
        case searchPhotos
        // case photoImage(String, String, String)
        
        var stringValue: String {
            switch self {
            case .searchPhotos:
                return Endpoints.baseForsearch + "flickr.photo.search" + Endpoints.apiKeyParam + "&nojsoncallback=1&format=json&per_page=50&extras=url_m"
            }
        }
    }
 
    func seachPhotoFromLocation(lat: Double, long: Double, page: Int = 1, completion: @escaping (FlickPhotosResponse?, Error?) -> Void) {
        guard let url = URL(string: Endpoints.searchPhotos.stringValue + "&lat=" + String(lat) + "&lon=" + String(long) + "&page=" + String(page)) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(FlickrSaerchResponse.self, from: data)
                let photos = response.photos
                DispatchQueue.main.async {
                    completion(photos, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error decoding for searchPhotoLocation!!")
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func getPhotoImage(url:URL, completion: @escaping (UIImage?)->Void){
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil,
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data,
                let image = UIImage(data: data) else{
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
}
