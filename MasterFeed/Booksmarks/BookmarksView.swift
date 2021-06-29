//
//  BookmarksView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 14-06-21.
//

import SwiftUI
import CoreData

struct BookmarksView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: StoredArticle.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \StoredArticle.timestamp, ascending: true)]
    ) var articles: FetchedResults<StoredArticle>
    
    @State var url: URL?
    @State var isPresented: Bool = false
    
    var body: some View {
        List {
            ForEach(articles){ article in
                Button (action: {
                    isPresented = true
                    url = article.url
                }, label: {
                        SampleView(article: article)
                })
            }.onDelete(perform: { indexSet in
                for index in indexSet {
                    moc.delete(articles[index])
                }
                do {
                    try moc.save()
                } catch {
                    print("Somethin bad here")
                }
            })
        }
        .navigationTitle("Bookmarks")
        .sheet(isPresented: $isPresented, content: {
            SafariView(url: $url)
        })
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
