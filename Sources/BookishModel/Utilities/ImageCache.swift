// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger
import CryptoKit
import CommonCrypto

let imageCacheChannel = Channel("com.elegantchaos.imageCache")

public protocol ImageFactory {
    associatedtype ImageClass
    static func image(from data: Data) -> ImageClass?
    static func image(named: String) -> ImageClass?
}

public class ImageCache<Factory: ImageFactory> {
    let queue = DispatchQueue(label: "image-cache")
    let cacheURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    public typealias ImageCallback = (Factory.ImageClass) -> Void
    
    public init() {
    }

    public func image(for url: URL, callback: @escaping ImageCallback) {
        queue.async {
            do {
                let localURL = self.localURL(for: url)
                if let image = self.load(cachedURL: localURL) ?? self.load(remoteURL: url, toLocalURL: localURL) {
                    DispatchQueue.main.async {
                        callback(image)
                    }
                } else {
                    print("failed to load image \(url)")
                }
            }
        }
    }
    
    private func load(cachedURL url: URL) -> Factory.ImageClass? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        guard let image = Factory.image(from: data) else {
            try? FileManager.default.removeItem(at: url)
            return nil
        }
        
        imageCacheChannel.log("loaded \(url.lastPathComponent) from cache")
        return image
    }
    
    private func load(remoteURL url: URL, toLocalURL: URL) -> Factory.ImageClass? {
        guard let data = try? Data(contentsOf: url), let image = Factory.image(from: data) else {
            return nil
        }

        do {
            try data.write(to: toLocalURL)
            imageCacheChannel.log("cached \(url.lastPathComponent) from cache")
        } catch {
            imageCacheChannel.log("couldn't cache \(url.lastPathComponent)\n\(error)")
        }
        
        return image
    }
    
    private func localURL(for imageURL: URL) -> URL {
        let imageCachedName = imageURL.absoluteString
        let imageCachedData = imageCachedName.data(using: .utf8)!
        let hashedName = CryptoKit.SHA256.hash(data: imageCachedData)
        let digest = hashedName.description
        let cachedImageURL = cacheURL.appendingPathComponent(digest)
        return cachedImageURL
    }
}

#if os(iOS)

import UIKit

public class UIImageFactory: ImageFactory {
    public typealias ImageClass = UIImage
    public static func image(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    public static func image(named name: String) -> UIImage? {
        return UIImage(named: name)
    }
}

public typealias UIImageCache = ImageCache<UIImageFactory>

#endif

#if os(macOS)

import AppKit

public class NSImageFactory: ImageFactory {
    public typealias ImageClass = NSImage
    public static func image(from data: Data) -> NSImage? {
        return NSImage(data: data)
    }
    public static func image(named name: String) -> NSImage? {
        return NSImage(named: name)
    }
}

public typealias NSImageCache = ImageCache<NSImageFactory>
#endif
