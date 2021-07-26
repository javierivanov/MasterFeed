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
import BetterSafariView

struct MainFeedView: View {
    
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        
        Group {
            if feedModel.state == .fetchingFeeds {
                ProgressView("Refreshing").frame(maxWidth: .infinity, alignment: .center)
            } else {
                CategoriesFeedView(segments: feedModel.segmentResults)
            }
        }
    }
}


struct CategoriesFeedView: View {
    
    
    var segments: [(category: String, segments: [SegmentResultGroup])]
    
    init(segments: [SegmentResultGroup]) {
        self.segments = segments.reduce(into: [:], {result, next in
            if let category = next.mainTweetCategory() {
                result[category, default: []].append(next)
            }
        })
        .sorted(by: {$0.value.count > $1.value.count})
        .map { key, value in (category: key, segments: value) }
        
    }
    
    var body: some View {
        CocoaList(segments.indices, id:\.self) { idx in
            CategorySegmentsView(segments: segments[idx])
        }.listSeparatorStyle(.none)
    }
}


struct CategorySegmentsView: View {
    
    var segments: (category: String, segments: [SegmentResultGroup])
    
    var body: some View {
        HStack {
            Text(segments.category).font(.title).bold()
            Spacer()
        }.padding(.horizontal)
        
        SegmentsView(segments: segments.segments, category: segments.category)
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
                LargeCardView(tweet: tweet)
                NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                    Text("\(segment.tokens.a.capitalized) and \(segment.tokens.b.capitalized)").blueFilledCaption()
                }).padding([.horizontal, .bottom])
            }
            LazyVGrid(columns: columns) {
                ForEach(segments[1..<computedGrid]) { segment in
                    VStack {
                        VerticalCardView(tweet: segment.resultGroup.bestResult() as? Tweet)
                        NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                            Text("\(segment.tokens.a.capitalized) and \(segment.tokens.b.capitalized)").blueFilledCaption()
                        }).padding([.horizontal, .bottom])
                    }
                }
            }
            if (segments.count - 1) % div != 0 {
                VStack {
                    let segment = segments.last!
                    HorizontalCardView(tweet: segment.resultGroup.bestResult() as? Tweet)
                    NavigationLink(destination: CoverageView(category: category, segment: segment), label: {
                        Text("\(segment.tokens.a.capitalized) and \(segment.tokens.b.capitalized)").blueFilledCaption()
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
            .font(.body, weight: .bold)
    }
}

extension View {
    func blueFilledCaption() -> some View {
        modifier(BlueFilledCaption())
    }
}


extension Array where Element == ResultGroup {
    func bestResult() -> Article? {
        self.min(by: {$0.similarity < $1.similarity})?.article
    }
}
