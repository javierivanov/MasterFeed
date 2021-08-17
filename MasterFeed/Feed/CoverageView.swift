//
//  CoverageView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 22-07-21.
//

import SwiftUI
import UnsupervisedTextClassifier
import SwiftUIX
import LinkPresentation
import CoreServices
import BetterSafariView

struct CoverageView: View {
    var category: String
    var segment: SegmentResultGroup
    @EnvironmentObject var feedModel: FeedModel
    let imgSize = CGSize(width: 120, height: 120)
    var body: some View {
//        ScrollView {
//            VStack {
                let tweets = segment.resultGroup.map {$0.article as! Tweet}
                List {
//                    Text("\(segment.tokens.a.capitalized)")
                    ForEach(tweets) { tweet in
//                        HorizontalCardView(tweet: result)
                        CoverageInlineButtonView(tweet: tweet, imgSize: imgSize).padding([.horizontal], UIDevice.current.userInterfaceIdiom == .pad ? 150 : 0)

                    }
                    InternalCoverageView(currentTweets: tweets, coverage: Coverage(feedModel: feedModel)/*, correlationIndex: segment.correlationIndex*/)
                        .padding([.horizontal], UIDevice.current.userInterfaceIdiom == .pad ? 150 : 0)
                    
                }
                .navigationTitle("\(category)")
                .navigationBarTitleDisplayMode(.large)
//            }
            
//        }
    }
}


struct CoverageInlineView: View {
    
    var tweet: Tweet
    var imgSize: CGSize
    @State var unredact: Bool = false
    @State var title: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy"
    @State var uiImage: UIImage?
    var metadataProvider: CustomLPMetadataProvider = CustomLPMetadataProvider()
    
    var body: some View {
        HStack(alignment: .center) {
            
            Group {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
                } else {
                    AsyncImage<AnyView>(url: tweet.image, frameSize: imgSize)
                }
            }.frame(imgSize).cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(tweet.source ?? "").foregroundColor(.blue).bold()
                Text(formatter.localizedString(fromTimeInterval: Date().distance(to: (tweet.createdAt ?? Date())))).font(.caption)
                if !unredact && tweet.urlText == nil {
                    Text(tweet.urlText == nil ? title : tweet.text ?? "").font(.subheadline).lineLimit(2).redacted(reason: .placeholder)
                } else {
                    Text(tweet.urlText == nil ? title : tweet.text ?? "").font(.subheadline).lineLimit(5)
                }
            }.padding(.leading)
        }.onAppear {
            loadTweetRemoteContent(tweet, metadataProvider: metadataProvider, unredact: $unredact, title: $title, uiImage: $uiImage)
        }
    }
}


struct CoverageInlineButtonView: View {
    var tweet: Tweet
    var imgSize: CGSize
    @State var present: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        Button(action: {
            present.toggle()
        }, label: {
            CoverageInlineView(tweet: tweet, imgSize: imgSize)
        }).safariView(isPresented: $present) {
            SafariView(
                url: (tweet.url)!,
                configuration: SafariView.Configuration(
                    entersReaderIfAvailable: feedModel.defaultEasyReading,
                    barCollapsingEnabled: true
                )
            )
            .dismissButtonStyle(.done)
        }
        .contextMenu(menuItems: {
            ContextMenuView(tweet: tweet)
        })
    }
}

struct InternalCoverageView: View {
    
//    @EnvironmentObject var feedModel: FeedModel
    @StateObject var coverage: Coverage
//    var correlationIndex: Array<CorrelationResult>.Index
    var currentTweets: Set<String>
    var currentTweet: Tweet
    init(currentTweets: [Tweet], coverage: Coverage/*, correlationIndex: Array<CorrelationResult>.Index*/) {
        _coverage = StateObject(wrappedValue: coverage)
//        self.correlationIndex = correlationIndex
        self.currentTweets = Set(currentTweets.map(\.id))
        self.currentTweet = currentTweets.first!
    }
    let imgSize = CGSize(width: 120, height: 120)
    var body: some View {
        if coverage.loading {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    ProgressView("Checking similar stories...")
                    Spacer()
                }
            }.onAppear {
                coverage.computeCoverage(text: currentTweet.text!)
            }
        } else {
            ForEach(coverage.sortedArticles.filter {!currentTweets.contains($0.id)} ) { tweet in
                CoverageInlineButtonView(tweet: tweet, imgSize: imgSize)
            }
        }
    }
}

//struct CoverageView_Previews: PreviewProvider {
//    static var previews: some View {
//        CoverageView(correlation: CorrelationResult())
//    }
//}


class CustomLPMetadataProvider: LPMetadataProvider {
    var started: Bool = false
    override func startFetchingMetadata(for URL: URL, completionHandler: @escaping (LPLinkMetadata?, Error?) -> Void) {
        started = true
        super.startFetchingMetadata(for: URL, completionHandler: completionHandler)
    }
}
