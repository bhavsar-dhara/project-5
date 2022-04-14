//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-17.
//
//  Reference https://www.raywenderlich.com/18895088-uicollectionview-tutorial-getting-started
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pin = pin else {
            showAlert(title: "Can't load photo album", message: "Try Again!!")
            fatalError("No pin ")
        }
        
        activityIndicator.startAnimating()
        
        FlickrAPIClient.getPhotosForSelectedLocation(latitude: pin.latitude, longitude: pin.longitude, pageNum: 1, completion: handlePhotosResponse(success:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
    }
    
    func handlePhotosResponse(success: [PhotoResponse]?, error: Error?) {
        print("handlePhotosResponse")
        if success != nil {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            print("handlePhotosResponse: ", success!)
        }
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

// MARK:
extension PhotoAlbumViewController {

   
}

// MARK: UICollectionView (Delegate + DataSource)
//extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // TODO
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        // TODO
//        return nil
//    }
//}

// MARK: NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                self.collectionView.insertItems(at: [newIndexPath!])
            case .delete:
                self.collectionView.deleteItems(at: [indexPath!])
            case .update:
                self.collectionView.reloadItems(at: [indexPath!])
            default:
                break
        }
    }
}

// MARK: MKMapViewDelegate
extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
         
        } else {
            pinView!.annotation = annotation
        }
        
        pinView?.isSelected = true
        pinView?.isUserInteractionEnabled = false
        return pinView
    }
    
    func setUpMapView() {
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta:  0.015, longitudeDelta: 0.015)
        let coordinate = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(MapModel(name: pin!.locationName!, latitude: pin!.latitude, longitude: pin!.longitude, country: pin!.country!, pin: pin!))
    }
}

