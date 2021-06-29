//
//  CardSmallViewExperiment.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 04-06-21.
//

import SwiftUI

struct CardSmallViewExperiment: View {
    
    @StateObject private var loader: ImageLoader
    var tweet: Tweet?
    
    var colors: [Color] = Array([.blue, .red, .orange, .yellow, .green, .purple].shuffled().prefix(2))
    
    var startPoint: UnitPoint = [.top, .topLeading, .topTrailing].randomElement()!
    var endPoint: UnitPoint = [.bottom, .bottomLeading, .bottomTrailing].randomElement()!
    var maxWidth: CGFloat = UIScreen.main.bounds.width - 40
    
    
    init(tweet: Tweet?) {
        _loader = StateObject(wrappedValue: ImageLoader(url: tweet?.imageSmall, cache: Environment(\.imageCache).wrappedValue))
        self.tweet = tweet
    }
    
    var body: some View {
        ZStack {
            ImageBackgroundBlur(image: loader.image, colors: colors, startPoint: startPoint, endPoint: endPoint)
            Color.systemBackground.opacity(0.8)
            HStack(alignment: .top) {
                ImageSmallLeft(image: loader.image, colors: colors, startPoint: startPoint, endPoint: endPoint)
                TextOverlayDescriptor(tweet: tweet).padding(.top)
                Spacer()
            }
        }
        .frame(width: maxWidth, height: 130)
        .clipped()
        .cornerRadius(10.0)
        .padding()
        .onAppear(perform: loader.load)
    }
}

struct ImageSmallLeft: View {
    
    var image: UIImage?
    
    var colors: [Color]
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    
    var body: some View {
        Group {
            
            if let image = image {
                Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
            }
        }
        .frame(width: 130, height: 130)
        .clipped()
        .cornerRadius(10.0)
    }
}

struct ImageBackgroundBlur: View {
    var image: UIImage?
    
    var colors: [Color]
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 50, opaque: true)
            } else {
                LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
            }
        }
    }
}

struct CardSmallViewExperiment_Previews: PreviewProvider {
    static var previews: some View {
        CardSmallViewExperiment(tweet: nil).preferredColorScheme(.dark)
    }
}
