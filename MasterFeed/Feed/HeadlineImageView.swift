//
//  HeadlineImageView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 17-05-21.
//

import SwiftUI
//import SwURL

//
//struct HeadlineImageView: View {
//    
//    
//    @State var cardSelection: Bool = false
//    @State var cardOpacity: Double = 0.0
//    
//    var tweet: Tweet
//    var body: some View {
//        
////        Image(uiImage: T##UIImage)
//        
//        AsyncImage(url: URL(string: (tweet.imageLarge?.url)!)!, placeholder: {Text("Loading")})
//            .aspectRatio(contentMode: .fill)
//            .frame(width: UIScreen.main.bounds.width)
//            .clipped()
//            .overlay(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
//            .overlay(TextOverlay(tweet: tweet), alignment: .bottom)
//            .overlay(
//                NavigationLink(destination: Text("Destination \(tweet.text ?? "")"),
//                               isActive: $cardSelection,
//                               label: {}))
//            .onTapGesture {
//                cardSelection = true
//            }
//            .overlay(Color.black.opacity(cardOpacity))
//            .onLongPressGesture(minimumDuration: 1, pressing: { pressing in
//                withAnimation {
//                    cardOpacity = pressing ? 0.4 : 0.0
//                }
//            }, perform: {})
//            
//            
//        
////        RemoteImageView(
////            url: URL(string: (tweet.imageLarge?.url)!)!,
////            placeholderImage: Image("sample")
////        ).imageProcessing({ image in
////            return image
////                .resizable()
////                .aspectRatio(contentMode: .fill)
////                .frame(width: UIScreen.main.bounds.width)
////        })
////        .clipped()
////        .overlay(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
////        .overlay(TextOverlay(tweet: tweet), alignment: .bottom)
////        .overlay(
////            NavigationLink(destination: Text("Destination \(tweet.text ?? "")"),
////                           isActive: $cardSelection,
////                           label: {}))
////        .onTapGesture {
////            cardSelection = true
////        }
////        .overlay(Color.black.opacity(cardOpacity))
////        .onLongPressGesture(minimumDuration: 1, pressing: { pressing in
////            withAnimation {
////                cardOpacity = pressing ? 0.4 : 0.0
////            }
////        }, perform: {})
////        .animation(nil)
//    }
//    
//}
////
//
//struct TextOverlay: View {
//    var tweet: Tweet?
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            
//            Text("#Hashtags:")
//                .foregroundColor(.white)
//            Text(tweet?.text ?? tweet?.urlTitle ?? "Headline not found!")
//                .foregroundColor(.white)
//                .font(.title3)
//            HStack {
//                Text(tweet?.source ?? "")
//                    .foregroundColor(.white)
//                    .font(.caption).fontWeight(.bold)
//                Text("•").foregroundColor(.white).font(.caption)
//                Text("1 min ago")
//                    .foregroundColor(.white)
//                    .font(.caption).fontWeight(.heavy)
//            }
//            
//        }.padding(.bottom, 40)
//    }
//}
//
//struct HeadlineImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ScrollView {
//                FrontHeadlinesView(tweets: sampleTweets)
//            }.ignoresSafeArea()
//        }
//    }
//}
