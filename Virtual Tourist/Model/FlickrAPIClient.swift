//
//  FlickrAPIClient.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-16.
//

import Foundation
import UIKit

class FlickrAPIClient {
    static let key = "3bc19d850bda40ffb8997ac7bf3e0029"
    
    enum Endpoints {
        
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        
        case searchURLString(Double, Double, Int)

        var urlString: String {
            switch self {
                case .searchURLString(let latitude, let longitude, let pageNum):
                    return Endpoints.base + "&api_key=\(FlickrAPIClient.key)" +
                        "&lat=\(latitude)" +
                        "&lon=\(longitude)" +
                        "&page=\(pageNum)" +
                        "&per_page=10&radius=25&extras=url_m&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    
}
