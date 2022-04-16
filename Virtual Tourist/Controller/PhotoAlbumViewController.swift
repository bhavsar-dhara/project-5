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
        guard pin != nil else {
            showAlert(title: "Can't load photo album", message: "Try Again!!")
            fatalError("No pin ")
        }
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
        setupFetchedResultsController()
        downloadPhotoData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
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
    
    // Setting up fetched results controller
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()

        // TODO - check if this filter is working
        if let pin = pin {
           let predicate = NSPredicate(format: "pin == %@", pin)
           fetchRequest.predicate = predicate

           print("Pin details = \(pin.latitude) \(pin.longitude)")
        }
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                             managedObjectContext: dataController.viewContext,
                                                             sectionNameKeyPath: nil, cacheName: "photo")
        fetchedResultsController.delegate = self
        print(fetchedResultsController.cacheName!)
        print(fetchedResultsController.fetchedObjects?.count ?? 0)

        do {
           try fetchedResultsController.performFetch()
        } catch {
           fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func downloadPhotoData() {
        // manage activity indicator : start running
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        print("\(String(describing: fetchedResultsController.fetchedObjects?.count))")
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            print("image metadata is already present. no need to re download")
            return
        }
        
        FlickrAPIClient.getPhotosForSelectedLocation(latitude: pin.latitude, longitude: pin.longitude, pageNum: 1) { (photosRes, error) in
            if error != nil {
                print("handlePhotosResponse: ", error!)
            }
            if photosRes != nil {
                print("handlePhotosResponse: ", photosRes!)
                let photos = photosRes?.photo
                let totalPages = photosRes?.pages
                
                let pagesCount = Int(self.pin.pages)
                
                if photos!.count > 0 {
                    DispatchQueue.main.async {
                        if (pagesCount == 0) {
                            self.pin.pages = Int32(Int(totalPages!))
                        }
                        for photo in photos! {
                            let newPhoto = Photo(context: self.dataController.viewContext)
                            newPhoto.imageURL = URL(string: photo.url)
                            newPhoto.image = nil
                            newPhoto.pin = self.pin
                            newPhoto.imageID = UUID().uuidString
                            do {
                                try self.dataController.viewContext.save()
                            } catch {
                                print("Unable to save the photo")
                            }
                        }
                        print("All photos saved to on device")
                    }
                }
                // manage activity indicator : stop running
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

// MARK: UICollectionView (Delegate + DataSource)
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func setupCollectionView() {
        // Set up Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        setupFlowLayout()
    }
    
    func setupFlowLayout() {
        // Set up the flow layout for the collection view
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
             let space:CGFloat = 3.0
             let dimension = (view.frame.size.width - (2 * space)) / 3.0
             flowLayout.minimumInteritemSpacing = space
             flowLayout.minimumLineSpacing = space
             flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.reuseIdentifier, for: indexPath as IndexPath) as! PhotoViewCell
         guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
             print("images are already present.")
             return cell
         }
     
         // fetch core data first
         let photoData = self.fetchedResultsController.object(at: indexPath)

         if photoData.image == nil {
             // run thread
             newCollectionBtn.isEnabled = false
             DispatchQueue.global(qos: .background).async {
                 if let image = try? Data(contentsOf: photoData.imageURL!) {
                     DispatchQueue.main.async {
                         photoData.image = image
                         do {
                             try self.dataController.viewContext.save()
                             
                         } catch {
                             print("error in saving image data")
                         }
                         let image = UIImage(data: image)!
                         cell.setPhoto(imageView: image, sizeFit: true)
                     }
                 }
             }
         } else {
           if let image = photoData.image {
                 let image = UIImage(data: image)!
                 cell.setPhoto(imageView: image, sizeFit: false)
             }
             
         }
         newCollectionBtn.isEnabled = true
         return cell
    }
}

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
