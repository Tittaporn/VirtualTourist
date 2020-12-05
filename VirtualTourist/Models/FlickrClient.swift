//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/4/20.
//

import Foundation

class FlickrClient {
    
    static let apiKey = "4ded05561aa160f1e270ead2bdb4d70f"
   // static let apiKeySecret = " 86bb06132f7c7f33"
    //Endpoint
    
    enum Endpoints {
        //https://www.flickr.com/services/rest/?method=flickr.test.echo&name=value
        static let baseForsearch = "https://www.flickr.com/services/rest/?method="
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        static let baseForPhoto = "https://live.staticflickr.com/" //{server-id}/{id}_{secret}_{size-suffix}.jpg"
        case searchPhotos(String, String)
        case photoImage(String, String, String)
    
    var stringValue: String {
        switch self {
        case .searchPhotos(let latitude, let longitude):
            return Endpoints.baseForsearch + "flickr.photo.search" + Endpoints.apiKeyParam + "&lat=\(latitude)&lon=\(longitude)"
        case .photoImage(let serverId, let id, let secret):
            return Endpoints.baseForPhoto + "\(serverId)/\(id)_\(secret).jpg"
            
        }
    }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    //https://api.flickr.com/services
    
    //VirtualTourist
//    Key:
//    4ded05561aa160f1e270ead2bdb4d70f
//
//    Secret:
//    86bb06132f7c7f33
    
    
    //MARK : -TasksForRequest
    class func taskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
                  
        return task
    
}
    
    class func searchPhotos(latitude: String, longitude: String, completion: @escaping (Photos?, Error?) -> Void) {
        _ =  taskForGETRequest(url: Endpoints.searchPhotos(latitude, longitude).url, response: SearchResponse.self) { (searchRespones, error) in
            if let error = error {
                print("Error Searching Photos : \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            completion(searchRespones!.photos, nil)
        }
    }
    
    
    class func downloadPhotoImage(serverId: String, id: String, secret: String, completion: @escaping (Data?, Error?) -> Void) {
        
        _ = taskForGETRequest(url: Endpoints.photoImage(serverId, id, secret).url, response: Data.self) {(data, error) in
            
        guard let data = data else {
            print("Error!! No image Data in PhotoImage : \(String(describing: error))")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
}
}
