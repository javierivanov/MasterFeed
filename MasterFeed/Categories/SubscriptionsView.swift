//
//  SubscriptionsView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 02-08-21.
//

import SwiftUI

struct SectionSubcriptionAddView: View {
    
    var category: String
    @EnvironmentObject var feedModel: FeedModel
    var body: some View {
        if !feedModel.categoriesMapping[category, default: []].isEmpty {
            Section(header: category) {
                ForEach(feedModel.categoriesMapping[category, default: []], id:\.self) { source in
                    Button(action: {}, label: {
                        HStack {
                            Text(source)
                            Spacer()
                            Text(Image(systemName: "plus.circle"))
                        }
                    })
                }
            }
        }
    }
}


struct SubscriptionLabelView: View {
    var subscription: UserSubscription
    var body: some View {
        HStack {
            AsyncImage<AnyView>(url: URL(string: subscription.pic_url)!, frameSize: CGSize(width: 28, height: 28)).clipShape(Circle(), style: FillStyle())
            Text(subscription.name)
            Spacer()
        }
    }
}

struct NonSubscriptionLabelView: View {
    var subscription: UserSubscription
    @EnvironmentObject var feedModel: FeedModel
    var body: some View {
        Button(action: {
            feedModel.subscriptions.append(subscription)
            if let index = feedModel.recommendedSources[subscription.category]?.enumerated().first(where: {$0.element == subscription})?.offset {
                feedModel.recommendedSources[subscription.category]?.remove(at: index)
            }
        }, label: {
            HStack {
                AsyncImage<AnyView>(url: URL(string: subscription.pic_url)!, frameSize: CGSize(width: 28, height: 28)).clipShape(Circle(), style: FillStyle())
                Text(subscription.name)
                Spacer()
                Text(Image(systemName: "plus.circle"))
            }
        })
    }
}

struct SubscriptionSettingsView: View {
    
    var subscription: UserSubscription
    @EnvironmentObject var feedModel: FeedModel
    @State var sureToDelete = false
    @Environment(\.presentationMode) var presentationMode
    @State var removeAtFinish = false
    
    var body: some View {
        let selectedIndex = feedModel.subscriptions.enumerated().first(where: {$0.element == subscription})!.offset
        Form {
            Section(header: Text("From twitter")) {
                HStack {
                    AsyncImage<AnyView>(url: URL(string: feedModel.subscriptions[selectedIndex].pic_url)!, frameSize: CGSize(width: 28, height: 28)).clipShape(Circle(), style: FillStyle())
                    Link(destination: URL(string: "https://twitter.com/\(feedModel.subscriptions[selectedIndex].username)")!) {
                        Text("@\(feedModel.subscriptions[selectedIndex].username)").foregroundColor(.blue).font(.subheadline).bold()
                    }
                    
                }
            }
            Section(header: Text("Setup")) {
                Toggle("Source Enabled", isOn: $feedModel.subscriptions[selectedIndex].active)
                Picker("Pick a Category: ", selection: $feedModel.subscriptions[selectedIndex].category) {
                    ForEach(FeedModel.categoryList, id:\.self) { cat in
                        Text(cat).tag(cat)
                    }
                }.disabled(feedModel.sourceCategoryMap.keys.contains(feedModel.subscriptions[selectedIndex].username))
            }
            
            Section(header: Text("actions")) {
                Button("Delete", action: {
                    sureToDelete = true
                })
                .foregroundColor(feedModel.subscriptions[selectedIndex].inMemory ? .red : .gray)
                .disabled(!feedModel.subscriptions[selectedIndex].inMemory)
                .actionSheet(isPresented: $sureToDelete, content: {
                    ActionSheet(title: Text("Delete Source"), message: Text("Are you sure to delete this source?"), buttons: [
                        .destructive(Text("Delete"), action: {
                            removeAtFinish = true
                            presentationMode.wrappedValue.dismiss()
                        }),
                        .default(Text("Disable"), action: {
                            feedModel.subscriptions[selectedIndex].active = false
                        }),
                        .cancel()
                    ])
                })
            }
        }
        .navigationBarTitle(feedModel.subscriptions[selectedIndex].name, displayMode: .large)
        .onDisappear {
            if removeAtFinish {
                if feedModel.sourceCategoryMap.keys.contains(feedModel.subscriptions[selectedIndex].username) {
                    feedModel.subscriptions[selectedIndex].active = true
                    feedModel.recommendedSources[feedModel.subscriptions[selectedIndex].category]?.append(feedModel.subscriptions[selectedIndex])
                }
                feedModel.subscriptions.remove(at: selectedIndex)
            }
        }
    }
}
