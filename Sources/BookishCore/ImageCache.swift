// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public protocol ImageFactory {
    associatedtype ImageClass
    static func image(from data: Data) -> ImageClass?
    static func image(named: String) -> ImageClass?
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

public class UIImageFactory: ImageFactory {
    public typealias ImageClass = UIImage
    public static func image(from data: Data) -> UIImage? {
        return UIImage(data: data)
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
