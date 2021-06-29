//
//  SwiftUIView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 19-05-21.
//

import SwiftUI

let formatter = RelativeDateTimeFormatter()

struct SwiftUIView: View {
    
    
    
    
    @State var image = "sample"
    var imgs = ["sample", "sample2", "sample3"]
    var body: some View {
        NavigationView {
            ScrollView  {
                TabView(selection: $image) {
                    ForEach(imgs.indices, id:\.self) { id in
                        SwiftUICardView(img: imgs[id])
                            .tag(imgs[id])
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 400)
            }
        }
    }
}

struct SwiftUICardView: View {
    
    var tweet: Tweet?
    var img: String?
    
    
    var colors: [Color] = Array([.blue, .red, .orange, .yellow, .green, .purple, .gray].shuffled().prefix(2))
    
    var startPoint: UnitPoint = [.top, .topLeading, .topTrailing].randomElement()!
    var endPoint: UnitPoint = [.bottom, .bottomLeading, .bottomTrailing].randomElement()!
    
    @EnvironmentObject var feedModel: FeedModel
    
    
    var body: some View {
        
        AsyncImage(url: /*tweet?.imageLarge*/nil, placeholder: {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
        })
        .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width-25, height: 400)
        .clipped()
        .overlay(
            AsyncImage(url: /*tweet?.imageLarge*/nil, placeholder: {
                LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
            })
            .blur(radius: 20, opaque: true)
            .overlay(Color.systemBackground.opacity(0.5))
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width-25, height: 400)
            .mask(Rectangle().padding(.top, 210))
            .clipped()
            .shadow(radius: 10), alignment: .bottom)
        .overlay(
            TextOverlay(tweet: tweet)
                .padding(.top, 225)
                .padding(.horizontal), alignment: .topLeading)
        .cornerRadius(15)
    }
}


struct TextOverlay: View {
    
    var tweet: Tweet?
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(tweet?.source ?? "@CNN").foregroundColor(.blue).bold()
                Text("•")
                Text(formatter.localizedString(for: tweet?.created_at ?? Date(), relativeTo: Date()))
                Text(tweet?.domains(from: feedModel.categories).joined(separator: ", ") ?? "").fontWeight(.bold)
            }.font(.caption).lineLimit(1)
            
            Text(tweet?.entities().joined(separator: ", ") ?? "sample line").lineLimit(1)//.bold().foregroundColor(.blue)
            
            Text(tweet?.text ?? "Sample Text")
                .font(.title3)
                .lineLimit(3)
                .padding(.bottom)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SwiftUIView().environment(\.colorScheme, .light).environmentObject(FeedModel())
        }
    }
}
