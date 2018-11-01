//
//  ImageLoader.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation
import UIKit
import SVGKit

final class ImageLoader {
    
    private static let cache = NSCache<NSString, NSData>()
    
    class func image(for urlString: String, completionHandler: @escaping(_ image: UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            if let data = self.cache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async { completionHandler(SVGKImage(data: data as Data)?.uiImage) }
                return
            }
            
            guard let data = NSData(contentsOf: url) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            self.cache.setObject(data, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async { completionHandler(SVGKImage(data: data as Data)?.uiImage) }
        }
    }
    
}

