//
//  NewSourcesView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 02-08-21.
//

import SwiftUI

struct SourceAddView: View {
    
    
    @EnvironmentObject var feedModel: FeedModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var userSearch: SearchSources
    @State var textSearch: String = ""
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Search")) {
                    HStack {
                        TextField("Twitter Sources...", text: $textSearch)
                        if userSearch.isLoading {
                            ProgressView()
                        }
                        if userSearch.showReload {
                            Button(action: {
                                userSearch.load(textSearch)
                            }, label: {
                                Text("Retry")
                            })
                        }
                    }
                }

                Section(header: Text("Results")) {
                    ForEach(userSearch.results) { sub in
                        NavigationLink(
                            destination: SourceAddFormView(source: sub),
                            label: {
                                SourceLabelView(source: sub)
                            }).disabled(feedModel.subscriptions.contains(sub))
                    }
                }
            }
            .animation(.easeInOut)
            .onChange(of: textSearch, perform: { value in
                userSearch.load(value)
            })
            .navigationTitle("New Source")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: { Text("Done").bold() }))
        }
    }
}

struct SourceAddFormView: View {
    @State var source: UserSubscription
    @EnvironmentObject var feedModel: FeedModel
    @Environment(\.presentationMode) var presentationMode
    
    init(source: UserSubscription) {
        _source = State(wrappedValue: source)
    }
    
    var body: some View {
        Form {
            Section(header: Text("From twitter")) {
                HStack {
                    AsyncImage<AnyView>(url: URL(string: source.pic_url)!, frameSize: CGSize(width: 28, height: 28)).clipShape(Circle(), style: FillStyle())
                    
                    Link(destination: URL(string: "https://twitter.com/\(source.username)")!) {
                        Text("@\(source.username)").foregroundColor(.blue).font(.subheadline).bold()
                    }
                }
            }
            
            Section(header: Text("Setup")) {
                Picker("Select A Category", selection: $source.category) {
                    ForEach(FeedModel.categoryList, id:\.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
            }
            Section(header: Text("Actions"), footer: Text("The content from this source may not appear on results if no articles are published.")) {
                Button(action: {
                    feedModel.subscriptions.append(source)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Add Source")
                })
            }
            
        }
        .navigationTitle(source.name)
    }
}

struct SourceLabelView: View {
    var source: UserSubscription
    
    var body: some View {
        HStack {
            AsyncImage<AnyView>(url: URL(string: source.pic_url)!, frameSize: CGSize(width: 28, height: 28)).clipShape(Circle(), style: FillStyle())
            VStack(alignment: .leading) {
                Text(source.name).bold()
                Text("@\(source.username)").foregroundColor(.blue)
            }
        }
    }
}
