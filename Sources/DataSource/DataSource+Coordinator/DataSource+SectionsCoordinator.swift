//
//  DataSource+SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource
where
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SectionsCoordinator(sourceBase: sourceBase)
    }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableSectionsCoordinator(sourceBase: sourceBase)
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SectionsCoordinator(sourceBase: sourceBase, storage: coordinatorStorage)
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableSectionsCoordinator(sourceBase: sourceBase, storage: coordinatorStorage)
    }
}
