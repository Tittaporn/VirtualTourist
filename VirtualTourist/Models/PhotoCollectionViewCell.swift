//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imageURLPath: URL?
    
    func setImage(photo:Photo){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        guard let url = photo.url else {return}
        imageURLPath = url
        FlickrClient.shared.getPhotoImage(url: url) { [weak self] (image) in
            
            guard let self = self else {return}
            if self.imageURLPath == url{
                guard let imageUnwrapped = image else {return}
                self.imageView.image = imageUnwrapped
                photo.image = imageUnwrapped.jpegData(compressionQuality: 1)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }else{
                return
            }
            
        }
    }
    
}
