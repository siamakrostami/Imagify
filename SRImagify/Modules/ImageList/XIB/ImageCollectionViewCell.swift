//
//  ImageCollectionViewCell.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/3/21.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    //MARK: - Outlets & Variables
    @IBOutlet weak var fetchedImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fileSizeLabel: UILabel!
    static let identifier = "ImageCollectionViewCell"
    //MARK: - Override Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = self.containerView.frame.height / 2
    }
    //MARK: - Set Cell Data
    /// this function check the cache status of an image
    func setImageData(model : ImageModel){
        if let name = model.thumbnail_url{
            let url = URL(string: name)
            let width = String(Int(floor(ImageCollectionViewController.optimizedWidth)))
            let height = String(Int(floor(ImageCollectionViewController.optimizedHeight)))
            let finalURL = url?.appending("w", value: width)
                .appending("h", value: height)
            //Check if the image has been cached before
            // if cached, load it from disk
            if let cached = SDImageCache.shared.imageFromDiskCache(forKey: finalURL?.absoluteString){
                DispatchQueue.main.async {
                    debugPrint("fetched offline")
                    self.fetchedImageView.image = cached
                }
            }else{
                //Load Image from remote URL and cache it on disk
                DispatchQueue.main.async {
                    self.fetchedImageView.sd_setImage(with: finalURL)
                }
            }
        }
        if let size = model.size{
            self.fileSizeLabel.text = "\(Units(bytes: size).megabytes.rounded()) mb"
        }else{
            self.containerView.isHidden = true
        }
        
    }
    
}


