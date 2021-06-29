//
//  CardExperminentView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 04-06-21.
//

import SwiftUI

struct CardExperminentView: View {
    
    @StateObject private var loader: ImageLoader
    var tweet: Tweet?
    
    init(tweet: Tweet?) {
        _loader = StateObject(wrappedValue: ImageLoader(url: tweet?.imageLarge, cache: Environment(\.imageCache).wrappedValue))
        self.tweet = tweet
    }
    
    var colors: [Color] = Array([.blue, .red, .orange, .yellow, .green, .purple].shuffled().prefix(2))
    
    var startPoint: UnitPoint = [.top, .topLeading, .topTrailing].randomElement()!
    var endPoint: UnitPoint = [.bottom, .bottomLeading, .bottomTrailing].randomElement()!
    var maxWidth: CGFloat = UIScreen.main.bounds.width - 40
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ImageTopDisplay(image: loader.image, startPoint: startPoint, endPoint: endPoint, colors: colors, maxWidth: maxWidth)
            TextOverlayExperiment(tweet: tweet)
                .padding()
                .frame(minWidth: maxWidth)
                .background(ColorBackground(uiImage: loader.image, color: colors.last!))
                .shadow(radius: 20)
        }
        .frame(width: maxWidth, height: 350)
        .cornerRadius(10)
        .onAppear(perform: loader.load)
    }
}


struct ImageTopDisplay: View {
    
    var image: UIImage?
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    var colors: [Color]
    var maxWidth: CGFloat
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
//                                    Image("sample").resizable().aspectRatio(contentMode: .fill)
                LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
            }
        }
        .frame(minWidth: maxWidth)
        .clipped()
    }
}

struct ColorBackground: View {
    
    var uiImage: UIImage?
    var color: Color
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage).resizable().blur(radius: 60, opaque: true)
            } else {
                color
            }
        }.overlay(Color.systemBackground.opacity(0.6))
    }
}

struct TextOverlayExperiment: View {
    
    var tweet: Tweet?
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text(tweet?.source ?? "@CNN").foregroundColor(.blue).bold()
                    Text("•").bold()
                    Text(formatter.localizedString(for: tweet?.created_at ?? Date(), relativeTo: Date()))
                    Text(tweet?.domains(from: feedModel.categories).joined(separator: ", ") ?? "").fontWeight(.bold)
                }
                .font(.caption)
                .lineLimit(1)
                
                Text(tweet?.text ?? "Sample Text")
                    .lineLimit(5)
                    .font(.headline)
                    .padding(.bottom)
            }
            
            Spacer()
        }
    }
}

struct CardExperminentView_Previews: PreviewProvider {
    static var previews: some View {
        CardExperminentView(tweet: nil)
            .environmentObject(FeedModel())
            .preferredColorScheme(.light)
    }
}

