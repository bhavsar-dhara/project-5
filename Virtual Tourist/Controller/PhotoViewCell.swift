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
    
    var loadingSpinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        debugPrint("commonInit")
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(loadingSpinner)
        loadingSpinner.bringSubviewToFront(self.contentView)
        loadingSpinner.center = self.contentView.center
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.startAnimating()
     }
    
    func setPhoto(imageView: UIImage, sizeFit: Bool) {
        loadingSpinner.stopAnimating()
        photoViewImage.image = imageView.withAlignmentRectInsets(sectionInsets)
        if sizeFit == true {
            photoViewImage.sizeToFit()
        }
    }
    
}
