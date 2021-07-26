//
//  SegmentResultGroup+Categories.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 20-07-21.
//

import Foundation
import UnsupervisedTextClassifier

extension SegmentResultGroup {
    func mainTweetCategory() -> String? {
        guard let articles = resultGroup.map(\.article) as? [Tweet] else {
            return nil
        }
        var counter: [String: Int] = [:]
        articles.flatMap(\.categories).forEach {
            counter[$0, default: 0] += 1
        }
        return counter.sorted(by: {$0.value > $1.value}).first?.key
    }
}
