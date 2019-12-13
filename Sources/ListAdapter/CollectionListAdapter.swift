//
//  CollectionListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/11/23.
//

public protocol CollectionListAdapter: ScrollListAdapter {
    var collectionList: CollectionList<SourceBase> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct CollectionList<Source: DataSource>: CollectionListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public var collectionList: CollectionList<Source> { self }
    public func makeListCoordinator() -> ListCoordinator<Source> {
        addToStorage(source.makeListCoordinator())
    }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
}

extension DataSource {
    func toCollectionList() -> CollectionList<SourceBase> {
        let collectionList = CollectionList(source: sourceBase)
        collectionList.coordinatorStorage.coordinator = listCoordinator
        return collectionList
    }
}

extension CollectionListAdapter {
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionContext<SourceBase>, Input)) -> Output
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        let coordinator = collectionList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return collectionList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionContext<SourceBase>, Input)) -> Void
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        let coordinator = collectionList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return collectionList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionSectionContext<SourceBase>, Input)) -> Output
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        let coordinator = collectionList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return collectionList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionSectionContext<SourceBase>, Input)) -> Void
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        let coordinator = collectionList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return collectionList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionItemContext<SourceBase>, Input)) -> Output
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        let coordinator = collectionList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return collectionList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionItemContext<SourceBase>, Input)) -> Void
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        let coordinator = collectionList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return collectionList
    }
}
