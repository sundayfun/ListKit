//
//  DataSource+ItemsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource
where SourceBase.Source: Collection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        ItemsCoordinator(sourceBase)
    }
}

public extension DataSource
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableItemsCoordinator(sourceBase)
    }
}

public extension UpdatableDataSource
where SourceBase.Source: Collection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        ItemsCoordinator(sourceBase, storage: coordinatorStorage)
    }
}

public extension UpdatableDataSource
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableItemsCoordinator(sourceBase, storage: coordinatorStorage)
    }
}
