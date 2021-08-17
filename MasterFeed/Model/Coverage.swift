//
//  Coverage.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 22-07-21.
//

import SwiftUI
import Combine
import NaturalLanguage

class Coverage: ObservableObject {
    @Published var sortedArticles: [Tweet] = []
    let feedModel: FeedModel
    var coverageCancellable: AnyCancellable?
    
    @Published var loading: Bool = true
    
    
    
    init(feedModel: FeedModel) {
        self.feedModel = feedModel
    }
    
    func computeCoverage(text: String) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            if let embedding = NLEmbedding.sentenceEmbedding(for: .english) {
                
                let articles: [Tweet]? = self.feedModel.clusters?.reduce(into: [Tweet](), { res, next in
                    res.append(contentsOf: (next.value.articles as! [Tweet]))
                })
                
                articles?.forEach({ tweet in
                    if embedding.distance(between: tweet.text!, and: text) < 0.7 {
                        DispatchQueue.main.async {
                            self.sortedArticles.append(tweet)
                        }
                    }
                })
                DispatchQueue.main.async {
                    self.loading = false
                }
            }
        }
    }
}
