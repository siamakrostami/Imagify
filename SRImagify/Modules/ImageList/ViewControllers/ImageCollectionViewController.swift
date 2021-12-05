//
//  ImageCollectionViewController.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/3/21.
//

import UIKit
import SDWebImage

class ImageCollectionViewController: UIViewController {
    
    // MARK: - Outlets & Variables
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!{
        didSet{
            self.imagesCollectionView.delegate = self
            self.imagesCollectionView.dataSource = self
            self.imagesCollectionView.register(UINib(nibName: ImageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
            self.layout = UICollectionViewFlowLayout()
            self.layout.scrollDirection = .vertical
            self.imagesCollectionView.collectionViewLayout = self.layout
        }
    }
    
    fileprivate var layout : UICollectionViewFlowLayout!
    fileprivate var imageModels : [ImageModel]?
    fileprivate var imageHandler : ImageHandler!
    static var optimizedHeight : CGFloat!
    static var optimizedWidth : CGFloat!
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addClearCacheButton()
        self.initImageHandler()
    }
}

// MARK: - Class Extension
extension ImageCollectionViewController{
    
    // MARK: - Initialize Models & Variables
    fileprivate func initImageHandler(){
        ImageCollectionViewController.optimizedWidth = ((self.imagesCollectionView.frame.width / 3) - 4).rounded()
        ImageCollectionViewController.optimizedHeight = ((self.imagesCollectionView.frame.width / 3) - 4).rounded()
        self.imageHandler = ImageHandler()
        self.fetchImages()
    }
    // MARK: - Fetch Images
    /// this function will check the cache status, if data has been cached before, it will load it from cache
    /// but if the cache is empty, it will try to get them from remote url and cache them
    fileprivate func fetchImages(){
        if ImageCache.shared.hasCacheData(){
            debugPrint("Show Data From Cache")
            ImageCache.shared.fetchAllImageModels { images, error in
                if error == nil{
                    guard let images = images else{
                        return
                    }
                    self.imageModels = images
                    DispatchQueue.main.async {
                        self.imagesCollectionView.reloadData()
                    }
                }else{
                    self.showActionSheet(title: "", message: error?.localizedDescription ?? "error".Localized(), style: .alert, actions: [self.actionMessageOK()])
                }
            }
        }else{
            self.imageHandler.fetchImages { images, error in
                if error == nil{
                    debugPrint("Show Data From Remote")
                    guard let images = images else {
                        return
                    }
                    if self.imageModels == nil{
                        self.imageModels = [ImageModel]()
                    }
                    for item in images{
                        self.imageModels?.append(item)
                    }
                    if self.imageModels != nil{
                        ImageCache.shared.insertImageModelToDatabase(models: self.imageModels!) { error in
                            if error == nil{
                            }else{
                                self.showActionSheet(title: "", message: error?.localizedDescription ?? "error".Localized(), style: .alert, actions: [self.actionMessageOK()])
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.imagesCollectionView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showActionSheet(title: "", message: error?.localizedDescription ?? "error".Localized(), style: .alert, actions: [self.actionMessageOK()])
                    }

                }
            }
        }
    }
    //MARK: - Add BarButtonItem
    fileprivate func addClearCacheButton(){
        lazy var clearButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 110, height: 30))
        clearButton.setTitle("Clear Cache", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        clearButton.backgroundColor = .systemPink
        clearButton.tintColor = .white
        clearButton.layer.cornerRadius = 15
        clearButton.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearButton)
    }
    //MARK: - BarButtonItem Function
    /// this function will check the cache and try to remove it and fetch the data again from remote url
    @objc func clearCache(){
        self.showActionSheet(title: "", message: "clear-cache".Localized(), style: .alert, actions: [self.actionMessageCancel(),self.actionMessage("Clear Cache", style: .destructive, {
            if ImageCache.shared.hasCacheData(){
                ImageCache.shared.deleteAllImageModels { error in
                    if error == nil{
                        self.imageModels = nil
                        SDImageCache.shared.diskCache.removeAllData()
                        SDImageCache.shared.memoryCache.removeAllObjects()
                        DispatchQueue.main.async {
                            self.imagesCollectionView.reloadData()
                        }
                        self.fetchImages()
                    }else{
                        self.showActionSheet(title: "", message: error?.localizedDescription ?? "error".Localized(), style: .alert, actions: [self.actionMessageOK()])
                    }
                }
            }else{
                self.showActionSheet(title: "", message:"no-cache".Localized(), style: .alert, actions: [self.actionMessageOK()])
            }
        })])
    }
}
//MARK: - UICollectionView Delegates
extension ImageCollectionViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.imageModels != nil else{
            return 0
        }
        return self.imageModels!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else{return UICollectionViewCell()}
        guard let images = self.imageModels else{return UICollectionViewCell()}
        cell.setImageData(model: images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let images = self.imageModels else {return}
        let currentImage = images[indexPath.row]
        let presenterViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePresenterViewController") as! ImagePresenterViewController
        presenterViewController.imageModel = currentImage
        self.navigationController?.pushViewController(presenterViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size : CGSize = CGSize(width: (collectionView.bounds.width / 3) - 8, height: collectionView.bounds.width / 3)
        return size
    }
    
    
}

