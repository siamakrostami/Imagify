//
//  RequestHandler.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/3/21.
//

import Foundation
//MARK: - Custom Error Enum
enum CustomError : Error{
    case invalidURL
    case invalidData
}
//MARK: - Class Protocols
protocol APIHandlerProtocols {
    func request<T:Codable>(url : URL?, expecting : T.Type , completion: @escaping ((Result<T,Error>) -> Void))
}
//MARK: - Class Definition
class APIHandler : URLSession {
}
//MARK: - Class Extension (URLSession Class)
extension URLSession : APIHandlerProtocols{
    //MARK: - Generic Function to fetch data from api
    func request<T>(url: URL?, expecting: T.Type, completion: @escaping ((Result<T, Error>) -> Void)) where T : Decodable, T : Encodable {
        guard let url = url else {
            completion(.failure(CustomError.invalidURL))
            return
        }
        let task = self.dataTask(with: url) { data, _, error in
            guard let data = data else {
                if let error = error{
                    completion(.failure(error))
                }else{
                    completion(.failure(CustomError.invalidData))
                }
                return
            }
            do{
                let results = try JSONDecoder().decode(expecting, from: data)
                completion(.success(results))
                
            }catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
 
}
