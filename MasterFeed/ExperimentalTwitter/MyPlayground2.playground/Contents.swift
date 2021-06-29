import Combine
import Foundation


var data = [1,2,3,4,5].shuffled()

class SampleSubs: Subscriber {
    
    typealias Input = Int
    typealias Failure = Never
    var subscription: Subscription?
    
    var data:[Int] = []
    
    func receive(subscription: Subscription) {
        print(subscription)
        self.subscription = subscription
        self.subscription?.request(.unlimited)
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        data.append(input)
        print(input)
        return Subscribers.Demand.unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Done :D")
    }
    
}

var sampleSub = SampleSubs()

Just(data).flatMap { da -> AnyPublisher<Int, Never> in
    let tasks = da.map { d -> Deferred<Future<Int, Never>> in
        return Deferred {
            Future() { promise in
                DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(d)), execute: {
                    return promise(.success(d))
                })
            }
        }
    }
    return Publishers.MergeMany(tasks).eraseToAnyPublisher()
}
.subscribe(sampleSub)

