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
        
        Group {
            if feedModel.state == .fetchingFeeds {
                ProgressView("Refreshing").frame(maxWidth: .infinity, alignment: .center)
            } else {
                CocoaList(feedModel.filterSegments(for: category), rowContent: { segment in
                    ExtractedView(resultGroup: segment.resultGroup, tokens: segment.tokens, url: $url, isPresented: $isPresentedWebView).frame(maxWidth: 700)
                }).listSeparatorStyle(.none)
            }
        }

        
        .environment(\.categoryValue, category)
        .navigationTitle(category)
        .background(Group {
            if let url = url {
                NavigationLink(
                    destination: SafariWebView(url: url, presented: $isPresentedWebView, readerMode: feedModel.defaultEasyReading)
                        .ignoresSafeArea()
                        .navigationBarHidden(true),
                    isActive: $isPresentedWebView,
                    label: {
                        EmptyView()
                    })
            } else {
                EmptyView()
            }
        })
        
//        .sheet(isPresented: $isPresentedWebView, content: {
//            SafariView(url: $url)
//        })
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
                VStack {
                    HStack {
                    Text(tokens.a.capitalized)
                        .bold()
                        .font(.title2)
                        .padding(3)
                        .backgroundFill(.accentColor)
                        .foregroundColor(.systemBackground)
                        .cornerRadius(5)
                    
                        Text(" and ").bold().italic()
                    
                    Text(tokens.b.capitalized)
                        .bold()
                        .font(.title2)
                        .padding(3)
                        .backgroundFill(.accentColor)
                        .foregroundColor(.systemBackground)
                        .cornerRadius(5)
                    
                    }.padding(.top)
                    
                    TopicCardsView(resultGroup: resultGroup, url: $url, isPresented: $isPresented, tokens: tokens)//.frame(height: 1000)
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0)
                .background(LinearGradient(gradient: Gradient(colors: [.systemBackground, Array<Color>([.blue, .red, .green, .orange]).shuffled().first!.opacity(0.1)]), startPoint: .top, endPoint: .bottom).cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 10 : 0))

            } else if resultGroup.count == 1 {
                
//                NavigationLink(
//                    destination: SafariWebView(url: ((resultGroup.first!.article as? Tweet)?.url!)!, presented: $selection).ignoresSafeArea().navigationBarHidden(true),
//                    tag: ((resultGroup.first!.article as? Tweet)?.url!.absoluteString)!,
//                    selection: $selection,
//                    label: {
//                        HorizontalCardView(tweet: resultGroup.first!.article as? Tweet)
//                    }).contextMenu {ContextMenuView(tweet: resultGroup.first!.article as? Tweet)}
                
                Button(action: {
                    url = (resultGroup.first!.article as? Tweet)?.url
                    isPresented = true
                }, label: {
                    HorizontalCardView(tweet: resultGroup.first!.article as? Tweet)
                })
                .contextMenu {ContextMenuView(tweet: resultGroup.first!.article as? Tweet)}
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0)

                
    //            Button(action: {
    //                isPresented = true
    //                url = (resultGroup.first!.article as! Tweet).url
    //            }, label: {
//                    SmallCardViewTopic(resultGroup: resultGroup.first!, url: $url, isPresented: $isPresented)//.contextMenu(menuItems: {ContextMenusView(tweet: resultGroup.first!.article as! Tweet)})
//                        .frame(height: 300)
    //            })
            }
//            else {
//                EmptyView()
//            }
        }
//        .background(Rectangle().foregroundColor(.secondarySystemBackground).cornerRadius(10)).padding(10)
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
