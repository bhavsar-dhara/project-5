//
//  BaseViewController.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-05-02.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {

    // MARK: Properties
    var myIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up activity indicator
        myIndicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.large)
        self.view.addSubview(myIndicator)
        myIndicator.bringSubviewToFront(self.view)
        myIndicator.center = self.view.center
    }
    
    // MARK: Helper functions to show and hide activity indicators
    func showActivityIndicator() {
        myIndicator.isHidden = false
        myIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        myIndicator.stopAnimating()
        myIndicator.isHidden = true
    }

    // MODIFICATION
    // MARK: Alert helper function
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
