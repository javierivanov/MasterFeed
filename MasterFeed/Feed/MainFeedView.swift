//
//  MainFeedView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 12-05-21.
//

import SwiftUI
import UIKit
import UnsupervisedTextClassifier
import SwiftUIX


struct MainFeedView: View {
    
    
    @EnvironmentObject var feedModel: FeedModel
    @Environment(\.colorScheme) var scheme
    @State var isPresentedWebView = false
    @State var url: URL?
    var formatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
    var category: String = "Latest"
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    
    var body: some View {
        
        CocoaList(feedModel.filterSegments(for: category), rowContent: { segment in
            ExtractedView(resultGroup: segment.resultGroup, tokens: segment.tokens, url: $url, isPresented: $isPresentedWebView)
        }).listSeparatorStyle(.none)
        
//        ScrollView {
//            LazyVStack {
//                ForEach(feedModel.filterSegments(for: category)) { segment in
////                    SmallCardViewTopic(resultGroup: segment.resultGroup.first!, url: $url, isPresented: $isPresentedWebView)
//                    ExtractedView(resultGroup: segment.resultGroup, tokens: segment.tokens, url: $url, isPresented: $isPresentedWebView)
//                }
//            }
//        }
        .environment(\.categoryValue, category)
        .navigationTitle(category)
        .sheet(isPresented: $isPresentedWebView, content: {
            SafariView(url: $url)
        })
    }
}

struct MainFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainFeedView().environmentObject(FeedModel.sampleSubs())
        }
    }
}


struct ExtractedView: View {
    
    var resultGroup: [ResultGroup]
    var tokens: (a: String, b: String)
//    @State var selection: Int = 0
    @Binding var url: URL?
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack {
            
            if resultGroup.count > 1 {
                HStack {
                Text(tokens.a.capitalized)
                    .bold()
                    .font(.title2)
                    .padding(3)
                    .backgroundFill(.accentColor)
                    .foregroundColor(.systemBackground)
                    .cornerRadius(5)
                
                    Text("+").bold()
                
                Text(tokens.b.capitalized)
                    .bold()
                    .font(.title2)
                    .padding(3)
                    .backgroundFill(.accentColor)
                    .foregroundColor(.systemBackground)
                    .cornerRadius(5)
                
                }.padding(.top)
                
                TopicCardsView(resultGroup: resultGroup, url: $url, isPresented: $isPresented, tokens: tokens).frame(height: 1000)

            } else if resultGroup.count == 1 {
    //            Button(action: {
    //                isPresented = true
    //                url = (resultGroup.first!.article as! Tweet).url
    //            }, label: {
                    SmallCardViewTopic(resultGroup: resultGroup.first!, url: $url, isPresented: $isPresented)//.contextMenu(menuItems: {ContextMenusView(tweet: resultGroup.first!.article as! Tweet)})
                        .frame(height: 300)
    //            })
            }
//            else {
//                EmptyView()
//            }
        }.background(Rectangle().foregroundColor(.secondarySystemBackground).cornerRadius(10)).padding(10)
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}


struct CategoryValueKey: EnvironmentKey {
    static var defaultValue: String = "Latest"
}


extension EnvironmentValues {
    var categoryValue: String {
        get { self[CategoryValueKey.self] }
        set { self[CategoryValueKey.self] = newValue }
    }
}
