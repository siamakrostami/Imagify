//
//  ImageCollectionViewController.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/3/21.
//

import UIKit
import SDWebImage
import CoreData

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
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ImageEntity.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "size", ascending: true)]
        let resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        return resultController
    }()
    
    fileprivate var layout : UICollectionViewFlowLayout!
    static var optimizedHeight : CGFloat!
    static var optimizedWidth : CGFloat!
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addClearCacheButton()
        self.initialize()
    }
}

// MARK: - Class Extension
extension ImageCollectionViewController{
    
    // MARK: - Initialize Models & Variables
    fileprivate func initialize(){
        ImageCollectionViewController.optimizedWidth = ((self.imagesCollectionView.frame.width / 3) - 4).rounded()
        ImageCollectionViewController.optimizedHeight = ((self.imagesCollectionView.frame.width / 3) - 4).rounded()
        self.fetchImages()
    }
    // MARK: - Fetch Images
    fileprivate func fetchImages(){
        do{
            try self.fetchedhResultController.performFetch()
        }catch{
            self.showActionSheet(title: "", message: error.localizedDescription, style: .alert, actions: [self.actionMessageOK()])
        }
        APIHandler.shared.request(url: NetworkConstants.sharedMediaUrl) {[weak self] response in
            switch response{
            case .success(let images):
                debugPrint("Fetched Online")
                self?.clearCoreDataStack()
                if let imagesArray = images{
                self?.saveInCoreDataWith(dictionaryArray: imagesArray)
                }else{
                    self?.showActionSheet(title: "", message: "no-image-data".Localized(), style: .alert, actions: [self?.actionMessageRetry({
                        self?.fetchImages()
                    })])
                }
            case .failure(let error):
                self?.showActionSheet(title: "", message: error.localizedDescription, style: .alert, actions: [self?.actionMessageRetry({
                    self?.fetchImages()
                })])
                debugPrint(error)
            }
        }
    }
    //MARK: - Delete all data from CoreData
    fileprivate func clearCoreDataStack() {
            let context = CoreDataStack.shared.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ImageEntity.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                debugPrint("Deleted All Items")
                CoreDataStack.shared.saveContext()
            } catch let error {
                self.showActionSheet(title: "", message: error.localizedDescription, style: .alert, actions: [self.actionMessageOK()])
            }
    }
    //MARK: - Create Photo Entity
    fileprivate func createPhotoEntityFrom(dictionary: Dictionary<String,Any>) -> NSManagedObject?{
        let context = CoreDataStack.shared.persistentContainer.viewContext
        if let imageEntity = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: context) as? ImageEntity {
            imageEntity.id = dictionary["id"] as? String
            imageEntity.user_id = dictionary["user_id"] as? String
            imageEntity.media_type = dictionary["media_type"] as? String
            imageEntity.created_at = dictionary["created_at"] as? String
            imageEntity.taken_at = dictionary["taken_at"] as? String
            imageEntity.guessed_taken_at = dictionary["guessed_taken_at"] as? String
            imageEntity.md5sum = dictionary["md5sum"] as? String
            imageEntity.content_type = dictionary["content_type"] as? String
            imageEntity.video = dictionary["video"] as? String
            imageEntity.filename = dictionary["filename"] as? String
            imageEntity.thumbnail_url = dictionary["thumbnail_url"] as? String
            imageEntity.download_url = dictionary["download_url"] as? String
            imageEntity.size = dictionary["size"] as? Int64 ?? 0
            return imageEntity
        }
        return nil
    }
    //MARK: - Save Photo Entity
    fileprivate func saveInCoreDataWith(dictionaryArray: [Dictionary<String,Any>]) {
        _ = dictionaryArray.map{self.createPhotoEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.shared.persistentContainer.viewContext.save()
        } catch let error {
            self.showActionSheet(title: "", message: error.localizedDescription, style: .alert, actions: [self.actionMessageOK()])
        }
    }
    
    //MARK: - Clear SDImage Cache
    fileprivate func clearSDImageCache(){
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk {
            debugPrint("SDImageCache Deleted")
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
            self.clearCoreDataStack()
            self.clearSDImageCache()
            self.fetchImages()
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        })])
    }
}
//MARK: - UICollectionView Delegates
extension ImageCollectionViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else{return UICollectionViewCell()}
        guard let image = self.fetchedhResultController.object(at: indexPath) as? ImageEntity else{return UICollectionViewCell()}
        cell.setImageData(model: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = self.fetchedhResultController.object(at: indexPath) as? ImageEntity else{return}
        let presenterViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePresenterViewController") as! ImagePresenterViewController
        presenterViewController.imageModel = image
        self.navigationController?.pushViewController(presenterViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size : CGSize = CGSize(width: (collectionView.bounds.width / 3) - 8, height: collectionView.bounds.width / 3)
        return size
    }
}

//MARK: - NSFetchedResultController Delegate
extension ImageCollectionViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.imagesCollectionView.reloadData()
    }
}
