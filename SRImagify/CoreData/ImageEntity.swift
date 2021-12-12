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
    
}



