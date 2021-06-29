//
//  FrontHeadlinesView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 17-05-21.
//

import SwiftUI
//
//struct FrontHeadlinesView: View {
//    
//    @State var selection = 0
//    var tweets: [Tweet]
//    
//    
//    var body: some View {
//        GeometryReader { geo -> AnyView in
//            let offsetMin = geo.frame(in: .global).minY
//            let offset = offsetMin > 0 ? offsetMin : 0
//            
//            return AnyView(
//                TabView(selection: $selection) {
//                    ForEach(tweets.indices, id:\.self) { idx in
//                        HeadlineImageView(tweet: tweets[idx])
//                            .tag(idx)
//                            .id(idx)
//                    }
//                }.tabViewStyle(PageTabViewStyle())
//                .frame(height: 400 + offset)
//                .offset(y: -offset)
//            )
//        }.frame(height: 400)
//    }
//}
//
//struct FrontHeadlinesView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ScrollView {
//                FrontHeadlinesView(tweets: sampleTweets)
//            }.ignoresSafeArea()
//        }
//    }
//}
