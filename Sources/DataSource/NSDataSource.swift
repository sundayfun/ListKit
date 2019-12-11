//
//  NSDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol NSDataSource: AnyObject, UpdatableDataSource where Source == Never {
    func item(at section: Int, item: Int) -> Item
    func numbersOfSections() -> Int
    func numbersOfItem(in section: Int) -> Int
}

public extension NSDataSource {
    var source: Never { fatalError("should not call source for NSDataSource") }
}