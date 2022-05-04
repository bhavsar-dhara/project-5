//
//  IndicatorCell.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-05-03.
//

import Foundation
import UIKit

class IndicatorCell: UICollectionViewCell {

    var loadingSpinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        return view
    }()
    
    static let reuseIdentifier = "IndicatorCell"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(loadingSpinner)
        loadingSpinner.bringSubviewToFront(self.contentView)
        loadingSpinner.center = self.contentView.center
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.startAnimating()
     }
}
