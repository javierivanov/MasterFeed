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



class ImageLoader: ObservableObject {
    @Published var image: UIImage?
//    @Published var avgColor: UIColor?
    
    private(set) var isLoading = false
    
    let url: URL?
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    //private static let imageProcessingQueue = DispatchQueue(label: "image-queue", qos: .background)
    
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
            DispatchQueue.main.async {
                self.image = image
            }
            return
        }
        onStart()
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { (data, _) -> UIImage? in
                let image = UIImage(data: data)
                //let color = image?.averageColor
                return image
            }
            .replaceError(with: nil)
            
//            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {[weak self] _ in
                self?.onFinish()
            }, receiveValue: { [weak self] image in
                self?.cache(image)
                DispatchQueue.main.async {
                    self?.image = image
                }
            })
            
    }
    
    func cancel() {
        guard let cancellable = cancellable else { return }
        DispatchQueue
            .global(qos: .utility)
            .asyncAfter(deadline: .now()+7, execute: cancellable.cancel)
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
