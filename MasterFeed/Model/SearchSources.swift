//
//  SearchSources.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 02-08-21.
//

import Foundation
import Combine

class SearchSources: ObservableObject {
    
    @Published var results: [UserSubscription] = []
    @Published var isLoading: Bool = false
    @Published var showReload: Bool = false
    private(set) var searchCancellable: AnyCancellable?
    var user: UserAccount
    
    init(user: UserAccount) {
        self.user = user
    }
    
    func load(_ param: String, page: Int? = nil) {
        searchCancellable?.cancel()
        
        guard !param.isEmpty else {
            isLoading = false
            showReload = false
            return
        }
        
        isLoading = true
        showReload = false
        searchCancellable = TwitterServices(user: user).searchPublisher(param, page: page)
            .delay(for: .milliseconds(page == nil ? 500: 0), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                    self.isLoading = false
                    self.showReload = true
                    self.results = []
                case .finished:
                    self.isLoading = false
                }
            } receiveValue: { subs in
                let current = Set(self.results)
                if page == nil {
                    self.results = subs
                } else {
                    self.results.append(contentsOf: subs.filter {!current.contains($0)})
                }
                
                if subs.count < 20 && page ?? 1 < 10 {
                    let page = page ?? 1
                    self.load(param, page: page + 1)
                }
            }
    }
}
