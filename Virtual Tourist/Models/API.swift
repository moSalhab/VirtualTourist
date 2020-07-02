//
//  API.swift
//  Virtual Tourist
//
//  Created by Mohammad Salhab on 6/26/20.
//  Copyright © 2020 Mohammad Salhab. All rights reserved.
//

import Foundation
import UIKit

//my api key: cc1f245baadef5b124d1bdb261aa94bc
class API {
    
    static func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLongitude = max(latitude  - API.BBox.HalfHeight, API.BBox.LatRange.0)
        let minimumLatitude = max(longitude - API.BBox.HalfWidth, API.BBox.LonRange.0)
        
        let maximumLongitude = min(latitude  + API.BBox.HalfHeight, API.BBox.LatRange.1)
        let maximumLatitude = min(longitude + API.BBox.HalfWidth, API.BBox.LonRange.1)
        
        return "\(minimumLatitude),\(minimumLongitude),\(maximumLatitude),\(maximumLongitude)"
    }
    
    class func getSearchResult(pin: Pin, completion: @escaping ([FlickrPhoto]?, Error?)->Void) {
        
        let boundingBox = API.bboxString(latitude: pin.lat, longitude: pin.long)
        
        let urlParameters =  [ParameterKeys.Method: ParameterValues.SearchMethod, ParameterKeys.APIKey: ParameterValues.APIKey, ParameterKeys.Extras: ParameterValues.MediumURL, ParameterKeys.Format: ParameterValues.ResponseFormat, ParameterKeys.SafeSearch: ParameterValues.UseSafeSearch, ParameterKeys.PhotosPerPage:  ParameterValues.PhotosPerPage, ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback, ParameterKeys.BoundingBox: boundingBox, ParameterKeys.PhotoPage: (String(Int.random(in: 1...10)))] as [String : AnyObject]

        let url = creatURL( (urlParameters ))
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Cannot connect.")
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(FlickrData.self, from: data!)
                DispatchQueue.main.async {
                    completion(responseObject.photos.photo, nil)
                }
            } catch {
                completion(nil, error)
                return
            }
        }
        task.resume()
    }
    
    class func creatURL(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func photoDownloader(imageURL: URL , pin: Pin, completion: @escaping (Data?, Error?)->Void) {
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            guard let data = data else {
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
}


struct FlickrData: Decodable {
    let photos: FlickrPhotos
}

struct FlickrPhotos: Decodable {
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Decodable {
    let url_n: String
}
