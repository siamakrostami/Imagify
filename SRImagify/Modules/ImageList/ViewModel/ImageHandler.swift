//
//  ImageHandler.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/3/21.
//

import Foundation
//MARK: - Typealias
typealias ImageHandlerCompletion = (([ImageModel]? , Error?) -> Void)
//MARK: - Class Protocols
protocol ImageHandlerProtocols{
    func fetchImages(completion : @escaping ImageHandlerCompletion)
}
//MARK: - Class Definition
class ImageHandler{
}
//MARK: - Class Extension
/// this function will fetch the images data from remote url
extension ImageHandler : ImageHandlerProtocols{
    func fetchImages(completion: @escaping ImageHandlerCompletion) {
        APIHandler.shared.request(url: NetworkConstants.sharedMediaUrl, expecting: [ImageModel].self) { result in
            switch result{
            case .success(let images):
                completion(images,nil)
            case .failure(let error):
                completion(nil,error)
            }
        }
    }
}
