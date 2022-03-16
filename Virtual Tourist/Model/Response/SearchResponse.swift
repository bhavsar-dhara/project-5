//
//  SearchResponse.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-16.
//

import Foundation

struct SearchResponse: Codable {
    
    let photos: PhotosResponse
    let stat: String
    
}
