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
                })
                // MODIFIED HERE: actionSheet to confirmationDialog
                .confirmationDialog(
                    Text("Remove Credentials From Device"), // Title
                    isPresented: $showAlert,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        withAnimation { feedModel.logoutUser() }
                    }
                    Button("Cancel", role: .cancel) {
                        // Default cancel action dismisses the dialog
                    }
                } message: {
                    Text("Are you sure?") // Message
                }
            }
        }
        .navigationTitle("Account")
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AccountView().environmentObject(FeedModel.sampleSubs())
        }
    }
}
