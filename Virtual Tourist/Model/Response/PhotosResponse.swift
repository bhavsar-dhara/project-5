//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-16.
//

import Foundation

struct PhotosResponse: Codable {
    
    let page: Int
    let pages: Int // String
    let perpage: Int
    let total: Int // String
    let photo: [PhotoResponse]
}
