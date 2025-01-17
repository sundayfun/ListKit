//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

import Foundation

class SectionsCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    typealias Section = Sources<SourceBase.Source.Element, SourceBase.Item>
    
    lazy var sections = toSections(source)
    lazy var indices = Self.toIndices(sections, options)
    
    var updateType: SectionsCoordinatorUpdate<SourceBase>.Type {
        SectionsCoordinatorUpdate<SourceBase>.self
    }
    
    func toSections(_ source: SourceBase.Source) -> ContiguousArray<Section> {
        source.mapContiguous {
            .init(
                items: $0,
                update: .init(way: update.way),
                options: options.union(.preferSection)
            )
        }
    }
    
    override func item(at indexPath: IndexPath) -> Item {
        let section = sections[indices[indexPath.section].index]
        return section.listCoordinator.item(at: .init(item: indexPath.item))
    }
    
    override func numbersOfSections() -> Int { indices.count }
    override func numbersOfItems(in section: Int) -> Int {
        let index = indices[section]
        if index.isFake { return 0 }
        return sections[index.index].count
    }
    
    override func configSourceType() -> SourceType { .section }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! SectionsCoordinator<SourceBase>
        return updateType.init(
            coordinator: self,
            update: ListUpdate(updateWay),
            values: (coordinator.sections, sections),
            sources: (coordinator.source, source),
            indices: (coordinator.indices, indices),
            options: (coordinator.options, options)
        )
    }
    
    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        let sectionsAfter = update.source.map(toSections)
        let indicesAfter = sectionsAfter.map { Self.toIndices($0, options ?? self.options) }
        return updateType.init(
            coordinator: self,
            update: update,
            values: (sections, sectionsAfter ?? sections),
            sources: (source, update.source ?? source),
            indices: (indices, indicesAfter ?? indices),
            options: (self.options, options ?? self.options)
        )
    }
}


final class RangeReplacableSectionsCoordinator<SourceBase: DataSource>:
    SectionsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    override var updateType: SectionsCoordinatorUpdate<SourceBase>.Type {
        RangeReplacableSectionsCoordinatorUpdate<SourceBase>.self
    }
    
    override func toSections(_ source: SourceBase.Source) -> ContiguousArray<Section> {
        source.mapContiguous {
            .init(
                items: $0,
                update: .init(way: update.way),
                options: options.union(.preferSection)
            )
        }
    }
}

extension SectionsCoordinator {
    static func toIndices(_ sections: ContiguousArray<Section>, _ options: ListOptions) -> Indices {
        if !options.removeEmptySection { return sections.indices.mapContiguous { ($0, false) } }
        var indices = Indices(capacity: sections.count)
        for (i, section) in sections.enumerated() where !section.isEmpty {
            indices.append((i, false))
        }
        return indices
    }
}
