//
//  AccountView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 12-05-21.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var feedModel: FeedModel
    @State private var showAlert = false
    
    var body: some View {
        
        Form {
            
            List {
                
                HStack {
                    
                    Image("twitter").resizable().scaledToFit().frame(maxWidth: 60).padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("User: \(feedModel.user?.username ?? "Super User")")
                        Spacer()
                        Text("id: \(feedModel.user?.user_id ?? "Super User")")
                    }.padding([.vertical])
                }
                
                Section {
                    Toggle("EasyReading", isOn: $feedModel.defaultEasyReading)
//                    Picker("Default Category", selection: $feedModel.defaultCategory)  {
//                        ForEach(feedModel.categoryList.indices, id:\.self) { idx in
//                            Text(feedModel.categoryList[idx]).tag(feedModel.categoryList[idx])
//                        }
//                    }
                    
//                    NavigationLink(
//                        destination: SubscriptionsView(),
//                        label: {
//                            Text("Subscriptions")
//                        })
                    //                    NavigationLink(
                    //                        destination: Text("Destination"),
                    //                        label:{
                    //                            Text("Categories")
                    //                        })
                }
                
                Button(action: {
                    showAlert = true
                }, label: {
                    Text("Logout").foregroundColor(.red)
                }).actionSheet(isPresented: $showAlert) {
                    ActionSheet(
                        title: Text("Remove Credentials From Device"),
                        message: Text("Are you sure?"),
                        buttons: [
                            .cancel(),
                            .destructive(Text("Delete"),
                                         action: {withAnimation { feedModel.logoutUser() }})
                        ]
                    )
                }
            }
        }
        .navigationTitle("Account")
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView().environmentObject(FeedModel.sampleSubs())
    }
}

