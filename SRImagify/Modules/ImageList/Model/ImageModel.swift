//
//  ImageModel.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/3/21.
//

import Foundation
import UIKit
//MARK: - Image Model
/// this model will cache in coreData
struct ImageModel : Codable{
    var id : String?
    var user_id : String?
    var media_type : String?
    var created_at : String?
    var taken_at : String?
    var guessed_taken_at : String?
    var md5sum : String?
    var content_type : String?
    var video : String?
    var filename : String?
    var thumbnail_url : String?
    var download_url : String?
    var size : Int64?
}

