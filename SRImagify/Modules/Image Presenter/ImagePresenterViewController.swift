//
//  ImagePresenterViewController.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/5/21.
//

import UIKit
import SDWebImage

class ImagePresenterViewController: UIViewController {
    
    @IBOutlet weak var imageScrollView: UIScrollView!{
        didSet{
            imageScrollView.delegate = self
            imageScrollView.minimumZoomScale = 0.5
            imageScrollView.maximumZoomScale = 6
            imageScrollView.alwaysBounceVertical = false
            imageScrollView.alwaysBounceHorizontal = false
            imageScrollView.showsVerticalScrollIndicator = false
            imageScrollView.flashScrollIndicators()
        }
    }
    @IBOutlet weak var presenterImageView: UIImageView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var imageModel : ImageModel!
    let loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLoadingIndicator()
        self.setDate()
        self.initImageView()

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.dateView.layer.cornerRadius = self.dateView.frame.height / 2
    }
    

}

extension ImagePresenterViewController{
    
    fileprivate func initLoadingIndicator(){
        imageScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        self.loadingIndicator.center = self.presenterImageView.center
        self.presenterImageView.addSubview(loadingIndicator)
    }
    
    fileprivate func initImageView(){
        self.loadingIndicator.startAnimating()
        guard let completeSize = self.imageModel.download_url else {return}
        let url = URL(string: completeSize)
        if let cached = SDImageCache.shared.imageFromDiskCache(forKey: url?.absoluteString){
            DispatchQueue.main.async {
                debugPrint("fetched offline")
                self.loadingIndicator.stopAnimating()
                self.presenterImageView.image = cached
            }
        }else{
            DispatchQueue.main.async {
                self.presenterImageView.sd_setImage(with: url) { image, errors, types, urls in
                    self.loadingIndicator.stopAnimating()
                }
            }
        }

    }
    
    fileprivate func setDate(){
        DispatchQueue.main.async {
            self.dateLabel.text = self.imageModel.created_at
        }
    }
}

extension ImagePresenterViewController : UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return presenterImageView
    }
}
