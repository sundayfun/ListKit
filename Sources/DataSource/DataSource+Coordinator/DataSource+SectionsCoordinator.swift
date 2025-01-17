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
    var listCoordinator: ListCoordinator<SourceBase> {
        SectionsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    var listCoordinator: ListCoordinator<SourceBase> {
        RangeReplacableSectionsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Item
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: SectionsCoordinator(sourceBase))
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: RangeReplacableSectionsCoordinator(sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    func itemContext<List: ListView>(
        for listView: List,
        at section: Int,
        item: Int
    ) -> [ListItemContext<List>] {
        _itemContext(for: listView, at: .init(section: section, item: item))
    }
}
