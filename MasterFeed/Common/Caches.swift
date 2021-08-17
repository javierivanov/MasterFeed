//
//  Caches.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 29-07-21.
//

import Foundation
import UIKit
import SwiftUI

struct StringCacheKey: EnvironmentKey {
    static let defaultValue: StringCache = TemporaryStringCache()
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
    
    var stringCache: StringCache {
        get { self[StringCacheKey.self] }
        set { self[StringCacheKey.self] = newValue }
    }
}


protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

protocol StringCache {
    subscript(_ url: URL) -> NSString? { get set }
}


struct TemporaryStringCache: StringCache {
    private let cache: NSCache<NSURL, NSString> = {
        let cache = NSCache<NSURL, NSString>()
        cache.countLimit = 200
        cache.totalCostLimit = 1024 * 200
        return cache
    }()
    
    subscript(url: URL) -> NSString? {
        get { cache.object(forKey: url as NSURL) }
        set {
            guard let notNilNewValue = newValue else {
                cache.removeObject(forKey: url as NSURL)
                return
            }
            cache.setObject(notNilNewValue, forKey: url as NSURL)
        }
    }
    
}

struct TemporaryImageCache: ImageCache {
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}
