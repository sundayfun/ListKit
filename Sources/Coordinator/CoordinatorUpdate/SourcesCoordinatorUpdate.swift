//
//  SourcesCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/12.
//

import Foundation

final class SourcesCoordinatorChange<SourceBase: DataSource, Source: RangeReplaceableCollection>:
    CoordinatorChange<SourceElement<Source.Element>>
where
    SourceBase.SourceBase == SourceBase,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    typealias Subupdate = CoordinatorUpdate<Source.Element.SourceBase>
    
    var update = UpdateContextCache(value: nil as CoordinatorUpdate<Source.Element.SourceBase>?)
    
    func update(_ isSource: Bool, _ id: ObjectIdentifier?) -> Subupdate {
        self.update[id] ?? {
            let update = value.coordinator.update(isSource ? .remove : .insert)
            self.update[nil] = update
            return update
        }()
    }
}

enum SourcesChange<SourceBase: DataSource, Source: RangeReplaceableCollection>
where
    SourceBase.SourceBase == SourceBase,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    typealias Subupdate = CoordinatorUpdate<Source.Element.SourceBase>
    
    case update(Int, SourceElement<Source.Element>, Subupdate)
    case change(SourcesCoordinatorChange<SourceBase, Source>, isSource: Bool)
}

final class SourcesCoordinatorUpdate<SourceBase: DataSource, Source: RangeReplaceableCollection>:
    DiffableCoordinatgorUpdate<
        SourceBase,
        Source,
        SourceElement<Source.Element>,
        SourcesCoordinatorChange<SourceBase, Source>,
        SourcesChange<SourceBase, Source>
    >
where
    SourceBase.SourceBase == SourceBase,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    typealias Coordinator = SourcesCoordinator<SourceBase, Source>
    typealias CoordinatorChange = SourcesCoordinatorChange<SourceBase, Source>
    typealias Change = SourcesChange<SourceBase, Source>
    typealias Subsource = Coordinator.Subsource
    typealias Subupdate = CoordinatorUpdate<Element.SourceBase>
    typealias Subcoordinator = ListCoordinator<Element.SourceBase>
    
    weak var coordinator: Coordinator?
    
    var indices: Mapping<Indices>
    var subupdates = [() -> Void]()
    
    lazy var offsetForOrder = UpdateContextCache(value: [Order: [ObjectIdentifier: Int]]())
    
    override var diffable: Bool { true }
    override var equaltable: Bool { true }
    override var identifiable: Bool { true }
    override var rangeReplacable: Bool { true }
    
    init(
        coordinator: Coordinator,
        update: ListUpdate<SourceBase>,
        values: Values,
        sources: Sources,
        indices: Mapping<Indices>,
        keepSectionIfEmpty: Mapping<Bool>,
        isSectioned: Bool
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator, update: update, values, sources, keepSectionIfEmpty)
        self.isSectioned = isSectioned
    }
    
    override func getSourceCount() -> Int { indices.source.count }
    override func getTargetCount() -> Int { indices.target.count }
    
    override func toCount(_ value: Subsource) -> Int { value.count }
    override func toValue(_ element: Element) -> Subsource {
        let coordinator = element.listCoordinator
        let context = coordinator.context()
        let count = isSectioned ? context.numbersOfSections() : context.numbersOfItems(in: 0)
        return .init(element: .element(element), context: context, offset: 0, count: count)
    }
    
    override func toChange(_ change: CoordinatorChange, _ isSource: Bool) -> Change {
        .change(change, isSource: isSource)
    }
    
    override func append(change: CoordinatorChange, isSource: Bool, to changes: inout Changes) {
        super.append(change: change, isSource: isSource, to: &changes)
        guard change.associated[nil] == nil else { return }
        changes[keyPath: path(!isSource)].append(.change(.change(change, isSource: isSource)))
    }
    
    override func append(from: Mapping<Int>, to: Mapping<Int>, to changes: inout Changes) {
        for (s, t) in zip(from.source..<to.source, from.target..<to.target) {
            let source = values.source[s], target = values.target[t]
            let update = target.coordinator.update(from: source.coordinator, differ: differ)
            changes.source.append(.change(.update(t, target, update)))
            changes.target.append(.change(.update(t, target, update)))
        }
    }
    
    override func inferringMoves(context: Context? = nil) {
        super.inferringMoves(context: context)
        let context = context ?? defaultContext
        changes.source.forEach {
            switch $0 {
            case let .change(.change(change, isSource: isSource)) where change[nil] == nil:
                change.update(isSource, context.id).inferringMoves(context: context)
            case let .change(.update(_, _, update)):
                update.inferringMoves(context: context)
            default:
                break
            }
        }
    }
    
    override func updateData(isSource: Bool) {
        super.updateData(isSource: isSource)
        coordinator?.subsources = isSource ? values.source : values.target
        coordinator?.indices = isSource ? indices.source : indices.target
    }
    
    override func isEqual(lhs: Subsource, rhs: Subsource) -> Bool {
        let related = lhs.context
        switch (lhs.element, rhs.element) {
        case let (.element(lhs), .element(rhs)):
            return related.coordinator.equal(lhs: lhs.sourceBase, rhs: rhs.sourceBase)
        case let (.items(lhs, _), .items(rhs, _)):
            return lhs == rhs
        default:
            return false
        }
    }
    
    override func identifier(for value: Subsource) -> AnyHashable {
        switch value.element {
        case .element(let element):
            return HashCombiner(0, value.coordinator.identifier(for: element.sourceBase))
        case .items(let id, _):
            return HashCombiner(1, id)
        }
    }
    
    override func isDiffEqual(lhs: Subsource, rhs: Subsource) -> Bool {
        guard identifier(for: lhs) == identifier(for: rhs) else { return false }
        return isEqual(lhs: lhs, rhs: rhs)
    }
    
    override func configChangeAssociated(
        for mapping: Mapping<CoordinatorChange>,
        context: (context: CoordinatorUpdateContext, id: ObjectIdentifier)?
    ) {
        let source = mapping.source.value.coordinator
        let target = mapping.target.value.coordinator
        let update = target.update(from: source, differ: differ)
        mapping.source.update[context?.id] = update
        mapping.target.update[context?.id] = update
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        guard isSectioned else {
            return super.generateSourceSectionUpdate(order: order, context: context)
        }
        return sourceUpdate(order, in: context, \.section, Subupdate.generateSourceSectionUpdate)
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        guard isSectioned else {
            return super.generateTargetSectionUpdate(order: order, context: context)
        }
        return targetUpdate(order, in: context, \.section, Subupdate.generateTargetSectionUpdate)
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        sourceUpdate(order, in: context, \.self, Subupdate.generateSourceItemUpdate)
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        targetUpdate(order, in: context, \.self, Subupdate.generateTargetItemUpdate)
    }
}

extension SourcesCoordinatorUpdate {
    func subsource<Subsource: UpdatableDataSource>(
        _ source: Subsource,
        update: ListUpdate<Subsource.SourceBase>,
        animated: Bool? = nil,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        subupdates.append { source.perform(update, animated: animated, completion: completion) }
    }
    
    func sourceUpdate<Collection: UpdateIndexCollection, Result: BatchUpdate, O>(
        _ order: Order,
        in context: UpdateContext<O>?,
        _ keyPath: WritableKeyPath<Result, BatchUpdates.Source<Collection>>,
        _ toSubUpdate: (Subupdate) -> (Order, UpdateContext<O>?) -> UpdateSource<Result>
    ) -> UpdateSource<Result> where Collection.Element == O {
        if notUpdate(order, context) { return (targetCount, nil) }
        var count = 0, offsets = [ObjectIdentifier: Int](), result = Result()
        var offset: O { .init(context?.offset, offset: count) }
        
        defer { offsetForOrder[context?.id][order] = offsets }
        
        func add(value: Subsource) {
            if value.count == 0 { return }
            count += value.count
        }
        
        func add(_ update: Subupdate, isMoved: Bool) {
            let subcontext = toContext(context, isMoved, or: .zero) { $0.offseted(count) }
            let (subcount, subupdate) = toSubUpdate(update)(order, subcontext)
            offsets[ObjectIdentifier(update)] = count
            count += subcount
            subupdate.map { result.add($0) }
        }
        
        func reload(from value: Subsource, to other: Subsource) {
            let (diff, minValue) = (value.count - other.count, min(value.count, other.count))
            count += value.count
            if minValue > 0 {
                result[keyPath: keyPath].add(\.reloads, offset, offset.offseted(minValue))
            }
            if diff > 0 {
                let upper = offset.offseted(value.count)
                result[keyPath: keyPath].add(\.deletes, upper.offseted(-diff), upper)
            }
        }
        
        func configChange(_ change: CoordinatorChange) {
            configCoordinatorChange(
                change,
                context: context,
                enumrateChange: { change in
                    context.map { change.offsets[$0.id] = (offset.section, offset.item) }
                },
                deleteOrInsert: { change in
                    add(change.update(true, context?.id), isMoved: false)
                },
                reload: { (change, associated) in
                    if isMain(order) {
                        reload(from: change.value, to: associated.value)
                    } else {
                        add(value: associated.value)
                    }
                },
                move: { change, associated, isReload in
                    guard isReload else {
                        let moved = isMain(order), update = change.update(true, context?.id)
                        add(update, isMoved: moved)
                        return
                    }
                    if isMain(order) {
                        updateMaxIfNeeded(order, context, isSectioned)
                        offsets[ObjectIdentifier(associated)] = count
                        add(value: change.value)
                        if change.value.count == 0 { return }
                        result[keyPath: keyPath].move(offset, offset.offseted(change.value.count))
                    } else if isExtra(order) {
                        reload(from: change.value, to: associated.value)
                    } else {
                        add(value: associated.value)
                    }
                }
            )
        }
        
        func config(value: ChangeOrUnchanged) {
            switch value {
            case let .change(.change(change, isSource: isSource)):
                if isSource {
                    configChange(change)
                } else {
                    add(change.update(false, context?.id), isMoved: false)
                }
            case let .change(.update(_, _, update)):
                add(update, isMoved: false)
            case let .unchanged(from: from, to: to):
                guard context?.isMoved != true else { fatalError("TODO") }
                (from.source..<to.source).forEach { add(value: values.source[$0]) }
            }
        }
        
        if isMain(order) {
            changes.source.forEach(config(value:))
        } else {
            changes.target.forEach(config(value:))
        }
        
        return (count, result)
    }
    
    func targetUpdate<Collection: UpdateIndexCollection, Result: BatchUpdate, O>(
        _ order: Order,
        in context: UpdateContext<Offset<O>>?,
        _ keyPath: WritableKeyPath<Result, BatchUpdates.Target<Collection>>,
        _ toSubresult: (Subupdate) -> (Order, UpdateContext<Offset<O>>?) -> UpdateTarget<Result>
    ) -> UpdateTarget<Result> where Collection.Element == O {
        if notUpdate(order, context) { return (toIndices(indices.target, context), nil, nil) }
        var subsources = ContiguousArray<Subsource>(capacity: values.target.count)
        var indices = Indices(capacity: self.indices.source.count)
        var result = Result(), change: (() -> Void)?, index = 0
        var offset: O { .init(context?.offset.offset.target, offset: indices.count) }
        let offsets = offsetForOrder[context?.id][order]!
        
        func add(value: Subsource) {
            let value = value.setting(offset: indices.count)
            subsources.append(value)
            indices.append(repeatElement: (index, false), count: value.count)
            index += 1
        }
        
        func add(value: Subsource, update: Subupdate, isMoved: Bool) {
            guard let o = offsets[ObjectIdentifier(update)] else { return }
            let subcontext = toContext(context, isMoved, or: (0, (.zero, .zero))) {
                (index, ($0.offset.source.offseted(o), $0.offset.source.offseted(indices.count)))
            }
            let (subindices, subupdate, subchange) = toSubresult(update)(order, subcontext)
            subsources.append(value.setting(offset: indices.count, count: subindices.count))
            subupdate.map { result.add($0) }
            change = change + subchange
            index += 1
            indices.append(contentsOf: subindices)
            updateMaxIfNeeded(update, context, subcontext)
        }
        
        func reload(from other: Subsource, to value: Subsource) {
            let diff = value.count - other.count, minValue = min(other.count, value.count)
            subsources.append(value.setting(offset: indices.count))
            if minValue != 0 {
                result[keyPath: keyPath].reload(offset, offset.offseted(minValue))
            }
            if diff > 0 {
                let upper = offset.offseted(value.count)
                result[keyPath: keyPath].add(\.inserts, upper.offseted(-diff), upper)
            }
            indices.append(repeatElement: (index, false), count: value.count)
            index += 1
        }
        
        func configChange(_ change: CoordinatorChange) {
            configCoordinatorChange(
                change,
                context: context,
                enumrateChange: { change in
                    guard let ((_, (_, target)), _, id) = context else { return }
                    change.offsets[id] = (target.section, target.item)
                },
                deleteOrInsert: { change in
                    let update = change.update(false, context?.id)
                    add(value: change.value, update: update, isMoved: false)
                },
                reload: { change, associated in
                    if isMain(order) {
                        reload(from: associated.value, to: change.value)
                    } else {
                        add(value: change.value)
                    }
                },
                move: { change, associated, isReload in
                    guard isReload else {
                        let moved = isMain(order), update = change.update(false, context?.id)
                        add(value: change.value, update: update, isMoved: moved)
                        return
                    }
                    if isMain(order) {
                        add(value: associated.value)
                        let count = associated.value.count
                        guard count != 0, let o = offsets[ObjectIdentifier(change)] else { return }
                        let source = O(context?.offset.offset.source, offset: o)
                        result[keyPath: keyPath].move(
                            (source, offset),
                            (source.offseted(count), offset.offseted(count))
                        )
                    } else if isExtra(order) {
                        reload(from: associated.value, to: change.value)
                    } else {
                        add(value: change.value)
                    }
                }
            )
        }
        
        for value in changes.target {
            switch value {
            case let .change(.change(change, isSource: isSource)):
                if isSource {
                    let update = change.update(false, context?.id)
                    add(value: change.value, update: update, isMoved: false)
                } else {
                    configChange(change)
                }
            case let .change(.update(_, value, update)):
                let value = value.setting(offset: indices.count)
                add(value: value, update: update, isMoved: false)
            case let .unchanged(from: from, to: to):
                guard context?.isMoved != true else { fatalError("TODO") }
                (from.source..<to.source).forEach { add(value: values.target[$0]) }
            }
        }
        
        if hasNext(order, context) {
            let source = Source(subsources.flatMap { subsource -> ContiguousArray<Element> in
                switch subsource.element {
                case let .items(_, items):
                    return items()
                case let .element(element):
                    return [element]
                }
            })
            
            
            change = change + { [unowned self] in
                self.coordinator?.set(source: source, values: subsources, indices: indices)
            }
        } else {
            change = change + finalChange
        }
        
        return (toIndices(indices, context), result, change)
    }
}