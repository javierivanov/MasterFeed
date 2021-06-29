//
//  Subscriptions.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 09-05-21.
//

import Foundation

// MARK: - UserSubscription
struct UserSubscription: Identifiable, Codable, Hashable {
    var username: String
    var name: String
    var pic_url: String
    var id: String
    var active: Bool = true
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserSubscription, rhs: UserSubscription) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: - Categories
struct SubscriptionCategory: Identifiable, Hashable {
    var name: String
    var id: String
    var pic_url: String
    var active: Bool = true
}

//
//let acceptedAccounts = [
//"FoxNews",
//"politico",
//"telegraph",
//"cbcnews",
//"independent",
//"rt_com",
//"guardiannews",
//"france24_en",
//"cnbc",
//"newsweek",
//"skynewsbreak",
//"ajenglish",
//"skynews",
//"financialtimes",
//"guardian",
//"breakingnews",
//"huffpost",
//"ndtv",
//"xhnews",
//"ap",
//"washingtonpost",
//"abc",
//"time",
//"wsj",
//"reuters",
//"theeconomist",
//"bbcworld",
//"bbcbreaking",
//"cnn",
//"nytimes",
//"cnnbrk",
//]
