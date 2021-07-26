//
//  CoverageView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 22-07-21.
//

import SwiftUI
import UnsupervisedTextClassifier
import SwiftUIX

struct CoverageView: View {
    var category: String
    var segment: SegmentResultGroup
    @EnvironmentObject var feedModel: FeedModel
    let imgSize = CGSize(width: 120, height: 120)
    var body: some View {
//        ScrollView {
//            VStack {
                let resultGroup = segment.resultGroup.map {$0.article as! Tweet}
                List {
                    Text("\(segment.tokens.a.capitalized)")
                    ForEach(resultGroup) { result in
//                        HorizontalCardView(tweet: result)
                        
                        HStack(alignment: .top) {
                            AsyncImage<AnyView>(url: result.image, frameSize: imgSize).frame(imgSize).cornerRadius(10)
                            VStack(alignment: .leading) {
                                Text(result.source ?? "").foregroundColor(.blue).bold()
                                Text(formatter.localizedString(fromTimeInterval: Date().distance(to: (result.createdAt ?? Date())))).font(.caption)
                                Text(result.text ?? "").font(.title3)
                            }.padding(.leading)
                        }
                        
                    }
                    InternalCoverageView(coverage: feedModel.coverage[segment.correlationIndex, default: Coverage()], correlationIndex: segment.correlationIndex)
                }.navigationTitle("\(category)")
//            }
            
//        }
    }
}

struct InternalCoverageView: View {
    
    @EnvironmentObject var feedModel: FeedModel
    @StateObject var coverage: Coverage
    var correlationIndex: Array<CorrelationResult>.Index
    init(coverage: Coverage, correlationIndex: Array<CorrelationResult>.Index) {
        _coverage = StateObject(wrappedValue: coverage)
        self.correlationIndex = correlationIndex
    }
    
    var body: some View {
        if coverage.sortedArticles.isEmpty {
            VStack(alignment: .center) {
                ProgressView("")
            }
                .onAppear {
                    feedModel.computeCoverage(index: correlationIndex)
                }
        } else {
            EmptyView()
        }
    }
}

//struct CoverageView_Previews: PreviewProvider {
//    static var previews: some View {
//        CoverageView(correlation: CorrelationResult())
//    }
//}
