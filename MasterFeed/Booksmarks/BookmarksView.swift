//
//  BookmarksView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 14-06-21.
//

import SwiftUI
import CoreData
import BetterSafariView

struct BookmarksView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: StoredArticle.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \StoredArticle.timestamp, ascending: true)]
    ) var articles: FetchedResults<StoredArticle>
    
    @State var url: URL?
    @State var presented: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        List {
            ForEach(articles){ article in
                Button (action: {
                    presented = true
                }, label: {
                    BookmarkInlineView(article: article, imgSize: CGSize(width: 120, height: 120))
                }).safariView(isPresented: $presented, content: {
                    let tweet = article.tweet
                    return SafariView(
                        url: (tweet.url)!,
                        configuration: SafariView.Configuration(
                            entersReaderIfAvailable: feedModel.defaultEasyReading,
                            barCollapsingEnabled: true
                        )
                    )
                    .dismissButtonStyle(.done)
                })
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 150 : 0)
            }.onDelete(perform: { indexSet in
                for index in indexSet {
                    moc.delete(articles[index])
                }
                do {
                    try moc.save()
                } catch {
                    print("Unknown error")
                }
            })
        }
        .navigationTitle("Bookmarks")
    }
}


struct BookmarkInlineView: View {
    
    var article: StoredArticle
    var imgSize: CGSize
    @State var unredact: Bool = false
    @State var title: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy"
    @State var uiImage: UIImage?
    var metadataProvider: CustomLPMetadataProvider = CustomLPMetadataProvider()
    
    var body: some View {
        let tweet = article.tweet
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


struct SampleView: View {
    
    var article: StoredArticle
    let imgSize = CGSize(width: 120, height: 120)
    var body: some View {
        HStack {
            AsyncImage<AnyView>(url: article.imageURL, frameSize: imgSize).frame(imgSize).cornerRadius(10)
            VStack(alignment: .leading) {
                Text(article.source ?? "").foregroundColor(.blue).bold()
                Text(formatter.localizedString(fromTimeInterval: Date().distance(to: (article.timestamp ?? Date())))).font(.caption)
                Text(article.text ?? "").font(.title3)
            }.padding(.leading)
        }
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
    }
}
