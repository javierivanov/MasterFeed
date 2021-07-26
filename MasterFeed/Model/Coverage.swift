//
//  Coverage.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 22-07-21.
//

import SwiftUI
import Combine

class Coverage: ObservableObject {
    @Published public var sortedArticles: [Tweet] = []
    
    init() {
    }
}
