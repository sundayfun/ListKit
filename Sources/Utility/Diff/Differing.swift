//
//  Differing.swift
//  Difference
//
//  Created by Frain on 2019/3/17.
//

extension CollectionDifference {
    fileprivate func _fastEnumeratedApply(
        _ consume: (Change) throws -> Void
    ) rethrows {
        let totalRemoves = removals.count
        let totalInserts = insertions.count
        var enumeratedRemoves = 0
        var enumeratedInserts = 0
        
        while enumeratedRemoves < totalRemoves || enumeratedInserts < totalInserts {
            let change: Change
            if enumeratedRemoves < removals.count && enumeratedInserts < insertions.count {
                let removeOffset = removals[enumeratedRemoves]._offset
                let insertOffset = insertions[enumeratedInserts]._offset
                if removeOffset - enumeratedRemoves <= insertOffset - enumeratedInserts {
                    change = removals[enumeratedRemoves]
                } else {
                    change = insertions[enumeratedInserts]
                }
            } else if enumeratedRemoves < totalRemoves {
                change = removals[enumeratedRemoves]
            } else if enumeratedInserts < totalInserts {
                change = insertions[enumeratedInserts]
            } else {
                // Not reached, loop should have exited.
                preconditionFailure()
            }
            
            try consume(change)
            
            switch change {
            case .remove(_, _, _):
                enumeratedRemoves += 1
            case .insert(_, _, _):
                enumeratedInserts += 1
            }
        }
    }
}

// Error type allows the use of throw to unroll state on application failure
private enum _ApplicationError : Error { case failed }

extension RangeReplaceableCollection {
    /// Applies the given difference to this collection.
    ///
    /// - Parameter difference: The difference to be applied.
    ///
    /// - Returns: An instance representing the state of the receiver with the
    ///   difference applied, or `nil` if the difference is incompatible with
    ///   the receiver's state.
    ///
    /// - Complexity: O(*n* + *c*), where *n* is `self.count` and *c* is the
    ///   number of changes contained by the parameter.
    public func applying(_ difference: CollectionDifference<Element>) -> Self? {
        
        func append(
            into target: inout Self,
            contentsOf source: Self,
            from index: inout Self.Index, count: Int
        ) throws {
            let start = index
            if !source.formIndex(&index, offsetBy: count, limitedBy: source.endIndex) {
                throw _ApplicationError.failed
            }
            target.append(contentsOf: source[start..<index])
        }
        
        var result = Self()
        do {
            var enumeratedRemoves = 0
            var enumeratedInserts = 0
            var enumeratedOriginals = 0
            var currentIndex = self.startIndex
            try difference._fastEnumeratedApply { change in
                switch change {
                case .remove(offset: let offset, element: _, associatedWith: _):
                    let origCount = offset - enumeratedOriginals
                    try append(into: &result, contentsOf: self, from: &currentIndex, count: origCount)
                    if currentIndex == self.endIndex {
                        // Removing nonexistent element off the end of the collection
                        throw _ApplicationError.failed
                    }
                    enumeratedOriginals += origCount + 1 // Removal consumes an original element
                    currentIndex = self.index(after: currentIndex)
                    enumeratedRemoves += 1
                case .insert(offset: let offset, element: let element, associatedWith: _):
                    let origCount = (offset + enumeratedRemoves - enumeratedInserts) - enumeratedOriginals
                    try append(into: &result, contentsOf: self, from: &currentIndex, count: origCount)
                    result.append(element)
                    enumeratedOriginals += origCount
                    enumeratedInserts += 1
                }
            }
            if currentIndex < self.endIndex {
                result.append(contentsOf: self[currentIndex...])
            }
        } catch {
            return nil
        }
        
        return result
    }
}

// MARK: Definition of API
public extension CollectionDifference {
    init<From: BidirectionalCollection, To: BidirectionalCollection>(
        from: From, to: To,
        by areEquivalent: (ChangeElement, ChangeElement) -> Bool
    ) where From.Element == ChangeElement, To.Element == ChangeElement {
        self = _myers(from: from, to: to, using: areEquivalent)
    }
}

public extension CollectionDifference where ChangeElement: Equatable {
    init<From: BidirectionalCollection, To: BidirectionalCollection>(
        from: From, to: To
    ) where From.Element == ChangeElement, To.Element == ChangeElement {
        self = _myers(from: from, to: to, using: ==)
    }
}

// MARK: Internal implementation

// _V is a rudimentary type made to represent the rows of the triangular matrix type used by the Myer's algorithm
//
// This type is basically an array that only supports indexes in the set `stride(from: -d, through: d, by: 2)` where `d` is the depth of this row in the matrix
// `d` is always known at allocation-time, and is used to preallocate the structure.
fileprivate struct _V {
    
    private var a: [Int]
    
    // The way negative indexes are implemented is by interleaving them in the empty slots between the valid positive indexes
    @inline(__always) private static func transform(_ index: Int) -> Int {
        // -3, -1, 1, 3 -> 3, 1, 0, 2 -> 0...3
        // -2, 0, 2 -> 2, 0, 1 -> 0...2
        return (index <= 0 ? -index : index &- 1)
    }
    
    init(maxIndex largest: Int) {
        a = [Int](repeating: 0, count: largest + 1)
    }
    
    subscript(index: Int) -> Int {
        get {
            return a[_V.transform(index)]
        }
        set(newValue) {
            a[_V.transform(index)] = newValue
        }
    }
}

fileprivate func _myers<C,D>(
    from old: C, to new: D,
    using cmp: (C.Element, D.Element) -> Bool
) -> CollectionDifference<C.Element>
    where
    C: BidirectionalCollection,
    D: BidirectionalCollection,
    C.Element == D.Element
{
    // Core implementation of the algorithm described at http://www.xmailserver.org/diff2.pdf
    // Variable names match those used in the paper as closely as possible
    func _descent(from a: UnsafeBufferPointer<C.Element>, to b: UnsafeBufferPointer<D.Element>) -> [_V] {
        let n = a.count
        let m = b.count
        let max = n + m
        
        var result = [_V]()
        var v = _V(maxIndex: 1)
        v[1] = 0
        
        var x = 0
        var y = 0
        iterator: for d in 0...max {
            let prev_v = v
            result.append(v)
            v = _V(maxIndex: d)
            
            // The code in this loop is _very_ hot—the loop bounds increases in terms
            // of the iterator of the outer loop!
            for k in stride(from: -d, through: d, by: 2) {
                if k == -d {
                    x = prev_v[k &+ 1]
                } else {
                    let km = prev_v[k &- 1]
                    
                    if k != d {
                        let kp = prev_v[k &+ 1]
                        if km < kp {
                            x = kp
                        } else {
                            x = km &+ 1
                        }
                    } else {
                        x = km &+ 1
                    }
                }
                y = x &- k
                
                while x < n && y < m {
                    if !cmp(a[x], b[y]) {
                        break;
                    }
                    x &+= 1
                    y &+= 1
                }
                
                v[k] = x
                
                if x >= n && y >= m {
                    break iterator
                }
            }
            if x >= n && y >= m {
                break
            }
        }
        
        return result
    }
    
    // Backtrack through the trace generated by the Myers descent to produce the changes that make up the diff
    func _formChanges(
        from a: UnsafeBufferPointer<C.Element>,
        to b: UnsafeBufferPointer<C.Element>,
        using trace: [_V]
    ) -> [CollectionDifference<C.Element>.Change] {
        var changes = [CollectionDifference<C.Element>.Change]()
        changes.reserveCapacity(trace.count)
        
        var x = a.count
        var y = b.count
        for d in stride(from: trace.count &- 1, to: 0, by: -1) {
            let v = trace[d]
            let k = x &- y
            let prev_k = (k == -d || (k != d && v[k &- 1] < v[k &+ 1])) ? k &+ 1 : k &- 1
            let prev_x = v[prev_k]
            let prev_y = prev_x &- prev_k
            
            while x > prev_x && y > prev_y {
                // No change at this position.
                x &-= 1
                y &-= 1
            }
            
            if y != prev_y {
                changes.append(.insert(offset: prev_y, element: b[prev_y], associatedWith: nil))
            } else {
                changes.append(.remove(offset: prev_x, element: a[prev_x], associatedWith: nil))
            }
            
            x = prev_x
            y = prev_y
        }
        
        return changes
    }
    
    /* Splatting the collections into contiguous storage has two advantages:
     *
     *   1) Subscript access is much faster
     *   2) Subscript index becomes Int, matching the iterator types in the algorithm
     *
     * Combined, these effects dramatically improves performance when
     * collections differ significantly, without unduly degrading runtime when
     * the parameters are very similar.
     *
     * In terms of memory use, the linear cost of creating a ContiguousArray (when
     * necessary) is significantly less than the worst-case n² memory use of the
     * descent algorithm.
     */
    func _withContiguousStorage<C: Collection, R>(
        for values: C,
        _ body: (UnsafeBufferPointer<C.Element>) throws -> R
    ) rethrows -> R {
        if let result = try values.withContiguousStorageIfAvailable(body) { return result }
        let array = ContiguousArray(values)
        return try array.withUnsafeBufferPointer(body)
    }
    
    return _withContiguousStorage(for: old) { a in
        return _withContiguousStorage(for: new) { b in
            return CollectionDifference(_formChanges(from: a, to: b, using:_descent(from: a, to: b)))!
        }
    }
}
