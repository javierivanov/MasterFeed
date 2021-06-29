//
//  TopicCardsView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-06-21.
//

import SwiftUI
import CoreData
import UnsupervisedTextClassifier

struct TopicCardsView: View {
    
    var resultGroup: [ResultGroup]
    
    var computedGrid: Int {
        if (resultGroup.count - 1) % 2 == 0 {
            return resultGroup.count
        } else {
            return resultGroup.count - 1
        }
    }
    
    //    var width: CGFloat {
    //        UIScreen.main.bounds.width - 60
    //    }
    
    @Binding var url: URL?
    @Binding var isPresented: Bool
    
    var tokens: (a: String, b: String)
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    var body: some View {
        VStack(alignment: .leading) {
            LargeCardViewTopic(resultGroup: resultGroup.first!, url: $url, isPresented: $isPresented)
            LazyVGrid(columns: columns) {
                ForEach(resultGroup[1..<computedGrid]) { result in
                    SmallGridViewTopic(resultGroup: result, url: $url, isPresented: $isPresented)
                }
            }
            if (resultGroup.count - 1) % 2 != 0 {
                SmallCardViewTopic(resultGroup: resultGroup.last!, url: $url, isPresented: $isPresented)
            }
        }
        .padding(.vertical)
    }
}

struct LargeCardViewTopic: View {
    
    var resultGroup: ResultGroup?
    @Binding var url: URL?
    @Binding var isPresented: Bool
    var body: some View {
        VStack(alignment: .center) {
            Button {
                isPresented = true
                url = (resultGroup?.article as! Tweet).url
            } label: {
                Image("sample").resizable()
//                                    AsyncImage<AnyView>(url: (resultGroup?.article as! Tweet).imageLarge,frameSize: CGSize(width: UIScreen.main.bounds.width-50, height: 300))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width-50, height: 300)
                    .cornerRadius(10)
            }.shadow(radius: 10)
            
            HeadlineTextLargeView(resultData: resultGroup, spacing: 10, url: $url, isPresented: $isPresented)
                .frame(maxWidth: UIScreen.main.bounds.width-50)
        }.padding()
    }
}

struct SmallGridViewTopic: View {
    
    var resultGroup: ResultGroup?
    @Binding var url: URL?
    @Binding var isPresented: Bool
    
    var width: CGFloat {
        UIScreen.main.bounds.width - 90
    }
    
    var body: some View {
        VStack {
            Button {
                isPresented = true
                url = (resultGroup?.article as! Tweet).url
            } label: {
                Image("sample").resizable()
//                                    AsyncImage<AnyView>(url: (resultGroup?.article as! Tweet).imageSmall, frameSize: CGSize(width: (width)/2, height: 150))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: (width)/2, height: 150)
                    .clipped()
                    .cornerRadius(10)
            }.shadow(radius: 10)
            
            HeadlineTextSmallView(resultData: resultGroup, url: $url, isPresented: $isPresented)
            Spacer()
        }
        .frame(width: width/2, height: 320)
        .padding()
    }
}

struct SmallCardViewTopic: View {
    var resultGroup: ResultGroup?
    @Binding var url: URL?
    @Binding var isPresented: Bool
    var width: CGFloat {
        UIScreen.main.bounds.width - 60
    }
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button {
                isPresented = true
                url = (resultGroup?.article as! Tweet).url
            } label: {
//                                AsyncImage<AnyView>(url: (resultGroup?.article as! Tweet).imageSmall, frameSize: CGSize(width: 150, height: 150))
                Image("sample").resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(10)
                
            }.shadow(radius: 10)
            
            HeadlineTextSmallView(resultData: resultGroup, url: $url, isPresented: $isPresented).padding(.leading)
            Spacer()
        }
        .frame(height: 150)
        .padding()
    }
}

struct SamplePreview: PreviewProvider {
    static var previews: some View {
        SmallCardViewTopic(resultGroup: nil, url: .constant(nil), isPresented: .constant(true)).previewLayout(.sizeThatFits)
        LargeCardViewTopic(resultGroup: nil, url: .constant(nil), isPresented: .constant(true)).previewLayout(.sizeThatFits)
        SmallGridViewTopic(resultGroup: nil, url: .constant(nil), isPresented: .constant(true)).previewLayout(.sizeThatFits)
        
    }
}



struct HeadlineTextLargeView: View {
    
    var resultData: ResultGroup?
    var spacing: CGFloat = 5
    let formatter = RelativeDateTimeFormatter()
    
    @Binding var url: URL?
    @Binding var isPresented: Bool
    
    var body: some View {
        let tweet: Tweet? = resultData?.article as? Tweet
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: spacing) {
                Text(tweet?.source ?? "CNN").foregroundColor(.blue).bold()
                Text("•")
                Text(formatter.localizedString(for: tweet?.created_at ?? Date(), relativeTo: Date())).bold().foregroundColor(.primary.opacity(0.7))
                TopicsListView(tweet: tweet)
                Spacer()
                //button
                BookmarksButtonView(tweet: tweet, storedArticle: FetchRequest(entity: StoredArticle.entity(), sortDescriptors: [], predicate: NSPredicate(format: "url == %@", argumentArray: [tweet!.url!])))
            }.font(.caption)
            
            Button {
                url = tweet?.url
                isPresented = true
            } label: {
                Text(tweet?.text ?? "Supreme Court Rules for High School Cheerleader Punished Over Snapchat Rant")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .lineLimit(5)
                    .frame(height: 90)
            }
        }
    }
}


struct HeadlineTextSmallView: View {
    
    var resultData: ResultGroup?
    var spacing: CGFloat = 5
    let formatter = RelativeDateTimeFormatter()
    
    @Binding var url: URL?
    @Binding var isPresented: Bool
    
    var body: some View {
        let tweet: Tweet? = resultData?.article as? Tweet
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                VStack(alignment: .leading) {
                    Text(tweet?.source ?? "CNN").foregroundColor(.blue).bold()
                    Text(formatter.localizedString(for: tweet?.created_at ?? Date(), relativeTo: Date())).bold()
                        .foregroundColor(.primary.opacity(0.7))
                }.font(.caption)
                Spacer()
                BookmarksButtonView(tweet: tweet, storedArticle: FetchRequest(entity: StoredArticle.entity(), sortDescriptors: [], predicate: NSPredicate(format: "url == %@", argumentArray: [tweet!.url!])))
            }
            
            HStack {
                TopicsListView(tweet: tweet)
            }
            .font(.caption)
            .padding(.vertical, 2)
            
            
            Button {
                url = tweet?.url
                isPresented = true
            } label: {
                Text(tweet?.text ?? "Supreme Court Rules for High School Cheerleader Punished Over Snapchat Rant")
                    .foregroundColor(.primary)
                    .lineLimit(5)
                    .frame(height: 90)
            }
        }
    }
}



struct BookmarksButtonView: View {
    var tweet: Tweet?
    @FetchRequest var storedArticle: FetchedResults<StoredArticle>
    @Environment(\.managedObjectContext) var moc
    var body: some View {
        Button(action: {
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
        }, label: {
            Text(Image(systemName: storedArticle.isEmpty ? "bookmark" : "bookmark.fill")).foregroundColor(.primary).font(.title2)
        })
    }
}



struct TopicsListView: View {
    
    var tweet: Tweet?
    
    var body: some View {
        if let tweet = tweet {
            ForEach(tweet.categories, id:\.self) { cat in
                
                if Environment(\.categoryValue).wrappedValue == cat {
                    Text(cat)
                        .bold()
                        .padding(3)
                        .backgroundFill(.secondary)
                        .foregroundColor(.secondarySystemBackground)
                        .cornerRadius(5)
                } else {
                    NavigationLink(destination: MainFeedView(category: cat), label: {
                        Text(cat)
                            .bold()
                            .padding(3)
                            .backgroundFill(.secondary)
                            .foregroundColor(.secondarySystemBackground)
                            .cornerRadius(5)
                    })
                }
                
            }
        } else {
            Text("Sample")
                .bold()
                .padding(3)
                .backgroundFill(.secondary)
                .foregroundColor(.secondarySystemBackground)
                .cornerRadius(5)
        }
    }
}

struct TopicCardsView_Previews: PreviewProvider {
    static var previews: some View {
        
        TopicCardsView(resultGroup: [], url: .constant(nil), isPresented: .constant(true), tokens: ("", "")).preferredColorScheme(.light).environmentObject(FeedModel())
    }
}

extension StoredArticle {
    func loadData(tweet: Tweet) {
        url = tweet.url
        imageURL = tweet.imageSmall
        text = tweet.text
        source = tweet.source
        id = UUID()
        timestamp = tweet.created_at
    }
    
    static func withUrl(_ url: URL, context moc: NSManagedObjectContext) -> StoredArticle? {
        let request = StoredArticle.fetchRequest(NSPredicate(format: "url = %@", url as NSURL))
        let results = try? moc.fetch(request)
        return results?.first
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<StoredArticle> {
        let request = NSFetchRequest<StoredArticle>(entityName: "StoredArticle")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    
}
