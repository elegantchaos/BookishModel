// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

public class ImageCache<ImageClass> {
    let queue = DispatchQueue(label: "image-cache")
    public typealias ImageCallback = (ImageClass) -> Void
    
    public func image(for url: URL, callback: @escaping ImageCallback) {
        queue.async {
            do {
                let data = try Data(contentsOf: url)
                if let image: ImageClass = self.image(from: data) {
                    DispatchQueue.main.async {
                        callback(image)
                    }
                }
            } catch {
                print("failed to load image \(url)")
            }
        }
    }
    
    func image(from data: Data) -> ImageClass? {
        return nil
    }
}

#if os(iOS)

public class UIImageCache: ImageCache<UIImage> {
    override public init() {
    }
    
    override func image(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}

#endif

#if os(macOS)

public class NSImageCache: ImageCache<NSImage> {
    override public init() {
    }
    
    override func image(from data: Data) -> NSImage? {
        return NSImage(data: data)
    }
}

#endif
