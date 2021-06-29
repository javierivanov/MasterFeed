//
//  TwitterLoginSample.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 14-04-21.
//

//import SwiftUI
//
//struct ContentView3: View {
//  @EnvironmentObject var twitter: TwitterAuth
//
//  var body: some View {
//    VStack {
//        Button(action: { twitter.authorize() }) {
//        Text("Login with Twitter")
//      }
////      Text(twitter.credential?.userId ?? "")
////      Text(twitter.credential?.screenName ?? "")
//    }
//    .sheet(isPresented: self.$twitter.showSheet) {
//        if self.twitter.authUrl != nil {
////            WebView(url: authUrl)
//            SafariView(url: self.$twitter.authUrl)
//        } else {
//            ProgressView()
//        }
//
//    }
//  }
//}
//
//struct ContentView3_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView3().environmentObject(TwitterAuth())
//  }
//}
