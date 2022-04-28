//
//  FlickrAPIClient.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-16.
//

import Foundation

class FlickrAPIClient {
    static let key = "3bc19d850bda40ffb8997ac7bf3e0029"
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        
        case searchURLString(Double, Double, Int)

        var stringValue: String {
            switch self {
                case .searchURLString(let latitude, let longitude, let pageNum):
                    return Endpoints.base + "&api_key=\(FlickrAPIClient.key)" +
                        "&lat=\(latitude)" +
                        "&lon=\(longitude)" +
                        "&page=\(pageNum)" +
                        "&per_page=10&radius=32&extras=url_m&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPhotosForSelectedLocation(latitude: Double, longitude: Double, pageNum: Int, completion: @escaping (PhotosResponse?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.searchURLString(latitude, longitude, pageNum).url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                // Handle error...
                print("Error response received with getPhotosForSelectedLocation http request")
                DispatchQueue.main.async {
                    completion (nil, error)
                }
                return
            }
            if data != nil {
                print(String(data: data!, encoding: .utf8)!)
                let decoder = JSONDecoder()
                do{
                    let response = try
                        decoder.decode(SearchResponse.self, from: data!)
                    print("Data decoded")
                    DispatchQueue.main.async {
                        completion(response.photos, nil)
                    }
                } catch {
                    print("Error with the data response received or decoded")
                    DispatchQueue.main.async {
                        completion (nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func downloadImage(img: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: img)
        
        guard let imageURL = url else {
            print("Issue with image URL  before downloadImage http request")
            DispatchQueue.main.async {
                completion(nil, nil)
            }
            return
        }
         
        let request = URLRequest(url: imageURL)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error response received with downloadImage http request")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
            if data != nil {
                print("Image data received with downloadImage http request")
                DispatchQueue.main.async {
                    completion(data, nil)
                }
            }
        }
        task.resume()
    }
}
