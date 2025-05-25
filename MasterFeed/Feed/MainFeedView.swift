////
////  MainFeedView.swift
////  MasterFeed
////
////  Created by Javier Fuentes on 12-05-21.
////
//
//import SwiftUI
//import UIKit
//import UnsupervisedTextClassifier
//
//
//struct MainFeedView: View {
//    
//    
//    @EnvironmentObject var feedModel: FeedModel
//    @Environment(\.colorScheme) var scheme
//    @State var isPresentedWebView = false
//    @State var url: URL?
//    
//    var formatter: DateFormatter {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .none
//        return dateFormatter
//    }
//    var category: String = "Latest"
//    
//    @Environment(\.safeAreaInsets) var safeAreaInsets // This should remain
//    
//    
//    var body: some View {
//        
//        Group {
//            if feedModel.state == .fetchingFeeds {
//                ProgressView("Refreshing").frame(maxWidth: .infinity, alignment: .center)
//            } else {
//                List(feedModel.filterSegments(for: category)) { segment in
//                    ExtractedView(resultGroup: segment.resultGroup, tokens: segment.tokens, url: $url, isPresented: $isPresentedWebView).frame(maxWidth: 700)
//                }.listSeparatorStyle(.none)
//            }
//        }
//        .environment(\.categoryValue, category)
//        .navigationTitle(category)
//        .navigationDestination(isPresented: $isPresentedWebView) {
//            if let validURL = url {
//                SafariWebView(url: validURL, presented: $isPresentedWebView, readerMode: feedModel.defaultEasyReading)
//                    .ignoresSafeArea()
//                    .navigationBarHidden(true)
//            } else {
//                EmptyView() 
//            }
//        }
//        
////        .sheet(isPresented: $isPresentedWebView, content: {
////            SafariView(url: $url)
////        })
//    }
//}
//
//struct MainFeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack { 
//            MainFeedView().environmentObject(FeedModel.sampleSubs())
//        }
//    }
//}
//
//
//struct ExtractedView: View {
//    
//    var resultGroup: [ResultGroup]
//    var tokens: (a: String, b: String)
////    @State var selection: Int = 0
//    @Binding var url: URL?
//    @Binding var isPresented: Bool
//    
//    var body: some View {
//        
//        VStack {
//            
//            if resultGroup.count > 1 {
//                VStack {
//                    HStack {
//                    Text(tokens.a.capitalized)
//                        .bold()
//                        .font(.title2)
//                        .padding(3)
//                        .background(.accent) 
//                        .foregroundColor(.systemBackground)
//                        .cornerRadius(5)
//                    
//                        Text(" and ").bold().italic()
//                    
//                    Text(tokens.b.capitalized)
//                        .bold()
//                        .font(.title2)
//                        .padding(3)
//                        .background(.accent) 
//                        .foregroundColor(.systemBackground)
//                        .cornerRadius(5)
//                    
//                    }.padding(.top)
//                    
//                    TopicCardsView(resultGroup: resultGroup, url: $url, isPresented: $isPresented, tokens: tokens)//.frame(height: 1000)
//                }
//                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0)
//                .background(LinearGradient(gradient: Gradient(colors: [.systemBackground, Array<Color>([.blue, .red, .green, .orange]).shuffled().first!.opacity(0.1)]), startPoint: .top, endPoint: .bottom).cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 10 : 0))
//
//            } else if resultGroup.count == 1 {
//                
//                Button(action: {
//                    url = (resultGroup.first!.article as? Tweet)?.url
//                    isPresented = true
//                }, label: {
//                    HorizontalCardView(tweet: resultGroup.first!.article as? Tweet)
//                })
//                .contextMenu {ContextMenuView(tweet: resultGroup.first!.article as? Tweet)}
//                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0)
//
//            }
//        }
//    }
//}
//
//// Removed SafeAreaInsetsKey struct
//
//// Removed EnvironmentValues extension for safeAreaInsets
//
//// Removed UIEdgeInsets extension for insets
//
//
//struct CategoryValueKey: EnvironmentKey {
//    static var defaultValue: String = "Latest"
//}
//
//
//extension EnvironmentValues {
//    var categoryValue: String {
//        get { self[CategoryValueKey.self] }
//        set { self[CategoryValueKey.self] = newValue }
//    }
//}
