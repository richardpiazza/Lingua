import Combine
import Foundation

final class SubscriptionContainer<Key: Hashable, Value: Identifiable> {
    
    private class Tracker {
        let subject: CurrentValueSubject<[Value], Never> = CurrentValueSubject([])
        var subscribers: Int = 0
    }
    
    let sort: any SortComparator<Value>
    private var content: [Key: Tracker] = [:]
    
    init(sort: any SortComparator<Value>) {
        self.sort = sort
    }
    
    private func beginSubscription(_ key: Key) {
        guard let tracker = content[key] else {
            return
        }
        
        tracker.subscribers += 1
    }
    
    private func terminateSubscription(_ key: Key) {
        guard let tracker = content[key] else {
            return
        }
        
        tracker.subscribers -= 1
        
        guard tracker.subscribers <= 0 else {
            return
        }
        
        content[key] = nil
    }
    
    func publisher(for key: Key, initialContent: (() -> [Value])? = nil) -> AnyPublisher<[Value], Never> {
        let tracker: Tracker
        
        if let existing = content[key] {
            tracker = existing
        } else {
            let new = Tracker()
            tracker = new
            content[key] = new
            
            if let initialContent {
                new.subject.value = initialContent().sorted(using: sort)
            }
        }
        
        return tracker
            .subject
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.beginSubscription(key)
                },
                receiveCancel: { [weak self] in
                    self?.terminateSubscription(key)
                }
            )
            .eraseToAnyPublisher()
    }
    
    func addValue(_ value: Value, for key: Key) {
        guard let tracker = content[key] else {
            return
        }
        
        var values = tracker.subject.value
        values.append(value)
        tracker.subject.value = values.sorted(using: sort)
    }
    
    func updateValue(_ value: Value, for key: Key) {
        guard let tracker = content[key] else {
            return
        }
        
        var values = tracker.subject.value
        guard let index = values.firstIndex(where: { $0.id == value.id }) else {
            return
        }
        
        values[index] = value
        tracker.subject.value = values.sorted(using: sort)
    }
    
    func removeValue(with id: Value.ID) {
        for (_, tracker) in content {
            var values = tracker.subject.value
            if let index = values.firstIndex(where: { $0.id == id }) {
                values.remove(at: index)
                tracker.subject.value = values
            }
        }
    }
}
