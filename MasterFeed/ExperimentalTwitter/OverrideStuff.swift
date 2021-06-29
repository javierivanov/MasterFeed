//import NaturalLanguage
//import LASwift
//import SigmaSwiftStatistics
//import Combine
//import os
//
//public class UnsupervisedTextClassifier {
//    
//    //public static let embeddings: NLEmbedding? = try? NLEmbedding(contentsOf: Bundle.module.url(forResource: "WordEmbedding_V1", withExtension: "mlmodelc")!)
//    
//    public init() {
//    }
//    
//    
////    MARK: extract keywords
//    public static func extractKeywords(text: String, options: [NLTag] = []) -> Set<String> {
//        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
//        tagger.string = text
//        var keywords: Set<String> = []
//        
//        
//        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames, .omitOther]
//        let staticTags: [NLTag] = [.personalName, .placeName, .organizationName]
//        
//        let lowerTags: [NLTag] = [.noun, .adjective]
//
//        let tags = staticTags + lowerTags
//        
//        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
//                             unit: .word,
//                             scheme: .nameTypeOrLexicalClass,
//                             options: options) { tag, tokenRange in
//            if let tag = tag, tags.contains(tag) {
//                keywords.insert(String(text[tokenRange]).lowercased())
//            }
//           return true
//        }
//        return keywords
//    }
//
//    // MARK: - Compute Cov
//    public static func cov(matrix: Matrix, pos: (x: Int, y: Int), colsAvg: Vector) -> Double {
//        //
//        //        Formula:
//        //            cov(x,y) = Σ(x - mx)(y - my) / n
//        
//        let Exy = zip(matrix[col: pos.x], matrix[col: pos.y]).map { $0 * $1 }.reduce(0.0, +) / Double(matrix.rows)
//
//        return Exy - colsAvg[pos.x]*colsAvg[pos.y]
//        
//    }
//    
//    //MARK: - Compute Cov
//    public static func cov(vect1: Vector, vect2: Vector, vect1Avg: Double, vect2Avg: Double) -> Double {
//        let Exy = zip(vect1, vect2).map { $0 * $1 }.reduce(0.0, +) / Double(vect1.count)
//        return Exy - vect1Avg*vect2Avg
//    }
//    
//    
//    public static func colsAvg(vector: Vector, n: Int) -> Vector {
//        vector .* (1.0/Double(n))
//    }
//    
//    public static func colAvg(vect: Vector) -> Double {
//        vect.reduce(0, +) / Double(vect.count)
//    }
//    
//    public static func std(matrix: Matrix, colsAvg: Vector, col: Int, corrected: Bool = false) -> Double {
//        let n = Double(matrix.rows - (corrected ? 0 : 1))
//        return sqrt(matrix[col: col].map {pow($0 - colsAvg[col], 2)}.reduce(0.0, +) / n)
//    }
//    
//    public static func std(vect: Vector, vectAvg: Double/*, corrected: Bool = false*/) -> Double {
//        let n = Double(vect.count)// - (corrected ? 0 : 1))
//        return sqrt(vect.map {pow($0 - vectAvg, 2.0)}.reduce(0.0, +) / n)
//    }
//    
//    
//    public static func pearson(matrix: Matrix, colsAvg: Vector, pos: (x: Int, y:Int)) -> Double {
//        Self.cov(matrix: matrix, pos: pos, colsAvg: colsAvg) / (Self.std(matrix: matrix, colsAvg: colsAvg, col: pos.x, corrected: true) * Self.std(matrix: matrix, colsAvg: colsAvg, col: pos.y, corrected: true))
//    }
//    
//    public static func pearson(vect1: Vector, vect2: Vector, vect1Avg: Double, vect2Avg: Double) -> Double {
//        let cov = self.cov(vect1: vect1, vect2: vect2, vect1Avg: vect1Avg, vect2Avg: vect2Avg)
//        let std1 = self.std(vect: vect1, vectAvg: vect1Avg)
//        let std2 = self.std(vect: vect2, vectAvg: vect2Avg)
//        return cov /  (std1 * std2)
//    }
//    
//    public static func colSum(matrix: Matrix) -> Vector {
//        sum(matrix, .Column)
//    }
//    
//    public static func q95(vector: Vector) -> Double {
//        Sigma.quantiles.method7(vector, probability: 0.95) ?? 5.0
//    }
//    
//    public static func qPercentile(vector: Vector, percentile: Double) -> Double {
//        Sigma.quantiles.method7(vector, probability: percentile)!
//    }
//    
//    
//    
//    // MARK: - Corr Matrix Old
//    
//    public static func corrMatrixOld(matrix: Matrix, colsAvg: Vector, colsSum: Vector) -> [(score:Double, tokens:(a:Int, b:Int))] {
//        print("Started filtering")
////        let idxs = colsSum.enumerated().filter {$0.element >= q}.map {$0.offset}
//        print("Filtering ended, count: \(0..<matrix.cols)")
//        var out: [(Double, (Int, Int))] = []
//        for outter in 0..<matrix.cols {
//            for inner in 0..<matrix.cols {
//                if inner > outter {
//                    out.append((Self.pearson(matrix: matrix, colsAvg: colsAvg, pos: (outter, inner)), (outter, inner)))
//                }
//            }
//        }
//        return out
//    }
//    
//    public static func filterCols(vector: Vector, cols: [Int]) -> Vector {
//        let cols_set = Set(cols)
//        return vector.enumerated()
//            .filter {cols_set.contains($0.offset)}
//            .map {$0.element}
//    }
//    
//    public static func filterCols(matrix: Matrix, cols: [Int], keywords: [String]) -> (matrix: Matrix, keywords: [String]) {
//        let cols_set = Set(cols)
//        let newKeywords: [String] = cols.map {keywords[$0]}
//        
//        let newMatrix: [Vector] = matrix.map { vect in
//            vect.enumerated()
//                .filter {cols_set.contains($0.offset)}
//                .map {$0.element}
//        }
//        
//        return (Matrix(newMatrix), newKeywords)
//    }
//    
//    
//    public static func filterRows(matrix: Matrix, cols: (x: Int, y: Int)) -> Matrix {
//        var newMatrix: [Vector] = []
//        for row in 0..<matrix.rows {
//            if matrix[row: row][cols.x] == 1 && matrix[row: row][cols.y] == 1 {
//                newMatrix.append(matrix[row: row])
//            }
//        }
//        return Matrix(newMatrix)
//    }
//    
//    public func computeNorm(matrix: Matrix) -> Vector {
//        matrix.map {vec in sqrt(vec.map {pow($0, 2)}.reduce(0.0, +))}
//    }
//    
//    public static func avgMatrixToVector(matrix: Matrix) -> Vector {
//        var out: Vector = Vector(matrix[row: 0])
//        for row in 1..<matrix.rows {
//            for col in 0..<matrix.cols {
//                out[col] += matrix[row: row][col]
//            }
//        }
//        return out.map {$0 / Double(matrix.rows)}
//    }
//    
//    
//    public func cosineSimilarity(matrix: Matrix, vector: Vector, norm_rows: Vector) -> [Double] {
//        var out:[Double] = []
//        
//        let vector_norm = sqrt(vector.map {pow($0, 2)}.reduce(0.0, +))
//        
//        for row in 0..<matrix.rows {
//            let row_result = 1.0 - (dot(matrix[row: row], vector) / (vector_norm * norm_rows[row]))
//            out.append(row_result.isNaN ? 1 : row_result)
//        }
//        
//        return out
//    }
//    
//    
//    typealias SortingClosestConf = (corrIdx: Int, rows: Set<Int>)
//    
//    // MARK: - Sorting Closests -
//    static func sortingResults(result: Cluster, conf: SortingClosestConf?) -> (conf: SortingClosestConf, output:SegmentResultGroup?) {
//        
//        var conf = conf ?? (corrIdx: 0, rows: Set(0..<result.matrix.rows))
//        let corrIdx = conf.corrIdx
//        var rows = conf.rows
//        
//        
////        print("conf.rows.count: \(conf.rows.count), corrIdx: \(corrIdx)")
//        
//        guard corrIdx < result.corrMatrix!.count - 1 && rows.count > 0 else {
//            return (conf: conf, output: nil)
//        }
//        // Target Group AVG with similar vectors.
//        let (token_x, token_y) = result.corrMatrix![corrIdx].tokens
//        let targetMatrix = Self.filterRows(matrix: result.matrix, cols: (token_x, token_y))
////        print("targetMatrix: ")
////        print("\(targetMatrix)")
//        let target_vector = Self.avgMatrixToVector(matrix: targetMatrix)
////        print("target_vector")
////        print("\(target_vector)")
//        
//        //let target_offsets = Set(target_vector.enumerated().filter {$0.element != 0.0}.map(\.offset))
//        
//        let tasks = rows.map { row -> Deferred<Future<ResultGroup,Never>> in
//            return Deferred {
//                Future() { promise in
//                    DispatchQueue.global(qos: .userInteractive).async {
//                        
//                        // Sample vector is the vector used to check if contains at least one of the previous tokens
//                        let sample_pair = result.matrix[row: row].enumerated()
//                            //.filter {target_offsets.contains($0.offset)}
//                            //.filter {$0.element != 0.0 || $0.offset == token_x || $0.offset == token_y}
//                        
//                        
//                        let sample_vector = sample_pair.map(\.element)
//                        //print("sample_vector: \(sample_vector)")
//                        
//                        let tp = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 > 0 }.count)
//                        let fp = Double(zip(target_vector, sample_vector).filter { $0 == 0.0 && $1 > 0 }.count)
//                        let fn = Double(zip(target_vector, sample_vector).filter { $0 > 0 && $1 == 0.0 }.count)
////                        let tn = Double(zip(target_vector, sample_vector).filter { $0 == 0 && $1 == 0 }.count )
//
////                        let accuracy_inv = 1.0 - (tp + tn) / (tp + tn + fp + fn)
//                        
//                        let f1_score_inv = 1.0 - (tp / (tp + (fp + fn)/2.0))
//                        
////                        let mcc_1 = ((tp * tn) - (fp * fn))
//                        
////                        let mcc_2 = sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
//                        
////                        let mcc = mcc_1 / mcc_2
//                        
//                        guard sample_vector.count > 0 else {
//                            promise(.success(ResultGroup(similarity: 1.0, article: result.articles[row], row: row)))
//                            return
//                        }
//                        
//                        let custom_target_vector = sample_pair.map {target_vector[$0.offset]}
////                        print("sample_vector \(sample_vector) - custom_target_vector \(custom_target_vector)")
//                        
//                        let custom_target_norm = sqrt(custom_target_vector.map {pow($0, 2)}.reduce(0.0, +))
//                        // recompute norm
//                        let div = custom_target_norm * sqrt(Double(sample_vector.filter {$0 > 0}.count))
//
//                        guard div > 0.0 else {
//                            promise(.success(ResultGroup(similarity: 1.0, article: result.articles[row], row: row)))
//                            return
//                        }
//
//                        
//                        let row_result =  f1_score_inv //accuracy_inv //mcc //1.0 - (dot(sample_vector, custom_target_vector) / div)
//                        
//                        let resultGroup = ResultGroup(similarity: row_result.isNaN ? 1.0 : row_result,
//                                                      article: result.articles[row],
//                                                      row: row)
//                        
//                        promise(.success(resultGroup))
//                    }
//                }
//            }
//        }
//        
//        let sema = DispatchSemaphore(value: 0)
//        
//        var ans: SegmentResultGroup?
//        
//        Publishers.MergeMany(tasks)
//            .collect()
//            .sinkStream { simils in
//                defer { sema.signal() }
//                let filteredSimils = simils.filter {$0.similarity < 0.5}
//                let correlation = result.corrMatrix![corrIdx]
//                let tokens = (a: result.keywords[correlation.tokens.a], b: result.keywords[correlation.tokens.b])
//                
//                if filteredSimils.isEmpty {
//                    if let single = simils.min(by: { $0.similarity < $1.similarity }) {
//                        ans = SegmentResultGroup(correlation: result.corrMatrix![corrIdx], tokens: tokens, resultGroup: [single])
//                        rows.remove(single.row)
//                    }
//                } else {
//                    ans = SegmentResultGroup(correlation: correlation, tokens: tokens, resultGroup: filteredSimils)
//                    filteredSimils.forEach { rows.remove($0.row) }
//                }
//                
////                if !filteredSimils.isEmpty {
////                    ans = SegmentResultGroup(correlation: correlation, tokens: tokens, resultGroup: filteredSimils)
////                    filteredSimils.forEach { rows.remove($0.row) }
////                }
//            }
//        sema.wait()
//        conf.rows = rows
//        conf.corrIdx += 1
////        print("conf.corrIdx: \(conf.corrIdx)")
//        return (conf: conf, output: ans)
//    }
//    
////    public static func computeNorm2(matrix: Matrix) -> AnyPublisher<Vector, Never> {
////
////        let tasks = matrix.enumerated().map({offset, vec -> Deferred<Future<(Int, Double), Never>> in
////            Deferred {
////                Future () { promise in
////                    DispatchQueue.global(qos: .userInitiated).async {
////                        promise(.success((offset, sqrt(vec.map {pow($0, 2)}.reduce(0.0, +)))))
////                    }
////                }
////            }
////        })
////        return Publishers.MergeMany(tasks).collect().map({ norms in
////            var output = Array<Double>(repeating: 0, count: norms.count)
////            norms.forEach { offset, val in
////                output[offset] = val
////            }
////            return output
////        }).eraseToAnyPublisher()
////    }
//    
//    
//    // MARK: - Correlation Matrix Publisher
//    static func corrMatrix(matrix: Matrix, vectAvgs: Vector) -> AnyPublisher<[CorrMatrixResult], Never> {
//        
//        var tasks: [Deferred<Future<CorrMatrixResult, Never>>] = []
//        
//        for outter in 0..<matrix.cols {
//            for inner in (outter + 1)..<matrix.cols {
//                tasks.append(Deferred {
//                    Future() { promise in
//                        DispatchQueue.global(qos: .userInteractive).async {
//                            let score = self.pearson(vect1: matrix[col: outter],
//                                                     vect2: matrix[col: inner],
//                                                     vect1Avg: matrix[col: outter].reduce(0.0, +) / Double(matrix[col: outter].count),
//                                                     vect2Avg: matrix[col: inner].reduce(0.0, +) / Double(matrix[col: inner].count))
//                            let result = CorrMatrixResult(score: score,
//                                                          tokens: (outter, inner))
//                            promise(.success(result))
//                        }
//                    }
//                })
//            }
//        }
//        return Publishers.MergeMany(tasks).collect().eraseToAnyPublisher()
//    }
//    
//    
//    // MARK: - Correlation Matrix Publisher Old
//    static func corrMatrix2(matrix: Matrix, colsAvg: Vector, colsSum: Vector) -> AnyPublisher<CorrMatrixResult, Never> {
////        print("Started new filtering")
////        let idxs = colsSum.enumerated().filter {$0.element >= q}.map {$0.offset}
////        print("Filtering ended, count: \(0..<matrix.cols)")
////        var out: [(Double, (Int, Int))] = []
//        var tasks:[Deferred<Future<CorrMatrixResult, Never>>] = []
//        for outter in 0..<matrix.cols {
//            for inner in 0..<matrix.cols {
//                if inner > outter {
//                    tasks.append(Deferred {
//                        Future() { promise in
//                            DispatchQueue.global(qos: .userInitiated).async {
//                                let result = CorrMatrixResult(score: self.pearson(matrix: matrix, colsAvg: colsAvg, pos: (outter, inner)), tokens: (outter, inner))
//                                promise(.success(result))
//                            }
//                        }
//                    })
//                }
//            }
//        }
//        return Publishers.MergeMany(tasks).eraseToAnyPublisher()
//    }
//    
////    MARK: - Build Keywords
//    public static func buildKeywords(article: Article) -> Article {
//        var keywords = extractKeywords(text: article.text!)
//        article.keywords?.forEach { keywords.insert($0.lowercased()) }
//        var newArticle = article
//        newArticle.keywords = Array(keywords)
//        return newArticle
//    }
//    
//    
//    public static func buildMatrix(textsMap: [[String]], keywords: [String]) -> Matrix {
//        
//        var keywords_list: [String: Int] = Dictionary()
//        
//        for (k, v) in keywords.enumerated() {
//            keywords_list[v] = k
//        }
//        
//        var matrix: [[Double]] = Array()
//        for text in textsMap {
//            var row = Array(repeating: 0.0, count: keywords_list.count)
//            for tag in text {
//                row[keywords_list[tag]!] = 1.0
//            }
//            matrix.append(row)
//        }
//        
//        return Matrix(matrix)
//    }
//    
//
////    MARK: - Compute Statistics
//    public static func computeStats(result: Cluster) -> AnyPublisher<Cluster, Never> {
//        let tasks = (0..<result.matrix.cols).map { col -> Deferred<Future<(col: Int, sum: Double, avg: Double), Never>> in
//            return Deferred {
//                return Future() { promise in
//                    DispatchQueue.global(qos: .userInteractive).async {
//                        let sum = sum(result.matrix[col: col])
//                        promise(.success((col, sum, sum / Double(result.matrix.rows))))
//                    }
//                }
//            }
//        }
//        // TODO: - Check issues -
//        return Publishers.MergeMany(tasks)
//            .collect()
//            .map { sums -> Cluster in
//                var colsSum = Array<Double>(repeating: 0, count: sums.count)
//                var colsAvg = Array<Double>(repeating: 0, count: sums.count)
//                sums.forEach { sum in
//                    // ISSUE HERE !!!
//                    colsSum[sum.col] = sum.sum
//                    colsAvg[sum.col] = sum.avg
//                }
//                var result = result
//                result.colsAvg = colsAvg
//                result.colsSum = colsSum
//                result.q = q95(vector: colsSum)
//                return result
//            }.eraseToAnyPublisher()
//    }
//    
//    
//    public static func computeCorrelationMatrix(result: Cluster) -> AnyPublisher<Cluster, Never> {
//
//        guard let colsSum = result.colsSum,
//              let q = result.q,
//              let colsAvg = result.colsAvg
//        else {
////            print("fail")
//            return Just(result).eraseToAnyPublisher()
//        }
//
//
//        let idxs = colsSum.enumerated().filter {$0.element >= q}.map {$0.offset}
////        print("idxs done \(idxs.count)  -  \(colsSum.count)")
//        
//        let newColsSum = filterCols(vector: colsSum, cols: idxs)
//        let newColsAvg = filterCols(vector: colsAvg, cols: idxs)
//
//        let (newMatrix, newKeywords) = filterCols(matrix: result.matrix, cols: idxs, keywords: result.keywords)
////        print("startCorr")
////
////        print(newMatrix)
////
////        print("result.matrix.rows: \(result.matrix.rows)")
////        print("newMatrix.rows: \(newMatrix.rows)")
//        
//        let computedCorrMatrix = corrMatrix(matrix: newMatrix, vectAvgs: newColsAvg)
//        return computedCorrMatrix.map {corr in
//            var result = result
//            result.corrMatrix = corr.sorted(by: {$0.score > $1.score}).filter {$0.score > 0.1}
//            result.matrix = newMatrix
//            result.keywords = newKeywords
//            result.colsSum = newColsSum
//            result.colsAvg = newColsAvg
//            return result
//        }.eraseToAnyPublisher()
//        
//    }
//    
//}
//
//
//extension Publisher {
//    func multiplier<Conf, Output>(_ splitTransform: @escaping Publishers.Multiplier<Self, Conf, Output>.SplitTransform) -> Publishers.Multiplier<Self, Conf, Output> {
//        Publishers.Multiplier(upstream: self, splitTransform: splitTransform)
//    }
//    
//    func sinkStream(_ callback: @escaping (Self.Output) -> Void) where Failure: Error {
//        self.receive(subscriber: Subscribers.SinkCollection<Self.Output, Self.Failure>(callback))
//    }
//}
//
//
//extension Subscribers {
//    final class SinkCollection<Input, Failure>: Subscriber where Failure : Error {
//        
//        let callback: (Input) -> Void
//        var subscription: Subscription?
//        
//        init(_ callback: @escaping (Input) -> Void) {
//            self.callback = callback
//        }
//        
//        func receive(subscription: Subscription) {
//            self.subscription = subscription
//            subscription.request(.unlimited)
//        }
//        
//        func receive(_ input: Input) -> Subscribers.Demand {
//            callback(input)
//            return .unlimited
//        }
//        
//        func receive(completion: Subscribers.Completion<Failure>) {
//        }
//    }
//}
//
//extension Publishers {
//    
//    struct Multiplier<Upstream, Conf, Output>: Publisher where Upstream: Publisher {
//        
//        typealias Output = Output
//        typealias Failure = Upstream.Failure
//        typealias SplitTransform = (Upstream.Output, Conf?) -> (conf: Conf, output: Output?)
//        
//        private let upstream: Upstream
//        
//        let splitTransform: SplitTransform
//        
//        init(upstream: Upstream, splitTransform: @escaping SplitTransform) {
//            self.upstream = upstream
//            self.splitTransform = splitTransform
//        }
//        
//        func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Output == S.Input {
//            let subscription = MultiplierSubscription<S>(upstream: self.upstream, subscriber: subscriber, splitTransform: splitTransform)
//            subscriber.receive(subscription: subscription)
//        }
//        
//        final class MultiplierSubscription<S: Subscriber>: Subscription {
//            
//            var upstream: Upstream
//            var subscriber: S
//            var multiplierSubscriber: MultiplierSubscriber<S>
//            
//            init(upstream: Upstream, subscriber: S, splitTransform: @escaping SplitTransform) {
//                self.upstream = upstream
//                self.subscriber = subscriber
//                self.multiplierSubscriber = MultiplierSubscriber(subscriber: subscriber, splitTransform: splitTransform)
//            }
//            
//            func request(_ demand: Subscribers.Demand) {
//                if demand > 0 {
//                    upstream.receive(subscriber: multiplierSubscriber)
//                }
//            }
//            
//            func cancel() {
//                multiplierSubscriber.receive(completion: .finished)
//                subscriber.receive(completion: .finished)
//            }
//            
//            
//        }
//        
//        class MultiplierSubscriber<S: Subscriber>: Subscriber {
//            
//            var subscriber: S
//            let splitTransform: SplitTransform
//            
//            init(subscriber: S, splitTransform: @escaping SplitTransform) {
//                self.subscriber = subscriber
//                self.splitTransform = splitTransform
//            }
//            
//            func receive(subscription: Subscription) {
//                subscription.request(.max(1))
//            }
//            
//            func receive(_ input: Upstream.Output) -> Subscribers.Demand {
//                var result = splitTransform(input, nil)
//                
//                while result.output != nil {
//                    _ = subscriber.receive(result.output! as! S.Input)
//                    result = splitTransform(input, result.conf)
//                }
//                
//                subscriber.receive(completion: .finished)
//                return .none
//            }
//            
//            func receive(completion: Subscribers.Completion<Upstream.Failure>) {
//                subscriber.receive(completion: .finished)
//            }
//            
//            typealias Input = Upstream.Output
//            typealias Failure = Upstream.Failure
//            
//        }
//        
//    }
//}
//
//
//public protocol Article: Codable {
//    var text: String? {get set}
//    var keywords: [String]? {get set}
//    var filterKeywords: Set<String>? {get set}
//    var url: URL? {get set}
//}
//
//
//extension Article {
//    static func extractKeywords<A>(articles: [A]) -> [A] where A: Article {
//        articles.map { (article: A) -> A in
//            UnsupervisedTextClassifier.buildKeywords(article: article) as! A
//        }
//    }
//}
//
//public struct CorrMatrixResult {
//    var score: Double
//    var tokens: (a: Int, b: Int)
//}
//
//
//public struct ResultGroup: Identifiable {
//    public var id = UUID()
//    var similarity: Double
//    var article: Article
//    var row: Int
//}
//
////public typealias CorrMatrixResult = (score:Double, tokens:(a:Int, b:Int))
////public typealias ResultGroup = (similarity: Double, article: Article, row: Int)
//
//public struct SegmentResultGroup: Identifiable {
//    public var id = UUID()
//    public var correlation: CorrMatrixResult
//    public var tokens: (a: String, b: String)
//    public var resultGroup: [ResultGroup]
//}
//
//public struct Cluster {
//    
//    public var articles: [Article]
//    public var keywords: [String]
//    var matrix: Matrix
//    var colsSum: Vector?
//    var colsAvg: Vector?
//    public var corrMatrix: [CorrMatrixResult]?
//    var q: Double?
//    
//    init(articles: [Article]) {
//        let all_keywords = articles.map(\.keywords).reduce(Set<String>(), { prev, curr in
//            var next = prev
//            curr?.forEach {next.insert($0)}
//            return next
//        }).sorted()
//        
//        // Review empty articles
//        let matrix = UnsupervisedTextClassifier.buildMatrix(textsMap: articles.map {$0.keywords ?? []}, keywords: all_keywords)
////        print("matrix.rows: \(matrix.rows)")
//        self.articles = articles
//        self.matrix = matrix
//        self.keywords = all_keywords
//    }
//    
//    public var publisher: AnyPublisher<SegmentResultGroup, Never> {
//        Just(self)
//            .flatMap(UnsupervisedTextClassifier.computeStats(result:))
//            .flatMap(UnsupervisedTextClassifier.computeCorrelationMatrix(result:))
//            .multiplier(UnsupervisedTextClassifier.sortingResults(result:conf:))
//            .eraseToAnyPublisher()
//    }
//}
