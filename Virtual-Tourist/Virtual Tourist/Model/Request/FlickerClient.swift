//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import Foundation

class FlickerClient {
    
    static let apiKey = "6dbfc3a7af64568fe06795dfa3be200b"
    static let numberOfPhotosPerPage = 12
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?api_key=\(FlickerClient.apiKey)&&format=json&nojsoncallback=1&"
        case search(String)
        case getSource(String)
        
        var stringValue: String {
            switch self {
            case .search(let parameters):
                return Endpoints.base + "method=flickr.photos.search&per_page=\(FlickerClient.numberOfPhotosPerPage)&" + parameters
            case .getSource(let parameters):
                return Endpoints.base + "method=flickr.photos.getSizes&" + parameters
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func search(latitude: Double, longitude: Double, page: Int = 1, completion: @escaping (FlickerPhotoSearchResponse?, Error?) -> Void) {
        getRequest(url: Endpoints.search("lat=\(latitude)&lon=\(longitude)&page=\(page)").url, response: FlickerPhotoSearchResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getSource(photoID: String, completion: @escaping (FlickerGetSizesResponse?, Error?) -> Void) {
        getRequest(url: Endpoints.getSource("photo_id=\(photoID)").url, response: FlickerGetSizesResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let download = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        download.resume()
    }
    
    @discardableResult class func getRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, stripResonse: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()

            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(FlickerResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
}
