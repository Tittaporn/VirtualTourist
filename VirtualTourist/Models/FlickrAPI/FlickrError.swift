//
//  FlickrError.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation

struct FlickrError: Error, Decodable{
    let stat:String
    let code:Int
    let message:String
}

extension FlickrError {
    var errorDescription: String{
        switch code {
        case 1:
            return "When performing an 'all tags' search, you may not specify more than 20 tags to join together."
        case 2:
            return "A user_id was passed which did not match a valid flickr user."
        case 3:
            return "To perform a search with no parameters (to get the latest public photos, please use flickr.photos.getRecent instead)."
        case 4:
            return "The logged in user (if any) does not have permission to view the pool for this group."
        case 5:
            return "The user id passed did not match a Flickr user."
        case 10:
            return "The Flickr API search databases are temporarily unavailable."
        case 11:
            return "The query styntax for the machine_tags argument did not validate."
        case 12:
            return "The maximum number of machine tags in a single query was exceeded."
        case 17:
            return "The call tried to use the contacts parameter with no user ID or a user ID other than that of the authenticated user."
        case 18:
            return "The request contained contradictory arguments."
        case 100:
            return "The API key passed was not valid or has expired."
        case 105:
            return "The requested service is temporarily unavailable."
        case 106:
            return "The requested operation failed due to a temporary issue."
        case 111:
            return "The requested response format was not found."
        case 112:
            return "The requested method was not found."
        case 114:
            return "The SOAP envelope send in the request could not be parsed."
        case 115:
            return "The XML-RPC request document could not be parsed."
        case 116:
            return "One or more arguments contained a URL that has been used for abuse on Flickr."
        default:
            return "Something went wrong"
        }
    }
}
