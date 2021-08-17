//
//  SegmentResultGroup+Categories.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 20-07-21.
//

import Foundation
import UnsupervisedTextClassifier

extension SegmentResultGroup {
    func mainTweetCategory(_ categoryMapping: [String:String]) -> String? {
        guard let articles = resultGroup.map(\.article) as? [Tweet] else {
            return nil
        }
        var counter: [String: Int] = [:]
        
        articles.map { article -> Tweet in
            guard !article.categories.isEmpty else {
                return article
            }
            var article = article
            article.categories.append(categoryMapping[article.username!, default: "News"])
            return article
        }.flatMap(\.categories).forEach {
            counter[$0, default: 0] += 1
        }
        return counter.sorted(by: {$0.value > $1.value}).first?.key
    }
}
