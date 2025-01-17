//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/16.
//

import Foundation

protocol ListAdapter: UpdatableDataSource where Source == SourceBase {
    associatedtype View: AnyObject
    associatedtype ViewDelegates: AnyObject
    associatedtype Erased
    
    var source: Source { get nonmutating set}
    var storage: ListAdapterStorage<Source> { get }
    var erasedGetter: (Self, ListOptions) -> Erased { get }
    static var defaultErasedGetter: (Self, ListOptions) -> Erased { get }
    static var rootKeyPath: ReferenceWritableKeyPath<CoordinatorContext, ViewDelegates> { get }
    
    init(
        listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void],
        source: Source,
        erasedGetter: @escaping (Self, ListOptions) -> Erased
    )
}

final class ListAdapterStorage<Source: DataSource> where Source.SourceBase == Source {
    var source: Source
    var makeListCoordinator: () -> ListCoordinator<Source> = { fatalError() }
    
    lazy var listCoordinator = makeListCoordinator()
    lazy var coordinatorStorage = listCoordinator.storage.or(.init())
    
    init(source: Source) {
        self.source = source
    }
}

extension ListAdapter
where Erased: ListAdapter, Erased.Source == AnySources, Erased.Erased == Erased {
    static var defaultErasedGetter: (Self, ListOptions) -> Erased {
        {
            .init(AnySources($0, options: $1)) { source, options in
                source.source = AnySources(anySources: source.source, options: options)
                return source
            }
        }
    }
}

extension ListAdapter {
    init<OtherSource: DataSource>(
        _ dataSource: OtherSource,
        erasedGetter: @escaping (Self, ListOptions) -> Erased = Self.defaultErasedGetter
    ) where OtherSource.SourceBase == Source {
        self.init(listContextSetups: [], source: dataSource.sourceBase, erasedGetter: erasedGetter)
    }

    init<OtherSource: ListAdapter>(
        _ dataSource: OtherSource
    ) where OtherSource.SourceBase == Source {
        self.init(
            listContextSetups: dataSource.listContextSetups,
            source: dataSource.sourceBase,
            erasedGetter: Self.defaultErasedGetter
        )
    }

    init<OtherSource: ListAdapter>(
        erase dataSource: OtherSource,
        options: ListOptions
    ) where Self == OtherSource.Erased {
        self = dataSource.erasedGetter(dataSource, options)
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((ListContext<View, Source>, Input)) -> Output
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { (context, object, input, root) in
                closure((.init(context: context, listView: object, root: root), input))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((ListContext<View, Source>, Input)) -> Void
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { (context, object, input, root) in
                closure((.init(context: context, listView: object, root: root), input))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input, Output, Index: ListIndex>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, IndexDelegate<View, Input, Output, Index>>,
        _ closure: @escaping ((ListIndexContext<View, Source, Index>, Input)) -> Output
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath), path = $0[keyPath: keyPath].index
            $0.set(keyPath) {
                closure((.init(context: $0, listView: $1, index: $2[keyPath: path], offset: $4, root: $3), $2))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input, Index: ListIndex>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, IndexDelegate<View, Input, Void, Index>>,
        _ closure: @escaping ((ListIndexContext<View, Source, Index>, Input)) -> Void
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath), path = $0[keyPath: keyPath].index
            $0.set(keyPath) {
                closure((.init(context: $0, listView: $1, index: $2[keyPath: path], offset: $4, root: $3), $2))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }
}
