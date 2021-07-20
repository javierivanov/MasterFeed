//
//  AppTabView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 12-05-21.
//

import SwiftUI

struct AppTabView: View {
    @State var selectedTab: Tabs = .main
    
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                MainFeedView()
            }.navigationViewStyle(StackNavigationViewStyle()) // Use .stack in io15
            .tabItem { Label("News", systemImage: "newspaper.fill")
                .accessibility(label: Text("News")) }
            .tag(Tabs.main)
            
            NavigationView {
                CategoriesView()
            }.navigationViewStyle(StackNavigationViewStyle()) // Use .stack in io15
            .tabItem { Label("Categories", systemImage: "books.vertical.fill")
                .accessibility(label: Text("Categories")) }
            .tag(Tabs.categories)
            
            NavigationView {
                BookmarksView()
            }.navigationViewStyle(StackNavigationViewStyle()) //TODO: deprecated ios 15
            .tabItem { Label("Bookmarks", systemImage: "book.fill")
                .accessibility(label: Text("Bookmarks")) }
            .tag(Tabs.bookmarks)
            
            NavigationView {
                AccountView()
            }.navigationViewStyle(StackNavigationViewStyle()) //TODO: deprecated ios 15
            .tabItem { Label("Account", systemImage: "person.fill")
                .accessibility(label: Text("Account"))  }
            .tag(Tabs.account)
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}


// MARK: - Main Views
extension AppTabView {
    enum Tabs: CaseIterable {
        case main
        case categories
        case bookmarks
        case account
    }
}



