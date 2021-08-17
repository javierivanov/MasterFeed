//
//  CardsView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 30-06-21.
//

import SwiftUI
import BetterSafariView
import CoreServices
import NaturalLanguage
import Foundation



struct HorizontalCardView: View {
    
    var tweet: Tweet?
    @State var present: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    @State var unredact: Bool = false
    @State var title: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy"
    @State var uiImage: UIImage?
    var metadataProvider: CustomLPMetadataProvider = CustomLPMetadataProvider()
    
    var body: some View {

        Button {
            present.toggle()
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Group {
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage).resizable()
                    } else {
                        AsyncImageLinearGradient(url: tweet?.image)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipped()
                .shadow(radius: 10)
                HorizontalHeadlineTextView(tweet: tweet, largeFont: false, title: $title, unredact: $unredact)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 150)
            }
            .clipped()
            .background(CustomLinearGradient().overlay(Color.systemBackground.opacity(0.8)))
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
        .contextMenu(menuItems: {
            ContextMenuView(tweet: tweet)
        })
        .cornerRadius(10)
        .padding()
        .shadow(radius: 5)
        .onAppear {
            guard let tweet = tweet else {return}
            loadTweetRemoteContent(tweet, metadataProvider: metadataProvider, unredact: $unredact, title: $title, uiImage: $uiImage)
        }
    }
}


struct VerticalCardView: View {
    
    var tweet: Tweet?
    var width: CGFloat = 170
    var height: CGFloat = 220
    
    @State var present: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    
    @State var unredact: Bool = false
    @State var title: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy"
    @State var uiImage: UIImage?
    var metadataProvider: CustomLPMetadataProvider = CustomLPMetadataProvider()
    
    var body: some View {
        Button {
            present.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage).resizable()
                    } else {
                        AsyncImageLinearGradient(url: tweet?.image)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: 150).clipped()
                .shadow(radius: 10)
                HorizontalHeadlineTextView(tweet: tweet, largeFont: false, title: $title, unredact: $unredact)
                    .padding().frame(height: height)
            }
            .clipped()
            .background(CustomLinearGradient().overlay(Color.systemBackground.opacity(0.8)))
            .frame(width: width, height: 150 + height)
            
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
        .contextMenu(menuItems: {
            ContextMenuView(tweet: tweet)
        })
        .cornerRadius(10)
        .padding()
        .shadow(radius: 5)
        .onAppear {
            guard let tweet = tweet else { return }
            loadTweetRemoteContent(tweet, metadataProvider: metadataProvider, unredact: $unredact, title: $title, uiImage: $uiImage)
        }
    }
}


func loadTweetRemoteContent(_ tweet: Tweet, metadataProvider: CustomLPMetadataProvider, unredact: Binding<Bool>, title: Binding<String>, uiImage: Binding<UIImage?>) {
    
    var stringCache = Environment(\.stringCache).wrappedValue
    var imageCache = Environment(\.imageCache).wrappedValue
    
    if let cachedString = stringCache[tweet.url!] {
        withAnimation {
            unredact.wrappedValue = true
            title.wrappedValue = String(cachedString)
        }
    }
    if let cachedImage = imageCache[tweet.url!] {
        withAnimation {
            uiImage.wrappedValue = cachedImage
        }
    }
    
    guard imageCache[tweet.url!] == nil && stringCache[tweet.url!] == nil else { return }
    
    if !metadataProvider.started && tweet.urlText == nil {
        metadataProvider.timeout = 6
        metadataProvider.shouldFetchSubresources = true
        metadataProvider.startFetchingMetadata(for: tweet.url!) { meta, error in
                if let fetchedTitle = meta?.title {
                    withAnimation {
                        if !fetchedTitle.hasPrefix("Subscribe ") {
                            title.wrappedValue = fetchedTitle
                        } else {
                            title.wrappedValue = tweet.text ?? ""
                        }
                        stringCache[tweet.url!] = NSString(string: fetchedTitle)
                        unredact.wrappedValue = true
                    }
                    meta?.imageProvider?.loadDataRepresentation(forTypeIdentifier: kUTTypeImage as String, completionHandler: { data, error in
                        if let data = data {
                            withAnimation {
                                uiImage.wrappedValue = UIImage(data: data)
                                imageCache[tweet.url!] = uiImage.wrappedValue
                            }
                        }
                    })
                }
                if error != nil || meta?.title == nil {
                    
                    let text:String = tweet.text ?? ""
                    var sentence: String = ""
                    let tokenizer = NLTokenizer(unit: .sentence)
                    tokenizer.string = text
                    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
                        sentence.append(String(text[range]))
                        if sentence.split(separator: " ").count < 3 {
                            return true
                        }
                        return false
                    }
                    withAnimation {
                        title.wrappedValue = sentence
                        stringCache[tweet.url!] = NSString(string: title.wrappedValue)
                        unredact.wrappedValue = true
                    }
                }
            }
    }
}


struct LargeCardView: View {
    
    var tweet: Tweet?
    @State var present: Bool = false
    @EnvironmentObject var feedModel: FeedModel
    
    @State var unredact: Bool = false
    @State var title: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy"
    @State var uiImage: UIImage?
    var metadataProvider: CustomLPMetadataProvider = CustomLPMetadataProvider()
    
    var body: some View {
        
        Button {
            present.toggle()
        } label: {
            VStack(alignment: .center, spacing: 0) {
                GeometryReader { geo in
                    Group {
                        if let uiImage = uiImage {
                            Image(uiImage: uiImage).resizable()
                        } else {
                            AsyncImageLinearGradient(url: tweet?.image)
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: 300, alignment: .top)
                    .clipped()
                    .shadow(radius: 10)
                    
                }
                HorizontalHeadlineTextView(tweet: tweet, largeFont: true, title: $title, unredact: $unredact)
                    .padding().frame(height: 150)
                    
            }
            .background(CustomLinearGradient().overlay(Color.systemBackground.opacity(0.8)))
            .frame(height: 450)
            
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
        .contextMenu(menuItems: {
            ContextMenuView(tweet: tweet)
        })
        .cornerRadius(10)
        .padding()
        .shadow(radius: 5)
        .onAppear {
            guard let tweet = tweet else { return }
            loadTweetRemoteContent(tweet, metadataProvider: metadataProvider, unredact: $unredact, title: $title, uiImage: $uiImage)
        }

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
    let largeFont: Bool
    @Binding var title: String
    @Binding var unredact: Bool
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            _SourceTextView(tweet: tweet)
            _TextHeadlineView(tweet: tweet, title: $title, unredact: $unredact, largeFont: largeFont)
        }
    }
}

struct _TextHeadlineView: View {
    
    var tweet: Tweet?
    @Binding var title:String
    @Binding var unredact: Bool
    var largeFont: Bool

    var body: some View {
        Group {
            if !unredact && tweet?.urlText == nil {
                Text(tweet?.urlText == nil ? title : tweet?.text ?? "").lineLimit(2).redacted(reason: .placeholder)
            } else {
                Text(tweet?.urlText == nil ? title : tweet?.text ?? "").lineLimit(5)
            }
        }.foregroundColor(.primary)
        .font(largeFont ? .headline : .subheadline, weight: .semibold)
        .padding(.top, 5).fixedSize(horizontal: false, vertical: true)
        
    }

}

struct _SourceTextView: View {
    var tweet: Tweet?
    
    var body: some View {
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
