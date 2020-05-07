//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

final class ListContext {
    weak var listView: ListView?
    weak var supercoordinator: Coordinator?
    var sectionOffset: Int
    var itemOffset: Int
    
    init(listView: ListView?, sectionOffset: Int, itemOffset: Int, supercoordinator: Coordinator?) {
        self.listView = listView
        self.sectionOffset = sectionOffset
        self.itemOffset = itemOffset
        self.supercoordinator = supercoordinator
    }
}

final class ItemRelatedCache {
    var nestedAdapterItemUpdate = [AnyHashable: (Bool, (Any) -> Void)]()
    var cacheForItem = [ObjectIdentifier: Any]()
}

public class ListCoordinator<SourceBase: DataSource>: Coordinator
where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    
    weak var storage: CoordinatorStorage<SourceBase>?
    lazy var selectorSets = initialSelectorSets()
    
    #if os(iOS) || os(tvOS)
    lazy var scrollListDelegate = UIScrollListDelegate()
    lazy var collectionListDelegate = UICollectionListDelegate()
    lazy var tableListDelegate = UITableListDelegate()
    #endif
    
    //Source Diffing
    var didUpdateToCoordinator = [(Coordinator, Coordinator) -> Void]()
    var didUpdateIndices = [() -> Void]()
    
    var id: AnyHashable
    
    var sourceType = SourceType.cell
    var multiType: SourceMultipleType { .sources }
    var isEmpty: Bool { false }
    
    var cacheFromItem: ((Item) -> Any)?
    var listContexts = [ObjectIdentifier: ListContext]()
    var didSetup = false
    
    var defaultUpdate = Update<Item>()
    var differ = Differ<SourceBase>()
    
    var source: SourceBase.Source
    
    init(
        id: AnyHashable = ObjectIdentifier(SourceBase.self),
        defaultUpdate: Update<Item> = .init(),
        source: SourceBase.Source,
        storage: CoordinatorStorage<SourceBase>?
    ) {
        self.id = id
        self.storage = storage
        self.defaultUpdate = defaultUpdate
        self.source = source
    }
    
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        self.id = ObjectIdentifier(SourceBase.self)
        self.storage = storage
        self.defaultUpdate = sourceBase.listUpdate
        self.source = sourceBase.source(storage: storage)
    }
    
    func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache { fatalError() }
    
    func numbersOfSections() -> Int { fatalError() }
    func numbersOfItems(in section: Int) -> Int { fatalError() }
    
    func subsourceOffset(at index: Int) -> Path { fatalError() }
    func subsource(at index: Int) -> Coordinator { fatalError() }
    
    func item(at path: PathConvertible) -> Item { fatalError() }
    
    func configNestedIfNeeded() {
//        guard needUpdateCaches else { return }
//        itemCaches.enumerated().forEach { (arg) in
//            let section = arg.offset
//            arg.element.enumerated().forEach { (arg) in
//                let item = arg.offset
//                arg.element.nestedAdapterItemUpdate.values.forEach {
//                    if $0.0 { return }
//                    $0.1(self.item(at: Path(section: section, item: item)))
//                }
//            }
//        }
    }
    
    func configNestedNotNewIfNeeded() {
//        guard needUpdateCaches else { return }
//        for cache in itemCaches.lazy.flatMap({ $0 }) {
//            cache.nestedAdapterItemUpdate.keys.forEach {
//                cache.nestedAdapterItemUpdate[$0]?.0 = false
//            }
//        }
    }
    
    func offset(for object: AnyObject) -> (Int, Int) {
        guard let context = listContexts[ObjectIdentifier(object)] else { return (0, 0) }
        return (context.sectionOffset, context.itemOffset)
    }
    
    //Diffs:
    func itemDifference(
        from coordinator: Coordinator,
        differ: Differ<Item>
    ) -> [ItemCacheDifference] {
        fatalError()
    }
    
    func sourceDifference(
        sourceOffset: Path,
        targetOffset: Path,
        sourcePaths: [Int],
        targetPaths: [Int],
        from coordinator: Coordinator
    ) -> DataSourceDifference {
        fatalError()
    }
    
    func performReload(
        to sourceBase: SourceBase,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        for context in listContexts.values {
            guard let listView = context.listView else { continue }
            if let coordinator = context.supercoordinator {
                _ = coordinator
            } else {
                updateTo(sourceBase, with: updateData)
                context.listView?.reloadSynchronously(animated: animated)
                completion?(listView, true)
            }
        }
    }
    
    func perform(
        diff: Differ<Item>,
        to sourceBase: SourceBase,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        fatalError()
    }
    
    func perform(
        _ update: Update<Item>,
        to sourceBase: SourceBase,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        switch update.way {
        case .diff(let diff):
            perform(diff: diff, to: sourceBase, animated, completion, updateData)
        case .reload:
            performReload(to: sourceBase, animated, completion, updateData)
        }
    }
    
    func updateTo(_ sourceBase: SourceBase, with updateData: ((SourceBase.Source) -> Void)?) {
        
    }
    
    func removeCurrent(animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        
    }
    
    //Selectors
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        self[keyPath: keyPath].closure?(object, input)
    }
    
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Coordinator, Delegate<Object, Input, Output>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none: selectorSets { $0.value.remove(delegate.selector) }
        case .indexPath: selectorSets { $0.withIndexPath.remove(delegate.selector) }
        case .index:
            selectorSets {
                $0.withIndex.remove(delegate.selector)
                $0.hasIndex = true
            }
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<Coordinator, Delegate<Object, Input, Void>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        selectorSets { $0.void.remove(delegate.selector) }
    }
    
    func selectorSets(applying: (inout SelectorSets) -> Void) {
        applying(&selectorSets)
    }
    
    //Setup
    
    func setup() { }
    
    func setupContext(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: Coordinator? = nil
    ) {
        if let context = listContexts[key] {
            context.sectionOffset = sectionOffset
            context.itemOffset = itemOffset
            return
        }
        
        let context = ListContext(
            listView: listView,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
        listContexts[key] = context
    }
    
    func update(
        from coordinator: Coordinator,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) -> Bool {
        false
    }
}

extension ListCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
