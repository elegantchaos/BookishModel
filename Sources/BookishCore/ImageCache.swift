// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

//class ImageFactory<ImageClass> {
//    class func image(from data: Data) -> ImageClass? {
//        return nil
//    }
//}

#if os(macOS)

import AppKit

#endif

#if os(iOS)

import UIKit

//extension ImageFactory where ImageClass == UIImage {
//    class func image(from data: Data) -> ImageClass? {
//         return UIImage(data: data)
//    }
//}

#endif

public class ImageCache<ImageClass> {
    let queue = DispatchQueue(label: "image-cache")
    public typealias ImageCallback = (ImageClass) -> Void
    
    public init() {
    }
    
    public func image(for url: URL, callback: @escaping ImageCallback) {
        queue.async {
            if let data = try? Data(contentsOf: url) {
                if let image: ImageClass = ImageCache.image(from: data) {
                    DispatchQueue.main.async {
                        callback(image)
                    }
                }
            }
        }
    }
    
    class func image(from data: Data) -> ImageClass? {
        return nil
    }
}

#if os(iOS)

extension ImageCache where ImageClass == UIImage {
    class func image(from data: Data) -> ImageClass? {
        return UIImage(data: data)
    }
}

#endif
