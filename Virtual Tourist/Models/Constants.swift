//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Mohammad Salhab on 7/2/20.
//  Copyright © 2020 Mohammad Salhab. All rights reserved.
//

import Foundation

extension API {
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let PhotoPage = "page"
        static let PhotosPerPage = "per_page"
        static let Accuracy = "accuracy"
    }
    
    struct  ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "cc1f245baadef5b124d1bdb261aa94bc"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_n"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = "20"
        static let Accuracy = "11"
    }
    
    struct BBox {
        static let HalfWidth = 0.5
        static let HalfHeight = 0.5
        static let LatRange = (-90.0, 90.0)
        static let LonRange = (-180.0, 180.0)
    }
}
