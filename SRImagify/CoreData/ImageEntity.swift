//
//  ImageEntity.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/4/21.
//

import Foundation
import CoreData
import UIKit

//MARK: - CoreData Entity Class
public class ImageEntity:  NSManagedObject {
    
}
extension ImageEntity{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }
    @NSManaged public var id : String?
    @NSManaged public var user_id : String?
    @NSManaged public var media_type : String?
    @NSManaged public var created_at : String?
    @NSManaged public var taken_at : String?
    @NSManaged public var guessed_taken_at : String?
    @NSManaged public var md5sum : String?
    @NSManaged public var content_type : String?
    @NSManaged public var video : String?
    @NSManaged public var filename : String?
    @NSManaged public var thumbnail_url : String?
    @NSManaged public  var download_url : String?
    @NSManaged public var size : Int64
    
    static func convertDictionaryToModel(dictionary : Dictionary<String,Any>) -> ImageEntity{
        let imageObject = ImageEntity()
        imageObject.id = dictionary["id"] as? String
        imageObject.user_id = dictionary["user_id"] as? String
        imageObject.media_type = dictionary["media_type"] as? String
        imageObject.created_at = dictionary["created_at"] as? String
        imageObject.taken_at = dictionary["taken_at"] as? String
        imageObject.guessed_taken_at = dictionary["guessed_taken_at"] as? String
        imageObject.md5sum = dictionary["md5sum"] as? String
        imageObject.content_type = dictionary["content_type"] as? String
        imageObject.video = dictionary["video"] as? String
        imageObject.filename = dictionary["filename"] as? String
        imageObject.thumbnail_url = dictionary["thumbnail_url"] as? String
        imageObject.download_url = dictionary["download_url"] as? String
        imageObject.size = dictionary["size"] as? Int64 ?? 0
        return imageObject
    }
}



