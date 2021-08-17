//
//  UTC.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 04-08-21.
//

import Foundation
//
//  UnsupervisedTextClassifier.swift
//  UnsupervisedTextClassifier
//
//  Created by Javier Fuentes on 28-03-21.
//
//
import NaturalLanguage
import LASwift
import SigmaSwiftStatistics
import Combine
import CoreML
public class UnsupervisedTextClassifier {
    
    public init() {
    }
    
    static let mlModel = try! KeywordDetection(configuration: MLModelConfiguration()).model
    static let customModel = try! NLModel(mlModel: mlModel)
    static let keywordScheme = NLTagScheme("Keyword")
    
    // MARK: - Extract keywords
    /**
     Extracts keywords from a sentences.
     
    - Parameter text: Full sentences to be decomposed.
    - Parameter tags: NTags for specific cases.
    
    - Returns:
     Set of tags (keywords) for the sentence (text).
     */
    public static func extractKeywords(text: String, tags userTags: [NLTag] = []) throws -> Set<String> {
        
        var keywords: Set<String> = []
        let tagger = NLTagger(tagSchemes: [keywordScheme])
        tagger.setModels([customModel], forTagScheme: keywordScheme)
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
//        let staticTags: [NLTag] = [.personalName, .placeName, .organizationName]
//        let lowerTags: [NLTag] = [.noun, .adverb]
//        let tags = userTags + staticTags + lowerTags
        
//        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
//                             unit: .word,
//                             scheme: .lemma,
//                             options: options) { tag, tokenRange in
//            if let tag = tag, tags.contains(tag) {
//                keywords.insert(String(text[tokenRange]).lowercased())
//            }
//           return true
//        }
        
        
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: keywordScheme,
                             options: options) {tag, tokenRange in
            if tag?.rawValue == "key" {
                keywords.insert(String(text[tokenRange]).lowercased())
            }
            return true
        }
        return keywords
    }
    
    //MARK: - Compute Cov
    /**
     Computes Covariance for two vectos.
     
     ```
     Formula: cov(x,y) = Σ(x - mx)(y - my) / n
     ```
     - Parameter vect1: Values for vector y
     - Parameter vect2: Values for vector x
     - Parameter vect1Avg: Average value for vector y
     - Parameter vect2Avg: Average value for vector x
     
     - Returns: Joint variability for the two vectors. For values close to zero there is no covariance.
     
     */
    public static func cov(vect1: Vector, vect2: Vector, vect1Avg: Double, vect2Avg: Double) -> Double {
        zip(vect1, vect2).map { (a: Double, b: Double) -> Double in
            (a - vect1Avg) * (b - vect2Avg)
        }.reduce(0.0, +) / Double(vect1.count - 1)
    }
    

    public static func colAvg(vect: Vector) -> Double {
        vect.reduce(0, +) / Double(vect.count)
    }
    

    public static func std(vect: Vector, vectAvg: Double/*, corrected: Bool = false*/) -> Double {
        let n = Double(vect.count)// - (corrected ? 0 : 1))
        return sqrt(vect.map {pow($0 - vectAvg, 2.0)}.reduce(0.0, +) / n)
    }
    
    
    public static func pearson(vect1: Vector, vect2: Vector, vect1Avg: Double, vect2Avg: Double) -> Double {
        let cov = self.cov(vect1: vect1, vect2: vect2, vect1Avg: vect1Avg, vect2Avg: vect2Avg)
        let std1 = self.std(vect: vect1, vectAvg: vect1Avg)
        let std2 = self.std(vect: vect2, vectAvg: vect2Avg)
        return cov /  (std1 * std2)
    }
    
    public static func colSum(matrix: Matrix) -> Vector {
        sum(matrix, .Column)
    }
    
    public static func qPercentile(vector: Vector, probability: Double) -> Double {
        Sigma.quantiles.method7(vector, probability: probability)!
    }
    
    
    public static func filterCols(vector: Vector, cols: [Int]) -> Vector {
        let cols_set = Set(cols)
        return vector.enumerated()
            .filter {cols_set.contains($0.offset)}
            .map {$0.element}
    }
    
    public static func filterCols(matrix: Matrix, cols: [Int], keywords: [String]) -> (matrix: Matrix, keywords: [String]) {
        let cols_set = Set(cols)
        let newKeywords: [String] = cols.map {keywords[$0]}

        let newMatrix: [Vector] = matrix.map { vect in
            vect.enumerated()
                .filter {cols_set.contains($0.offset)}
                .map {$0.element}
        }

        return (Matrix(newMatrix), newKeywords)
    }

    
    public static func filterRows(matrix: Matrix, cols: (x: Int, y: Int)) -> Matrix {
        var newMatrix: [Vector] = []
        for row in 0..<matrix.rows {
            if matrix[row: row][cols.x] == 1 && matrix[row: row][cols.y] == 1 {
                newMatrix.append(matrix[row: row])
            }
        }
        return Matrix(newMatrix)
    }
    
    public static func filterRows(matrix: Matrix, rows: [Int]) -> Matrix {
        var newMatrix: [Vector] = []
        for row in rows {
            newMatrix.append(matrix[row: row])
        }
        return Matrix(newMatrix)
    }
    
    public static func selectRows(matrix: Matrix, cols: (x: Int, y: Int)) -> [Int] {
        var rows: [Int] = []
        for row in 0..<matrix.rows {
            if matrix[row: row][cols.x] == 1 && matrix[row: row][cols.y] == 1 {
                rows.append(row)
            }
        }
        return rows
    }

    
    public static func avgMatrixToVector(matrix: Matrix) -> Vector {
        var out: Vector = Vector(matrix[row: 0])
        for row in 1..<matrix.rows {
            for col in 0..<matrix.cols {
                out[col] += matrix[row: row][col]
            }
        }
        return out.map {$0 / Double(matrix.rows)}
    }
    
    
    static func sortingResults(result: Cluster) -> AnyPublisher<SegmentResultGroup, Error> {
        guard let correlations = result.correlation else {fatalError()}
        let tasks = correlations.indices.map { correlationIndex -> Deferred<Future<SegmentResultGroup, Error>> in
            let correlation = correlations[correlationIndex]
            return Deferred {
                Future() { promise in
                    DispatchQueue.global(qos: .userInteractive).async {
                        // Target Group AVG with similar vectors.
                        let (token_x, token_y) = correlation.tokens
                        
                        let targetRows = Self.selectRows(matrix: result.matrix, cols: (token_x, token_y))
                        let targetMatrix = Self.filterRows(matrix: result.matrix, rows: targetRows)
                        let target_vector = Self.avgMatrixToVector(matrix: targetMatrix)
                        
                        let groups = targetRows.map { row -> ResultGroup in
                            let sample_pair = result.matrix[row: row].enumerated()
                                //.filter {target_offsets.contains($0.offset)}
                                //.filter {$0.element != 0.0 || $0.offset == token_x || $0.offset == token_y}
                            
                            
                            let sample_vector = sample_pair.map(\.element)
                            //print("sample_vector: \(sample_vector)")
                            
                            let tp = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 > 0 }.count)
                            let fp = Double(zip(target_vector, sample_vector).filter { $0 == 0.0 && $1 > 0 }.count)
                            let fn = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 == 0.0 }.count)
                            
    //                        let tn = Double(zip(target_vector, sample_vector).filter { $0 == 0 && $1 == 0 }.count )
    //                        let accuracy_inv = 1.0 - (tp + tn) / (tp + tn + fp + fn)
                            
                            let f1_score_inv = 1.0 - (tp / (tp + (fp + fn)/2.0))
                            
                            return ResultGroup(similarity: f1_score_inv, article: result.articles[row], row: row)
                        }.sorted(by: {$0.similarity < $1.similarity})
                        
                        
                        let tokens = (a: result.keywords[correlation.tokens.a], b: result.keywords[correlation.tokens.b])
                        let segment = SegmentResultGroup(correlationIndex: correlationIndex, tokens: tokens, resultGroup: groups)
                        promise(.success(segment))
                    }
                }
            }
        }
        
        return Publishers.MergeMany(tasks).eraseToAnyPublisher()
    }
    
    
    typealias SortingClosestConf = (corrIdx: Array<CorrelationResult>.Index, rows: Set<Int>)
    
    // MARK: - Sorting Closests -
    static func sortingResults(result: Cluster, conf: SortingClosestConf?) -> (conf: SortingClosestConf, output:SegmentResultGroup?) {
        
        var conf = conf ?? (corrIdx: 0, rows: Set(0..<result.matrix.rows))
        let corrIdx = conf.corrIdx
        var rows = conf.rows
        
        guard corrIdx < result.correlation!.count - 1 && rows.count > 0 else {
            return (conf: conf, output: nil)
        }
        
        // Target Group AVG with similar vectors.
        let (token_x, token_y) = result.correlation![corrIdx].tokens
        let targetMatrix = Self.filterRows(matrix: result.matrix, cols: (token_x, token_y))
        let target_vector = Self.avgMatrixToVector(matrix: targetMatrix)
        
        let tasks = rows.map { row -> Deferred<Future<ResultGroup, Error>> in
            return Deferred {
                Future() { promise in
                    DispatchQueue.global(qos: .userInteractive).async {
                        
                        // Sample vector is the vector used to check if contains at least one of the previous tokens
                        let sample_pair = result.matrix[row: row].enumerated()
                            //.filter {target_offsets.contains($0.offset)}
                            //.filter {$0.element != 0.0 || $0.offset == token_x || $0.offset == token_y}
                        
                        
                        let sample_vector = sample_pair.map(\.element)
                        //print("sample_vector: \(sample_vector)")
                        
                        let tp = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 > 0 }.count)
                        let fp = Double(zip(target_vector, sample_vector).filter { $0 == 0.0 && $1 > 0 }.count)
                        let fn = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 == 0.0 }.count)
                        
//                        let tn = Double(zip(target_vector, sample_vector).filter { $0 == 0 && $1 == 0 }.count )
//                        let accuracy_inv = 1.0 - (tp + tn) / (tp + tn + fp + fn)
                        
                        let f1_score_inv = 1.0 - (tp / (tp + (fp + fn)/2.0))
                        
//                        let mcc_1 = ((tp * tn) - (fp * fn))
//                        let mcc_2 = sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
//                        let mcc = mcc_1 / mcc_2
                        
                        guard sample_vector.count > 0 else {
                            promise(.success(ResultGroup(similarity: 1.0, article: result.articles[row], row: row)))
                            return
                        }
                        
                        let custom_target_vector = sample_pair.map {target_vector[$0.offset]}
                        
                        let custom_target_norm = sqrt(custom_target_vector.map {pow($0, 2)}.reduce(0.0, +))
                        // recompute norm
                        let div = custom_target_norm * sqrt(Double(sample_vector.filter {$0 > 0}.count))

                        guard div > 0.0 else {
                            promise(.success(ResultGroup(similarity: 1.0, article: result.articles[row], row: row)))
                            return
                        }

                        
                        let row_result =  f1_score_inv //accuracy_inv //mcc //1.0 - (dot(sample_vector, custom_target_vector) / div)
                        
                        let resultGroup = ResultGroup(similarity: row_result.isNaN ? 1.0 : row_result,
                                                      article: result.articles[row],
                                                      row: row)
                        
                        promise(.success(resultGroup))
                    }
                }
            }
        }
        
        let sema = DispatchSemaphore(value: 0)
        
        var ans: SegmentResultGroup?
        
        Publishers.MergeMany(tasks)
            .collect()
            .sinkStream { simils in
                defer { sema.signal() }
                let filteredSimils = simils.filter {$0.similarity < result.maxSimilarity }
                let correlation = result.correlation![corrIdx]
                let tokens = (a: result.keywords[correlation.tokens.a], b: result.keywords[correlation.tokens.b])
                
                if filteredSimils.isEmpty {
                    if let single = simils.min(by: { $0.similarity < $1.similarity }) {
                        ans = SegmentResultGroup(correlationIndex: corrIdx, tokens: tokens, resultGroup: [single])
                        rows.remove(single.row)
                    }
                } else {
                    ans = SegmentResultGroup(correlationIndex: corrIdx, tokens: tokens, resultGroup: filteredSimils)
                    filteredSimils.forEach { rows.remove($0.row) }
                }
            }
        sema.wait()
        conf.rows = rows
        conf.corrIdx += 1
        return (conf: conf, output: ans)
    }

    
//     MARK: - Sorting Results with repetition -
    static func sortingResults(result: Cluster, tokenIndex: Array<CorrelationResult>.Index) -> AnyPublisher<ResultGroup, Never> {
        guard tokenIndex < result.correlation!.count else {
            fatalError()
        }
        let (token_x, token_y) = result.correlation![tokenIndex].tokens
        let targetMatrix = Self.filterRows(matrix: result.matrix, cols: (token_x, token_y))
        let target_vector = Self.avgMatrixToVector(matrix: targetMatrix)
        
        let rows = 0..<result.matrix.rows
        
        let tasks = rows.map { row -> Deferred<Future<ResultGroup,Never>> in
            return Deferred {
                Future() { promise in
                    DispatchQueue.global(qos: .userInteractive).async {
                        
                        // Sample vector is the vector used to check if contains at least one of the previous tokens
                        let sample_pair = result.matrix[row: row].enumerated()
                            //.filter {target_offsets.contains($0.offset)}
                            //.filter {$0.element != 0.0 || $0.offset == token_x || $0.offset == token_y}
                        
                        
                        let sample_vector = sample_pair.map(\.element)
                        //print("sample_vector: \(sample_vector)")
                        
                        let tp = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 > 0 }.count)
                        let fp = Double(zip(target_vector, sample_vector).filter { $0 == 0.0 && $1 > 0 }.count)
                        let fn = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 == 0.0 }.count)
                        
//                        let tn = Double(zip(target_vector, sample_vector).filter { $0 == 0 && $1 == 0 }.count )
//                        let accuracy_inv = 1.0 - (tp + tn) / (tp + tn + fp + fn)
                        
                        let f1_score_inv = 1.0 - (tp / (tp + (fp + fn)/2.0))
                        
//                        let mcc_1 = ((tp * tn) - (fp * fn))
//                        let mcc_2 = sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
//                        let mcc = mcc_1 / mcc_2
                        
                        guard sample_vector.count > 0 else {
                            promise(.success(ResultGroup(similarity: 1.0, article: result.articles[row], row: row)))
                            return
                        }
                        
                        let custom_target_vector = sample_pair.map {target_vector[$0.offset]}
                        
                        let custom_target_norm = sqrt(custom_target_vector.map {pow($0, 2)}.reduce(0.0, +))
                        // recompute norm
                        let div = custom_target_norm * sqrt(Double(sample_vector.filter {$0 > 0}.count))

                        guard div > 0.0 else {
                            promise(.success(ResultGroup(similarity: 1.0, article: result.articles[row], row: row)))
                            return
                        }

                        
                        let row_result =  f1_score_inv //accuracy_inv //mcc //1.0 - (dot(sample_vector, custom_target_vector) / div)
                        
                        let resultGroup = ResultGroup(similarity: row_result.isNaN ? 1.0 : row_result,
                                                      article: result.articles[row],
                                                      row: row)
                        
                        promise(.success(resultGroup))
                    }
                }
            }
        }
        
        return Publishers.MergeMany(tasks).eraseToAnyPublisher()
        
    }
    
    
    
    // MARK: - Correlation Matrix Publisher
    static func correlationMatrix(matrix: Matrix, vectAvgs: Vector) -> AnyPublisher<[CorrelationResult], Never> {

        var tasks: [Deferred<Future<CorrelationResult, Never>>] = []

        for outter in 0..<matrix.cols {
            for inner in (outter + 1)..<matrix.cols {
                tasks.append(Deferred {
                    Future() { promise in
                        DispatchQueue.global(qos: .userInteractive).async {
                            let score = self.pearson(vect1: matrix[col: outter],
                                                     vect2: matrix[col: inner],
                                                     vect1Avg: matrix[col: outter].reduce(0.0, +) / Double(matrix[col: outter].count),
                                                     vect2Avg: matrix[col: inner].reduce(0.0, +) / Double(matrix[col: inner].count))
                            let result = CorrelationResult(score: score,
                                                          tokens: (outter, inner))
                            promise(.success(result))
                        }
                    }
                })
            }
        }
        return Publishers.MergeMany(tasks).collect().eraseToAnyPublisher()
    }
    
//    MARK: - Build Keywords
    public static func buildKeywords(article: Article) throws -> Article {
        var keywords = try extractKeywords(text: article.text!)
        article.keywords?.forEach { keywords.insert($0.lowercased()) }
        var newArticle = article
        newArticle.keywords = Array(keywords)
        return newArticle
    }
    
    // MARK: - Build Matrix
    public static func buildMatrix(textsMap: [[String]], keywords: [String]) -> Matrix {
        
        var keywords_list: [String: Int] = Dictionary()
        
        for (k, v) in keywords.enumerated() {
            keywords_list[v] = k
        }
        
        var matrix: [[Double]] = Array()
        for text in textsMap {
            var row = Array(repeating: 0.0, count: keywords_list.count)
            for tag in text {
                row[keywords_list[tag]!] = 1.0
            }
            matrix.append(row)
        }
        
        return Matrix(matrix)
    }

//    MARK: - Compute Statistics
    public static func statsPublisher(result: Cluster) -> AnyPublisher<Cluster, Never> {
        let tasks = (0..<result.matrix.cols).map { col -> Deferred<Future<(col: Int, sum: Double, avg: Double), Never>> in
            return Deferred {
                return Future() { promise in
                    DispatchQueue.global(qos: .userInteractive).async {
                        let sum = sum(result.matrix[col: col])
                        promise(.success((col, sum, sum / Double(result.matrix.rows))))
                    }
                }
            }
        }
        // TODO: - Check issues -
        return Publishers.MergeMany(tasks)
            .collect()
            .map { sums -> Cluster in
                var colsSum = Array<Double>(repeating: 0, count: sums.count)
                var colsAvg = Array<Double>(repeating: 0, count: sums.count)
                sums.forEach { sum in
                    // ISSUE HERE !!!
                    colsSum[sum.col] = sum.sum
                    colsAvg[sum.col] = sum.avg
                }
                var result = result
                result.colsAvg = colsAvg
                result.colsSum = colsSum
                result.q = qPercentile(vector: colsSum, probability: 0.95)
                return result
            }.eraseToAnyPublisher()
    }
    
    
    public static func correlationMatrixPublisher(result: Cluster) -> AnyPublisher<Cluster, Never> {

        guard let colsSum = result.colsSum,
              let q = result.q,
              let colsAvg = result.colsAvg
        else {
//            print("fail")
            return Just(result).eraseToAnyPublisher()
        }


        let idxs = colsSum.enumerated().filter {$0.element >= q}.map {$0.offset}
//        print("idxs done \(idxs.count)  -  \(colsSum.count)")
        
        let newColsSum = filterCols(vector: colsSum, cols: idxs)
        let newColsAvg = filterCols(vector: colsAvg, cols: idxs)

        let (newMatrix, newKeywords) = filterCols(matrix: result.matrix, cols: idxs, keywords: result.keywords)
//        print("startCorr")
//
//        print(newMatrix)
//
//        print("result.matrix.rows: \(result.matrix.rows)")
//        print("newMatrix.rows: \(newMatrix.rows)")
        
        let computedCorrMatrix = correlationMatrix(matrix: newMatrix, vectAvgs: newColsAvg)
        return computedCorrMatrix.map {corr in
            var result = result
            result.correlation = corr.sorted(by: {$0.score > $1.score}).filter {$0.score > 0.1}
            result.matrix = newMatrix
            result.keywords = newKeywords
            result.colsSum = newColsSum
            result.colsAvg = newColsAvg
            return result
        }.eraseToAnyPublisher()
        
    }
    
}


extension Publisher {
    func multiplier<Conf, Output>(_ splitTransform: @escaping Publishers.Multiplier<Self, Conf, Output>.SplitTransform) -> Publishers.Multiplier<Self, Conf, Output> {
        Publishers.Multiplier(upstream: self, splitTransform: splitTransform)
    }
    
    func sinkStream(_ callback: @escaping (Self.Output) -> Void) where Failure: Error {
        self.receive(subscriber: Subscribers.SinkCollection<Self.Output, Self.Failure>(callback))
    }
}


extension Subscribers {
    final class SinkCollection<Input, Failure>: Subscriber where Failure : Error {
        
        let callback: (Input) -> Void
        var subscription: Subscription?
        
        init(_ callback: @escaping (Input) -> Void) {
            self.callback = callback
        }
        
        func receive(subscription: Subscription) {
            self.subscription = subscription
            subscription.request(.unlimited)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            callback(input)
            return .unlimited
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
        }
    }
}

extension Publishers {
    
    struct Multiplier<Upstream, Conf, Output>: Publisher where Upstream: Publisher {
        
        typealias Output = Output
        typealias Failure = Upstream.Failure
        typealias SplitTransform = (Upstream.Output, Conf?) -> (conf: Conf, output: Output?)
        
        private let upstream: Upstream
        
        let splitTransform: SplitTransform
        
        init(upstream: Upstream, splitTransform: @escaping SplitTransform) {
            self.upstream = upstream
            self.splitTransform = splitTransform
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Output == S.Input {
            let subscription = MultiplierSubscription<S>(upstream: self.upstream, subscriber: subscriber, splitTransform: splitTransform)
            subscriber.receive(subscription: subscription)
        }
        
        final class MultiplierSubscription<S: Subscriber>: Subscription {
            
            var upstream: Upstream
            var subscriber: S
            var multiplierSubscriber: MultiplierSubscriber<S>
            
            init(upstream: Upstream, subscriber: S, splitTransform: @escaping SplitTransform) {
                self.upstream = upstream
                self.subscriber = subscriber
                self.multiplierSubscriber = MultiplierSubscriber(subscriber: subscriber, splitTransform: splitTransform)
            }
            
            func request(_ demand: Subscribers.Demand) {
                if demand > 0 {
                    upstream.receive(subscriber: multiplierSubscriber)
                }
            }
            
            func cancel() {
                multiplierSubscriber.receive(completion: .finished)
                subscriber.receive(completion: .finished)
            }
            
            
        }
        
        class MultiplierSubscriber<S: Subscriber>: Subscriber {
            
            var subscriber: S
            let splitTransform: SplitTransform
            
            init(subscriber: S, splitTransform: @escaping SplitTransform) {
                self.subscriber = subscriber
                self.splitTransform = splitTransform
            }
            
            func receive(subscription: Subscription) {
                subscription.request(.max(1))
            }
            
            func receive(_ input: Upstream.Output) -> Subscribers.Demand {
                var result = splitTransform(input, nil)
                
                while result.output != nil {
                    _ = subscriber.receive(result.output! as! S.Input)
                    result = splitTransform(input, result.conf)
                }
                
                subscriber.receive(completion: .finished)
                return .none
            }
            
            func receive(completion: Subscribers.Completion<Upstream.Failure>) {
                subscriber.receive(completion: .finished)
            }
            
            typealias Input = Upstream.Output
            typealias Failure = Upstream.Failure
            
        }
        
    }
}


public protocol Article: Codable {
    var text: String? {get set}
    var keywords: [String]? {get set}
    var categories: [String] {get set}
    var url: URL? {get set}
}


public extension Article {
    static func extractKeywords<A>(articles: [A]) -> [A] where A: Article {
        articles.compactMap { (article: A) -> A? in
            try? (UnsupervisedTextClassifier.buildKeywords(article: article) as! A)
        }
    }
}

public struct CorrelationResult {
    public var score: Double
    public var tokens: (a: Int, b: Int)
}


public struct ResultGroup: Identifiable {
    public var id = UUID()
    public var similarity: Double
    public var article: Article
    public var row: Int
}



public struct SegmentResultGroup: Identifiable {
    public var id = UUID()
    public var correlationIndex: Array<CorrelationResult>.Index
    public var tokens: (a: String, b: String)
    public var resultGroup: [ResultGroup]
}

public struct Cluster {
    public var category: String
    public var articles: [Article]
    public var keywords: [String]
    var matrix: Matrix
    var colsSum: Vector?
    var colsAvg: Vector?
    public var correlation: [CorrelationResult]?
    var q: Double?
    var maxSimilarity: Double
    
    public init(articles: [Article], category: String, maxSimilarity: Double = 0.5) {
        self.category = category
        let all_keywords = articles.map(\.keywords).reduce(Set<String>(), { prev, curr in
            var next = prev
            curr?.forEach {next.insert($0)}
            return next
        }).sorted()
        
        self.keywords = all_keywords
        self.maxSimilarity = maxSimilarity
        self.articles = articles
        self.matrix = UnsupervisedTextClassifier.buildMatrix(textsMap: articles.map {$0.keywords ?? []}, keywords: all_keywords)
    }
    
    public var publisherV2: AnyPublisher<SegmentResultGroup, Never> {
        Just(self)
            .flatMap(UnsupervisedTextClassifier.statsPublisher(result:))
            .flatMap(UnsupervisedTextClassifier.correlationMatrixPublisher(result:))
            .multiplier(UnsupervisedTextClassifier.sortingResults(result:conf:))
            .eraseToAnyPublisher()
    }
    
    public var publisher: AnyPublisher<SegmentResultGroup, Never> {
        precondition(self.correlation != nil, "Correlation was not computed")
        return Just(self)
            .multiplier(UnsupervisedTextClassifier.sortingResults(result:conf:))
            .eraseToAnyPublisher()
    }

    public var clusterPublisher: AnyPublisher<Cluster, Never> {
        Just(self)
            .flatMap(UnsupervisedTextClassifier.statsPublisher(result:))
            .flatMap(UnsupervisedTextClassifier.correlationMatrixPublisher(result:))
            .eraseToAnyPublisher()
    }
    
    public func tokenSimilarities(tokenIndex: Array<CorrelationResult>.Index) -> AnyPublisher<ResultGroup, Never> {
        Just(self)
            .flatMap {
                UnsupervisedTextClassifier.sortingResults(result:$0, tokenIndex: tokenIndex)
            }
            .eraseToAnyPublisher()
    }
}
