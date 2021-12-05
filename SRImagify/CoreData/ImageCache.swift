//
//  ImageCache.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/4/21.
//

import Foundation
import CoreData
import UIKit

//MARK: - Typealias
typealias InsertCompletion = ((Error?) -> Void)
typealias FetchAllCompletion = (([ImageModel]?,Error?) -> Void)
typealias FetchCompletion = ((ImageModel?,Error?) -> Void)
typealias UpdateCompletion = ((Error?) -> Void)
typealias DeleteCompletion = ((Error?) -> Void)
//MARK: - Protocols
protocol ImageCacheProtocols{
    func insertImageModelToDatabase(models : [ImageModel], completion: InsertCompletion)
    func fetchAllImageModels(completion: FetchAllCompletion)
    func fetchSelectedModel(model : ImageModel, completion: FetchCompletion)
    func deleteAllImageModels(completion: DeleteCompletion)
    func hasCacheData() -> Bool
    
}
//MARK: - Class Definition
class ImageCache : NSObject , NSCoding{
    let appDelgate = UIApplication.shared.delegate as! AppDelegate
    static let shared = ImageCache()
    //this keys are our coreData Entity model keys
    private let entity_key = "ImageEntity"
    fileprivate let id_key = "id"
    fileprivate let user_id_key = "user_id"
    fileprivate let media_type_key = "media_type"
    fileprivate let created_at_key = "created_at"
    fileprivate let taken_at_key = "taken_at"
    fileprivate let guessed_taken_at_key = "guessed_taken_at"
    fileprivate let md5sum_key = "md5sum"
    fileprivate let content_type_key = "content_type"
    fileprivate let video_key = "video"
    fileprivate let filename_key = "filename"
    fileprivate let thumbnail_url_key = "thumbnail_url"
    fileprivate let download_url_key = "download_url"
    fileprivate let size_key = "size"
    fileprivate var imageModel = ImageModel()
    
    override init(){}
    //encoding data
    func encode(with coder: NSCoder) {
        coder.encode(imageModel.id, forKey: id_key)
        coder.encode(imageModel.user_id, forKey: user_id_key)
        coder.encode(imageModel.media_type, forKey: media_type_key)
        coder.encode(imageModel.created_at, forKey: created_at_key)
        coder.encode(imageModel.taken_at, forKey: taken_at_key)
        coder.encode(imageModel.guessed_taken_at, forKey: guessed_taken_at_key)
        coder.encode(imageModel.md5sum, forKey: md5sum_key)
        coder.encode(imageModel.video, forKey: video_key)
        coder.encode(imageModel.filename, forKey: filename_key)
        coder.encode(imageModel.thumbnail_url, forKey: thumbnail_url_key)
        coder.encode(imageModel.download_url, forKey: download_url_key)
        coder.encode(imageModel.size, forKey: size_key)
    }
    //decoding data
    required init?(coder: NSCoder) {
        if let id = coder.decodeObject(forKey: id_key) as? String{
            imageModel.id = id
        }
        if let userId = coder.decodeObject(forKey: user_id_key) as? String{
            imageModel.user_id = userId
        }
        if let mediaType = coder.decodeObject(forKey: media_type_key) as? String{
            imageModel.media_type = mediaType
        }
        if let createdAt = coder.decodeObject(forKey: created_at_key) as? String{
            imageModel.created_at = createdAt
        }
        if let takenAt = coder.decodeObject(forKey: taken_at_key) as? String{
            imageModel.taken_at = takenAt
        }
        if let guessed = coder.decodeObject(forKey: guessed_taken_at_key) as? String{
            imageModel.guessed_taken_at = guessed
        }
        if let md5 = coder.decodeObject(forKey: md5sum_key) as? String{
            imageModel.md5sum = md5
        }
        if let video = coder.decodeObject(forKey: video_key) as? String{
            imageModel.video = video
        }
        if let filename = coder.decodeObject(forKey: filename_key) as? String{
            imageModel.filename = filename
        }
        if let thumbnailURL = coder.decodeObject(forKey: thumbnail_url_key) as? String{
            imageModel.thumbnail_url = thumbnailURL
        }
        if let downloadURL = coder.decodeObject(forKey: download_url_key) as? String{
            imageModel.download_url = downloadURL
        }
        if let size = coder.decodeObject(forKey: size_key) as? Int64{
            imageModel.size = size
        }
    }
}

//MARK: - CRUD Functions for CoreData
extension ImageCache : ImageCacheProtocols{
    //MARK: - Create
    func insertImageModelToDatabase(models: [ImageModel], completion:  InsertCompletion) {
        let context = appDelgate.persistentContainer.viewContext
        do{
            for model in models {
                let newImageModel = NSEntityDescription.insertNewObject(forEntityName: self.entity_key, into: context) as? ImageEntity
                newImageModel?.id = model.id
                newImageModel?.user_id = model.user_id
                newImageModel?.media_type = model.media_type
                newImageModel?.created_at = model.created_at
                newImageModel?.taken_at = model.taken_at
                newImageModel?.guessed_taken_at = model.guessed_taken_at
                newImageModel?.md5sum = model.md5sum
                newImageModel?.video = model.video
                newImageModel?.filename = model.filename
                newImageModel?.thumbnail_url = model.thumbnail_url
                newImageModel?.download_url = model.download_url
                newImageModel?.size = model.size ?? 0
                if newImageModel != nil{
                    context.insert(newImageModel!)
                }else{
                    return
                }
            }
            try context.save()
        }catch let error{
            completion(error)
        }
        completion(nil)
        
    }
    //MARK: - Read
    func fetchAllImageModels(completion:  FetchAllCompletion) {
        var imageModelsArray = [ImageModel]()
        let context = appDelgate.persistentContainer.viewContext
        let request : NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        do{
            let data = try context.fetch(request)
            imageModelsArray = self.castEntityToCustomModels(entity: data)
        }catch{
            completion(nil,error)
        }
        completion(imageModelsArray,nil)
        
    }
    
    func fetchSelectedModel(model: ImageModel, completion:  FetchCompletion) {
        var imageModel : ImageModel?
        let context = appDelgate.persistentContainer.viewContext
        let request : NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        do{
            var data = try context.fetch(request)
            let imagesArray = self.castEntityToCustomModels(entity: data)
            if imagesArray.contains(where: { ImageModel in
                model.id == ImageModel.id
            }){
                let index = imagesArray.firstIndex { image in
                    model.id == image.id
                }
                if index != nil{
                    imageModel = imagesArray[index!]
                    if imageModel != nil{
                        data[index!] = self.castModelToEntity(model: imageModel!)
                    }
                }
            }
        }catch{
            completion(nil,error)
        }
        completion(imageModel,nil)
    }
    //MARK: - Delete
    func deleteAllImageModels(completion:  DeleteCompletion) {
        let context = appDelgate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity_key)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            completion(error)
        }
        completion(nil)
    }
    //MARK: - Check Cache Data Existence
    func hasCacheData() -> Bool {
        let context = appDelgate.persistentContainer.viewContext
        let request : NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        do{
            let data = try context.fetch(request)
            if data.isEmpty{
                return false
            }else{
                return true
            }
        }catch{
            return false
        }
    }
    //MARK: - Cast CoreData Entity to Custom Model
    fileprivate func castEntityToCustomModels(entity : [ImageEntity]) -> [ImageModel]{
        var imageModelsArray = [ImageModel]()
        for item in entity{
            var model = ImageModel()
            model.id = item.id
            model.user_id = item.user_id
            model.media_type = item.media_type
            model.created_at = item.created_at
            model.taken_at = item.taken_at
            model.guessed_taken_at = item.guessed_taken_at
            model.md5sum = item.md5sum
            model.video = item.video
            model.filename = item.filename
            model.thumbnail_url = item.thumbnail_url
            model.download_url = item.download_url
            model.size = item.size
            imageModelsArray.append(model)
        }
        return imageModelsArray
    }
    //MARK: - Cast CustomModel to CoreData Entity
    fileprivate func castModelToEntity(model : ImageModel) -> ImageEntity{
        let entity = ImageEntity()
        entity.id = model.id
        entity.user_id = model.user_id
        entity.media_type = model.media_type
        entity.created_at = model.created_at
        entity.taken_at = model.taken_at
        entity.guessed_taken_at = model.guessed_taken_at
        entity.md5sum = model.md5sum
        entity.video = model.video
        entity.filename = model.filename
        entity.thumbnail_url = model.thumbnail_url
        entity.download_url = model.download_url
        entity.size = model.size ?? 0
        return entity
    }
    
}

