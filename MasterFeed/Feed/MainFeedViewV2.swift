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
import Combine
import BetterSafariView

struct MainFeedView: View {
    
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        
        Group {
            if feedModel.state == .fetchingFeeds {
                ProgressView("Refreshing").frame(maxWidth: .infinity, alignment: .center)
            } else {
                CategoriesFeedView()
            }
        }
        .navigationTitle("Feed")
    }
}




struct CategoriesFeedView: View {
    @EnvironmentObject var feedModel: FeedModel
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State var selectedTab: AppTabView.Tabs?
    var body: some View {
        
        Group {
            if feedModel.visibleCategories.isEmpty {
                
                
                if let clusters = feedModel.clusters, !clusters.isEmpty {
                    CocoaList(FeedModel.categoryList, id:\.self) { cat in
                        let idx = FeedModel.categoryListIndex[cat]!
                        let segments = feedModel.segmentResultsCategoryIndex[idx]
                        if segments.count > 0 {
                            SegmentsView(segments: segments, category: cat).maxWidth(650)
                        }
                    }
                    
                    .listSeparatorStyle(.none)
                    .hideNavigationBarIfAvailable()
                    .overlay(VStack {Rectangle().foregroundColor(.systemBackground).opacity(0.8).frame(maxWidth: .infinity).frame(height: safeAreaInsets.top);Spacer()}.ignoresSafeArea())
                } else {
                    VStack(alignment: .center, spacing: 10) {
                        Text("No sources available")
                        NavigationLink("Add Few Sources", destination: CategoriesView())
                        Button("Reload", action: {
                            feedModel.fetchSources()
                        })
                    }
                }
                
            } else {
                ProgressView("Computing \(feedModel.currentVisibleCategory ?? "")").padding()
            }
        }
    }
}



struct CategoryTitle: View {
    var category: String
    var colors: [Color] = [.pink, .blue, .green, .brown, .red, .yellow].shuffled()
    var body: some View {
        HStack {
            Text(category).font(.title, weight: .heavy)
                    .selfSizeMask(LinearGradient(gradient: Gradient(colors: Array(colors[0..<2])), startPoint: .topLeading, endPoint: .bottomTrailing))
            Spacer()
        }
         
    }
}

struct SegmentsView: View {
    
    var segments: [SegmentResultGroup]
    var category: String
    let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 0)), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
    let div = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
    var computedGrid: Int {
        let rest = (segments.count - 1) % div
        if rest == 0 {
            return segments.count
        } else {
            return segments.count - rest
        }
    }
    @State var presentation: Tweet?
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                let segment = segments.first!
                let tweet = segment.resultGroup.bestResult() as? Tweet
                CategoryTitle(category: category).padding([.horizontal, .top])
                LargeCardView(tweet: tweet)
                NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                    BlueTextView(text: "See More")
                }).padding([.horizontal, .bottom])
            }
            LazyVGrid(columns: columns) {
                ForEach(segments[1..<computedGrid]) { segment in
                    VStack {
                        VerticalCardView(tweet: segment.resultGroup.bestResult() as? Tweet)
                        NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                            BlueTextView(text: "See More")
                        }).padding([.horizontal, .bottom])
                    }
                }
            }
            if (segments.count - 1) % div != 0 {
                VStack {
                    let segment = segments.last!
                    HorizontalCardView(tweet: segment.resultGroup.bestResult() as? Tweet)
                    NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                        BlueTextView(text: "See More")
                    }).padding([.horizontal, .bottom])
                }
            }
        }
    }
}

struct SegmentsViewV2: View {
    
    var segments: [SegmentResultGroup]
    var category: String
    let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 0)), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
    let div = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
    var computedGrid: Int {
        let rest = (segments.count - 1) % div
        if rest == 0 {
            return segments.count
        } else {
            return segments.count - rest
        }
    }
    @State var presentation: Tweet?
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                let segment = segments.first!
                let tweet = segment.resultGroup.bestResult() as? Tweet
                CategoryTitle(category: category).padding([.horizontal, .top]).padding(.top)
                LargeCardView(tweet: tweet)
                NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                    BlueTextView(text: "See More")
                }).padding([.horizontal, .bottom])
            }
            LazyVGrid(columns: columns) {
                ForEach(segments[1..<computedGrid]) { segment in
                    VStack {
                        VerticalCardView(tweet: segment.resultGroup.bestResult() as? Tweet)
                        NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                            BlueTextView(text: "See More")
                        }).padding([.horizontal, .bottom])
                    }
                }
            }
            if (segments.count - 1) % div != 0 {
                VStack {
                    let segment = segments.last!
                    HorizontalCardView(tweet: segment.resultGroup.bestResult() as? Tweet)
                    NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                        BlueTextView(text: "See More")
                    }).padding([.horizontal, .bottom])
                }
            }
        }
    }
}

struct BlueButton: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(width: .greedy)
            .padding()
            .background(.accentColor)
            .cornerRadius(10)
            .font(.body, weight: .bold)
    }
}

struct BlueFilledCaption: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(width: .greedy)
            .padding()
            .background(.accentColor)
            .cornerRadius(10)
            .font(.body, weight: .medium)
    }
}

extension View {
    func blueFilledCaption() -> some View {
        modifier(BlueFilledCaption())
    }
}


extension Array where Element == ResultGroup {
    func bestResult() -> Article? {
        let bestMin = self.filter { result in
            let tweet = result.article as! Tweet
            return tweet.image != nil
        }.min { $0.similarity < $1.similarity }
        
        return bestMin?.article ?? self.min(by: {$0.similarity < $1.similarity})?.article
    }
}

extension View {
    func selfSizeMask<T: View>(_ mask: T) -> some View {
        ZStack {
            self.opacity(0)
            mask.mask(self)
        }.fixedSize()
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


struct BlueTextView: View {
    var text: String
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Text(Image(systemName: "chevron.right"))
        }.blueFilledCaption()
    }
}

struct SamplePreview: PreviewProvider {
    static var previews: some View {
        BlueTextView(text: "Sample Text")
    }
}
