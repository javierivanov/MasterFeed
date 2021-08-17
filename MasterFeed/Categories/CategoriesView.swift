//
//  CategoriesView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 01-06-21.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var feedModel: FeedModel
    @State var presentAdd: Bool = false
    
    var body: some View {
        List {
            ForEach(FeedModel.categoryList, id:\.self) { category in
                SectionSubcriptionView(section: category)
            }
        }
        
        .navigationBarItems(trailing:
                                Button(action: {
                                    presentAdd = true
                                }, label: {
                                    Text(Image(systemName: "plus"))
                                })
        )
        .navigationBarTitle("Categories", displayMode: .large)
        .listStyle(InsetGroupedListStyle())
        .sheet(isPresented: $presentAdd, content: {
            SourceAddView(userSearch: SearchSources(user: feedModel.user!))
                .environmentObject(feedModel)
        })
    }
}


struct SectionSubcriptionView: View {
    
    var section: String
    @EnvironmentObject var feedModel: FeedModel
    
    var body: some View {
        
        let subscriptions = feedModel.subscriptions.filter {$0.category == section}
        let accounts = Set(subscriptions.map(\.username))
        let filteredAccounts = feedModel.categoriesMapping[section, default:[]].filter({!accounts.contains($0)})
        
        if subscriptions.isEmpty && filteredAccounts.isEmpty {
            EmptyView()
        } else {
            Section(header: section) {
                ForEach(subscriptions) { subscription in
                    NavigationLink(
                        destination: SubscriptionSettingsView(subscription: subscription),
                        label: {
                            SubscriptionLabelView(subscription: subscription)
                        })
                }
                
                if !filteredAccounts.isEmpty && feedModel.recommendedSources[section, default: []].isEmpty {
                    Button(action: {
                        feedModel.loadUserLookup(filteredAccounts, category: section)
                    }, label: {
                        Text("See Recomendations")
                    })
                } else if !filteredAccounts.isEmpty {
                    ForEach(feedModel.recommendedSources[section, default:[]]) { subs in
                        NonSubscriptionLabelView(subscription: subs)
                    }
                }
            }
            .animation(.easeInOut)
        }
    }
}


//
//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            CategoriesView()
//        }.environmentObject(FeedModel.sampleSubs()).preferredColorScheme(.dark)
//    }
//}

