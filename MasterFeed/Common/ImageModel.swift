//
//  ImageModel.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 19-05-21.
//

import Foundation
import Combine
import UIKit
import SwiftUI


struct CustomLinearGradient: View {
    var body: some View {
        let colors: [Color] = Array([.blue, .red, .orange, .yellow, .green].shuffled().prefix(2))
        let startPoint: UnitPoint = [.top, .topLeading, .topTrailing].randomElement()!
        let endPoint: UnitPoint = [.bottom, .bottomLeading, .bottomTrailing].randomElement()!
        LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
    }
}

struct AsyncImageLinearGradient: View {
    @StateObject private var loader: ImageLoader
    private let image: (UIImage) -> Image
    
    init(url: URL?, @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)) {
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        Group {
            if loader.image != nil {
                image(loader.image!).resizable()
            } else {
                CustomLinearGradient()
            }
        }
        .onAppear(perform: loader.load)
        .onDisappear(perform: loader.cancel)
    }
}

struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (UIImage) -> Image
    private var frameSize: CGSize?
    init(
        url: URL?,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    init(
        url: URL?,
        frameSize: CGSize,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        
        let colors: [Color] = Array([.blue, .red, .orange, .yellow, .green, .purple].shuffled().prefix(2))
        
        let startPoint: UnitPoint = [.top, .topLeading, .topTrailing].randomElement()!
        let endPoint: UnitPoint = [.bottom, .bottomLeading, .bottomTrailing].randomElement()!
        self.placeholder = LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint).eraseToAnyView() as! Placeholder
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
        
        self.frameSize = frameSize
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var content: some View {
        Group {
            if loader.image != nil {
                if let frameSize = frameSize {
                    image(loader.image!).resizable().aspectRatio(contentMode: .fill).frame(frameSize)
                } else {
                    image(loader.image!).resizable()
                }
            } else {
                placeholder.frame(frameSize)
            }
        }
    }
}

extension UIImage {
    public var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}


struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}


protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
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

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var avgColor: UIColor?
    
    private(set) var isLoading = false
    
    let url: URL?
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-queue", qos: .userInteractive)
    
    init(url: URL?, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard let url = url else {return}
        guard !isLoading else { return }
        if let image = cache?[url] {
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, _) -> (image:UIImage?, color:UIColor?) in
                let image = UIImage(data: data)
                //let color = image?.averageColor
                return (image, nil)
            }
            .replaceError(with: (nil, nil))
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0.image) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0.image; self?.avgColor = $0.color}
    }
    
    func cancel() {
        guard let cancellable = cancellable else { return }
        DispatchQueue
            .global(qos: .utility)
            .asyncAfter(deadline: .now()+2, execute: cancellable.cancel)
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        guard let url = url else {return}
        image.map { cache?[url] = $0 }
    }
}
