import Foundation

// https://stackoverflow.com/questions/41552754/swift-create-a-multi-function-multicast-delegate
class MulticastDelegate <T>: NSObject {
    internal let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    func add(delegate: T) {
        guard !delegates.contains(delegate as AnyObject) else { return }
        delegates.add(delegate as AnyObject)
    }

    func remove(delegate: T) {
        for oneDelegate in delegates.allObjects.reversed() where oneDelegate === delegate as AnyObject {
            delegates.remove(oneDelegate)
        }
    }

    internal func invoke(invocation: (T) -> Void) {
        for delegate in delegates.allObjects.reversed() {
            guard let delegateT = delegate as? T else { return }
            invocation(delegateT)
        }
    }
}

func += <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
    left.add(delegate: right)
}

func -= <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
    left.remove(delegate: right)
}
