//
//  ImagePresenterViewController.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/5/21.
//

import UIKit
import SDWebImage

class ImagePresenterViewController: UIViewController {
    //MARK: - Outlets & Variables
    @IBOutlet weak var presenterImageView: UIImageView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var imageModel : ImageEntity!
    let loadingIndicator = UIActivityIndicatorView()
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
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

//MARK: - Functions
extension ImagePresenterViewController{
    //MARK: - Initialize Loading Indicator
    fileprivate func initLoadingIndicator(){
        self.loadingIndicator.center = self.view.center
        self.view.addSubview(loadingIndicator)
    }
    //MARK: - Download Or Set Image To Image View
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
            self.presenterImageView.sd_setImage(with: url) { [weak self]image, error, cache, url in
                self?.loadingIndicator.stopAnimating()
                if error == nil{
                    debugPrint("Image Downloaded and Cached Successfuly")
                }else{
                    self?.showActionSheet(title: "", message: error?.localizedDescription ?? "error".Localized(), style: .alert, actions: [self?.actionMessageOK()])
                }
            }
        }
    }
    //MARK: - Set Image Date
    fileprivate func setDate(){
        DispatchQueue.main.async {
            self.dateLabel.text = self.imageModel.created_at
        }
    }
}
