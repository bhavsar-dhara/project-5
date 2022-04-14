//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-17.
//

import Foundation
import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pin = pin else {
            showAlert(title: "Can't load photo album", message: "Try Again!!")
            fatalError("No pin ")
        }
        
        FlickrAPIClient.getPhotosForSelectedLocation(latitude: pin.latitude, longitude: pin.longitude, pageNum: 1, completion: handlePhotosResponse(success:error:))
    }
    
    func handlePhotosResponse(success: [PhotoResponse]?, error: Error?) {
        print("handlePhotosResponse")
    }
    
    @IBAction func OnPressTrash(_ sender: Any) {
        // removeSelectedImages()
        // dismiss(animated: true, completion: nil)
    }
    

    @IBAction func OnPressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
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
