//
//  CardsView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 30-06-21.
//

import SwiftUI
import BetterSafariView

struct HorizontalCardView: View {
    
    var tweet: Tweet?
    @State var present: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {

        Button {
            present.toggle()
        } label: {
            HStack(alignment: .center, spacing: 0) {
                AsyncImageLinearGradient(url: tweet?.image)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .shadow(radius: 10)
                HorizontalHeadlineTextView(tweet: tweet)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 150)
            }
            .clipped()
            .background(CustomLinearGradient().overlay(Color.systemBackground.opacity(0.8)))
            .cornerRadius(10)
            .padding()
            .shadow(radius: 10)
        }.safariView(isPresented: $present, content: {
            SafariView(
                url: (tweet?.url)!,
                configuration: SafariView.Configuration(
                    entersReaderIfAvailable: feedModel.defaultEasyReading,
                    barCollapsingEnabled: true
                )
            )
            .dismissButtonStyle(.done)
        })
    }
}


struct VerticalCardView: View {
    
    var tweet: Tweet?
    var width: CGFloat = 170
    var height: CGFloat = 220
    
    @State var present: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        Button {
            present.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                AsyncImageLinearGradient(url: tweet?.image)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: 150).clipped()
                    .shadow(radius: 10)
                HorizontalHeadlineTextView(tweet: tweet)
                    .padding().frame(height: height)
            }
            .clipped()
            .background(CustomLinearGradient().overlay(Color.systemBackground.opacity(0.8)))
            .cornerRadius(10)
            .frame(width: width, height: 150 + height)
            .padding()
            .shadow(radius: 10)
        }.safariView(isPresented: $present, content: {
            SafariView(
                url: (tweet?.url)!,
                configuration: SafariView.Configuration(
                    entersReaderIfAvailable: feedModel.defaultEasyReading,
                    barCollapsingEnabled: true
                )
            )
            .dismissButtonStyle(.done)
        })
    }
}


struct LargeCardView: View {
    
    var tweet: Tweet?
    @State var present: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    
    var body: some View {
        
        Button {
            present.toggle()
        } label: {
            VStack(alignment: .center, spacing: 0) {
                GeometryReader { geo in
                    AsyncImageLinearGradient(url: tweet?.image)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: 300, alignment: .top)
                        .clipped()
                        .shadow(radius: 10)
                }
                HorizontalHeadlineTextView(tweet: tweet, largeFont: true)
                    .padding().frame(height: 150)
                    
            }
            .background(CustomLinearGradient().overlay(Color.systemBackground.opacity(0.8)))
            .frame(height: 450)
            .cornerRadius(10)
            .padding()
            .shadow(radius: 10)
        }.safariView(isPresented: $present, content: {
            SafariView(
                url: (tweet?.url)!,
                configuration: SafariView.Configuration(
                    entersReaderIfAvailable: feedModel.defaultEasyReading,
                    barCollapsingEnabled: true
                )
            )
            .dismissButtonStyle(.done)
        })

    }
}

struct BookmarkView: View {
    var tweet: Tweet?
    @FetchRequest var storedArticle: FetchedResults<StoredArticle>
    
    init(tweet: Tweet?) {
        _storedArticle = FetchRequest(entity: StoredArticle.entity(), sortDescriptors: [], predicate: NSPredicate(format: "url == %@", argumentArray: [tweet?.url ?? URL(string: "")!]))
    }
    
    var body: some View {
        Text(Image(systemName: storedArticle.isEmpty ? "bookmark" : "bookmark.fill")).bold()
    }
}

struct TopicsListView: View {
    
    var tweet: Tweet?
    
    var body: some View {
        HStack {
            if let tweet = tweet {
                ForEach(tweet.categories, id:\.self) { cat in
                    Text(cat)
                        .bold()
                        .padding(2)
                        .backgroundFill(.secondary)
                        .foregroundColor(.secondarySystemBackground)
                        .cornerRadius(5)
                        .font(.caption)
                    
                }
            } else {
                Text("Latest")
                    .bold()
                    .padding(2)
                    .backgroundFill(.secondary)
                    .foregroundColor(.secondarySystemBackground)
                    .cornerRadius(5)
                    .font(.caption)
            }
        }
    }
}


struct HorizontalHeadlineTextView: View {
    
    var tweet: Tweet?
    let formatter: RelativeDateTimeFormatter
    let largeFont: Bool
    
    init(tweet: Tweet?, largeFont: Bool = false) {
        self.tweet = tweet
        self.formatter = RelativeDateTimeFormatter()
        self.formatter.unitsStyle = .short
        self.largeFont = largeFont
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                //BookmarkView(tweet: tweet)
                Text(tweet?.source ?? "CNN")
                    .foregroundColor(.accentColor)
                    .bold()
                Spacer()
                Text(formatter.localizedString(for: tweet?.createdAt ?? Date(), relativeTo: Date())).foregroundColor(.primary)
                
            }
            .lineLimit(2)
            .font(.caption)
            .padding(.vertical, 5)
            
            TopicsListView(tweet: tweet)
//            Text("Latest").padding(5).background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(.blue)).font(.caption).foregroundColor(Color.systemBackground)
            
            Text((tweet?.text ?? "").isEmpty ? tweet?.urlText ?? "" : tweet?.text ?? "")
                .foregroundColor(.primary)
                .font(largeFont ? .title2 : .headline, weight: .bold)
                .padding(.top, 5)
        }
    }
}

struct ContextMenuView: View {
    
    var tweet: Tweet?
    
    @FetchRequest var storedArticle: FetchedResults<StoredArticle>
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var feedModel: FeedModel
    
    init(tweet: Tweet?) {
        self.tweet = tweet
        _storedArticle = FetchRequest(entity: StoredArticle.entity(), sortDescriptors: [], predicate: NSPredicate(format: "url == %@", argumentArray: [tweet?.url ?? URL(string: "")!]))
    }
    
    var body: some View {
        Group {
            
//            Image(systemName: storedArticle.isEmpty ? "bookmark" : "bookmark.fill")
            
            Button(action: saveBookmark) {
                if storedArticle.isEmpty {
                    Label("Save In Bookmarks", systemImage: "bookmark")
                } else {
                    Label("Remove From Bookmarks", systemImage: "bookmark.fill")
                }
                
            }
            
            Button(action: disableSource) {
                if isActiveSource() {
                    Label("Disbale Source", systemImage: "hand.thumbsdown")
                } else {
                    Label("Enable Source", systemImage: "hand.thumbsup")
                }
            }
        }
    }
    
    func saveBookmark() {
        if storedArticle.isEmpty {
            guard let tweet = tweet else { return }
            StoredArticle(context: moc).loadData(tweet: tweet)
            try? moc.save()
        } else {
            if let url = tweet?.url, let storedArticle = StoredArticle.withUrl(url, context: moc) {
                moc.delete(storedArticle)
                try? moc.save()
            }
        }
    }
    
    func isActiveSource() -> Bool {
        for (offset, sub) in feedModel.subscriptions.enumerated() {
            if sub.name == tweet?.source ?? "" {
                return feedModel.subscriptions[offset].active
            }
        }
        return false
    }
    
    func disableSource() {
        for (offset, sub) in feedModel.subscriptions.enumerated() {
            if sub.name == tweet?.source ?? "" {
                feedModel.subscriptions[offset].active.toggle()
                return
            }
        }
    }
}


struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalCardView(tweet: nil).previewLayout(.sizeThatFits)
        VerticalCardView(tweet: nil).previewLayout(.sizeThatFits)
        LargeCardView(tweet: nil).previewLayout(.sizeThatFits)
    }
}
