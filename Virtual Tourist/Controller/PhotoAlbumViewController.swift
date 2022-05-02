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
    var pin: Pin!
    var downloadedPhotos: [Photo] = []
    var photoResponse: [PhotoResponse] = []
    var cellsPerRow = 0
    var page: Int = 1
    var totalPages: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard pin != nil else {
            showAlert(title: "Can't load photo album", message: "Try Again!!")
            fatalError("No pin ")
        }
        totalPages = Int(pin.pages)
        setupCollectionView()
        
        // add activity indicator to main view
        self.view.addSubview(activityIndicator)
        
        downloadedPhotos = fetchFlickrPhotos()
        if !downloadedPhotos.isEmpty && downloadedPhotos.count > 0 {
            collectionView.reloadData()
        } else {
            downloadPhotoData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: UIButton action methods
    @IBAction func onPressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Load new photo collection UIButton action method
    @IBAction func loadNewCollection(_ sender: Any) {
        print("New Collection Button is pressed")
        newCollectionBtn.isEnabled = false
        if !downloadedPhotos.isEmpty {
            // assign random page# only if there are existing downloaded images
            page = Int.random(in: 1...totalPages)
        }
        clearPhotos()
        downloadedPhotos = []
        photoResponse = []
        print("randomPage == ", page)
        downloadPhotoData()
        collectionView.reloadData()
    }
    
    // MARK: Delete photo collection
    func clearPhotos() {
        for photo in downloadedPhotos {
            dataController.viewContext.delete(photo)
            do {
                try self.dataController.viewContext.save()
            } catch {
                self.showAlert(title: "Error", message: "There was an error clearing the collection")
            }
        }
    }
    
    // MARK: UI methods
    func showAlert(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    // MARK: fetching from core data and downloading from web methods for photos
    func fetchFlickrPhotos() -> [Photo] {
        showActivityIndicator()
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            downloadedPhotos = result
            hideActivityIndicator()
        } catch {
            showAlert(title: "Error", message: "There was an error retrieving photos")
            hideActivityIndicator()
        }
        return downloadedPhotos
    }
    
    func downloadPhotoData() {
        // manage activity indicator : start running
        showActivityIndicator()
        // call to fetch data from the Flickr API
        FlickrAPIClient.getPhotosForSelectedLocation(latitude: pin.latitude, longitude: pin.longitude, pageNum: page) { (photosRes, error) in
            if error != nil {
                print("handlePhotosResponse: ", error!)
                self.showAlert(title: "Error", message: "There was an error retrieving photos")
            }
            if photosRes != nil {
                print("handlePhotosResponse: ", photosRes!)
                let photos = photosRes?.photo
                let totalPages = photosRes?.pages
                self.totalPages = totalPages!
                let randomPage = Int.random(in: 1...totalPages!)
                self.page = randomPage
                print("randomPage = ", self.page)
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
                            self.downloadedPhotos.append(newPhoto)
                            do {
                                try self.dataController.viewContext.save()
                            } catch {
                                print("Unable to save the photo")
                            }
                        }
                        self.collectionView.reloadData()
                        print("All photos saved to on device")
                    }
                } else {
                    self.pin.pages = Int32(Int(totalPages!))
                    DispatchQueue.main.async {
                        self.newCollectionBtn.isEnabled = false
                    }
                }
            }
            // manage activity indicator : stop running
            self.hideActivityIndicator()
        }
    }
}

// MARK: UICollectionView (Delegate + DataSource)
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionView() {
        // Set up Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        newCollectionBtn.isEnabled = false
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.reuseIdentifier, for: indexPath as IndexPath) as! PhotoViewCell
         // fetch core data first
         let photoData = downloadedPhotos[indexPath.row]
         if photoData.image == nil {
             // run thread
             FlickrAPIClient.downloadImage(img: photoData.imageURL!.absoluteString) { (data, error) in
                 if (data != nil) {
                     DispatchQueue.main.async {
                         photoData.image = data
                         photoData.pin = self.pin
                         do {
                             try self.dataController.viewContext.save()
                         } catch {
                             print("There was an error saving photos")
                         }
                         DispatchQueue.main.async {
                             cell.photoViewImage?.image = UIImage(data: data!)
                         }
                     }
                 } else {
                     DispatchQueue.main.async {
                         self.showAlert(title: "Error", message: "There was an error downloading photos")
                     }
                     
                 }
                 DispatchQueue.main.async {
                     self.newCollectionBtn.isEnabled = true
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // print("onClick: ", indexPath)
        // delete from the core data
        dataController.viewContext.delete(downloadedPhotos[indexPath.item])
        do {
            try self.dataController.viewContext.save()
        } catch {
            self.showAlert(title: "Error", message: "There was an error clearing the collection")
        }
        // delete from the array variable
        downloadedPhotos.remove(at: indexPath.item)
        // delete from the view
        self.collectionView.deleteItems(at: [indexPath])
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
        return CGSize(width: size, height: size)
    }
    
    override func viewWillLayoutSubviews() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        if UIDevice.current.orientation == .portrait {
            cellsPerRow = 3
        } else {
            cellsPerRow = 5
        }
        flowLayout.invalidateLayout()
    }
}

// MARK: MKMapViewDelegate
extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            print("no mkpointannotaions")
            return nil
        }
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
