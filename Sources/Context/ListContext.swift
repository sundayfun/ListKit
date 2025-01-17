//
//  ListContext.swift
//  ListKit
//
//  Created by Frain on 2020/8/2.
//

import Foundation

@dynamicMemberLookup
public protocol Context {
    associatedtype SourceBase: DataSource where SourceBase.SourceBase == SourceBase
    associatedtype List
    
    var context: ListCoordinatorContext<SourceBase> { get }
    var listView: List { get }
}

public struct ListContext<List, SourceBase: DataSource>: Context
where SourceBase.SourceBase == SourceBase {
    public let context: ListCoordinatorContext<SourceBase>
    public let listView: List
    let root: CoordinatorContext
}

public struct ListIndexContext<List, SourceBase: DataSource, Index>: Context
where SourceBase.SourceBase == SourceBase {
    public let context: ListCoordinatorContext<SourceBase>
    public let listView: List
    public let index: Index
    public let offset: Index
    let root: CoordinatorContext
}

public extension DataSource {
    typealias ListSectionContext<List: ListView> = ListIndexContext<List, SourceBase, Int>
    typealias ListItemContext<List: ListView> = ListIndexContext<List, SourceBase, IndexPath>
}

public extension Context {
    var source: SourceBase.Source { context.listCoordinator.source }

    subscript<Value>(dynamicMember keyPath: KeyPath<SourceBase.Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
}

public extension ListIndexContext where Index == Int {
    var section: Int { index - offset }
}

public extension ListIndexContext where Index == IndexPath {
    var section: Int { index.section - offset.section }
    var item: Int { index.item - offset.item }
}

extension ListIndexContext where Index == IndexPath {
    var itemValue: SourceBase.Item {
        context.listCoordinator.item(at: index.offseted(offset, plus: false))
    }
    
    func setNestedCache(update: @escaping (Any) -> Void) {
        root.itemNestedCache[index.section][index.item] = update
    }
    
    func itemCache<Cache>(or getter: (Self, SourceBase.Item) -> Cache) -> Cache {
        root.itemCaches[index.section][index.item] as? Cache ?? {
            let cache = getter(self, itemValue)
            root.itemCaches[index.section][index.item] = cache
            return cache
        }()
    }
}
