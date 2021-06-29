//
//  SubscriptionsView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 11-05-21.
//

import SwiftUI
import SwiftUIX

struct SubscriptionsView: View {
    
    @EnvironmentObject var feedModel: FeedModel
    @State var searchText = ""
    @State var isEditing: Bool = false
    
    var body: some View {
        List {
            ForEach(feedModel.subscriptions.indices, id:\.self) { index in
                
                if feedModel.subscriptions[index].name.lowercased().contains(searchText.lowercased()) || feedModel.subscriptions[index].username.lowercased().contains(searchText.lowercased()) || searchText == "" {
                    Toggle("\(feedModel.subscriptions[index].name) @\(feedModel.subscriptions[index].username)", isOn: $feedModel.subscriptions[index].active)
                }
            }
            
        }
        
//        Button(action: {
//            withAnimation {
//                feedModel.loadSubscriptions(forceRefresh: true)
//            }
//        }, label: {
//            Text("Refresh Subscriptions")
//        })
        
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Select All") {
                    withAnimation {
                        for idx in feedModel.subscriptions.indices {
                            feedModel.subscriptions[idx].active = true
                        }
                    }
                }
                
                Button("Deselect All") {
                    withAnimation {
                        for idx in feedModel.subscriptions.indices {
                            feedModel.subscriptions[idx].active = false
                        }
                    }
                }
            }
        }
        .navigationTitle("Subscriptions")
        .navigationSearchBarHiddenWhenScrolling(true)
        .navigationSearchBar {
            SearchBar("Name", text: $searchText, isEditing: $isEditing) {
                print(searchText)
            }
            .onCancel {
                isEditing = false
                searchText = ""
            }.showsCancelButton(true)
        }
 
    }
}

struct SubscriptionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            SubscriptionsView().environmentObject(FeedModel.sampleSubs())
        }
    }
}
