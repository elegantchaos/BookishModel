// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public protocol ImageFactory {
    associatedtype ImageClass
    static func image(from data: Data) -> ImageClass?
}

public class ImageCache<Factory: ImageFactory> {
    let queue = DispatchQueue(label: "image-cache")
    public typealias ImageCallback = (Factory.ImageClass) -> Void
    
    public init() {
    }

    public func image(for url: URL, callback: @escaping ImageCallback) {
        queue.async {
            do {
                let data = try Data(contentsOf: url)
                if let image = Factory.image(from: data) {
                    DispatchQueue.main.async {
                        callback(image)
                    }
                }
            } catch {
                print("failed to load image \(url)")
            }
        }
    }
}

#if os(iOS)

import UIKit

extension UIImage: ImageFactory {
    public typealias ImageClass = UIImage
    
    public static func image(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}

public typealias UIImageCache = ImageCache<UIImage>

#endif

#if os(macOS)

import AppKit

extension NSImage: ImageFactory {
    public typealias ImageClass = NSImage
    
    public static func image(from data: Data) -> NSImage? {
        return NSImage(data: data)
    }
}

public typealias NSImageCache = ImageCache<NSImage>
#endif
