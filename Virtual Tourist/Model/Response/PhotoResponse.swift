//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-16.
//

import Foundation

struct PhotoResponse: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url: String
    let height: Int
    let width: Int
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
        case url = "url_m"
        case height = "height_m"
        case width = "width_m"
    }
    
}
