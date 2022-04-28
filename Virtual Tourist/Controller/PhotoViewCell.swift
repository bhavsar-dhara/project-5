//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-04-15.
//

import Foundation
import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoViewImage: UIImageView!
    
    static let reuseIdentifier = "PhotoCell"
    let sectionInsets = UIEdgeInsets(
      top: -5.0,
      left: -2.0,
      bottom: -5.0,
      right: -2.0)
    
//    let sectionInsets = UIEdgeInsets(
//      top: 50.0,
//      left: 20.0,
//      bottom: 50.0,
//      right: 20.0)
    
    func setPhoto(imageView: UIImage, sizeFit: Bool) {
        photoViewImage.image = imageView.withAlignmentRectInsets(sectionInsets)
        if sizeFit == true {
            photoViewImage.sizeToFit()
        }
    }
    
}
