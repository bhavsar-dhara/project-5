//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-17.
//

import Foundation
import UIKit

class PhotoAlbumViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlickrAPIClient.getPhotosForSelectedLocation(latitude: 44.923639311481736, longitude: -93.32636418719535, pageNum: 1, completion: handlePhotosResponse(success:error:))
    }
    
    func handlePhotosResponse(success: [PhotoResponse]?, error: Error?) {
        print("handlePhotosResponse")
    }
}

//extension PhotoAlbumViewController: UICollectionViewController {
//
//    private let reuseIdentifier = "PhotoCell"
//
//    private let sectionInsets = UIEdgeInsets(
//      top: 50.0,
//      left: 20.0,
//      bottom: 50.0,
//      right: 20.0)
//}
