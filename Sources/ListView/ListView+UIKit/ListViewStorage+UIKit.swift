//
//  ListViewStorage+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UIListView {
    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        identifier: String = "",
        indexPath: IndexPath
    ) -> CustomCell {
        guard CustomCell.isSubclass(of: Cell.self) else {
            fatalError("\(CustomCell.self) is not subclass of \(Cell.self)")
        }
        let id = NSStringFromClass(CustomCell.self) + identifier
        if !_storage.registeredCellIdentifiers.contains(id) {
            _storage.registeredCellIdentifiers.insert(id)
            register(CustomCell.self, forCellReuseIdentifier: id)
        }
        return dequeueReusableCell(withIdentifier: id, for: indexPath) as! CustomCell
    }

    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        storyBoardIdentifier: String,
        indexPath: IndexPath
    ) -> CustomCell {
        guard CustomCell.isSubclass(of: Cell.self) else {
            fatalError("\(CustomCell.self) is not subclass of \(Cell.self)")
        }
        let cell = dequeueReusableCell(withIdentifier: storyBoardIdentifier, for: indexPath)
        return cell as! CustomCell
    }
    
    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        withNibName nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath
    ) -> CustomCell {
        guard CustomCell.isSubclass(of: Cell.self) else {
            fatalError("\(CustomCell.self) is not subclass of \(Cell.self)")
        }
        let nib = UINib(nibName: nibName, bundle: bundle)
        if !_storage.registeredNibNames.contains(nibName) {
            _storage.registeredNibNames.insert(nibName)
            register(nib, forCellReuseIdentifier: nibName)
        }
        return dequeueReusableCell(withIdentifier: nibName, for: indexPath) as! CustomCell
    }
}

public extension UICollectionView {
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UICollectionReusableView>(
        type: SupplementaryViewType,
        _ supplementaryClass: CustomSupplementaryView.Type,
        identifier: String = "",
        indexPath: IndexPath
    ) -> CustomSupplementaryView {
        let id = NSStringFromClass(CustomSupplementaryView.self) + type.rawValue + identifier
        if _storage.registeredSupplementaryIdentifiers[type]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryIdentifiers[type] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryIdentifiers[type] = identifiers
            register(supplementaryViewType: type, supplementaryClass, identifier: id)
        }
        let supplementaryView = dequeueReusableSupplementaryView(
            ofKind: type.rawValue,
            withReuseIdentifier: id,
            for: indexPath
        )
        return supplementaryView as! CustomSupplementaryView
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UICollectionReusableView>(
        type: SupplementaryViewType,
        _ supplementaryClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath
    ) -> CustomSupplementaryView {
        let nib = UINib(nibName: nibName, bundle: bundle)
        let id = nibName + type.rawValue
        if _storage.registeredSupplementaryNibName[type]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryNibName[type] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryNibName[type] = identifiers
            register(supplementaryViewType: type, nib, identifier: id)
        }
        let supplementaryView = dequeueReusableSupplementaryView(
            ofKind: type.rawValue,
            withReuseIdentifier: id,
            for: indexPath
        )
        return supplementaryView as! CustomSupplementaryView
    }
}

public extension UITableView {
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UITableViewHeaderFooterView>(
        type: SupplementaryViewType,
        _ supplementaryClass: CustomSupplementaryView.Type,
        identifier: String = ""
    ) -> CustomSupplementaryView? {
        let id = NSStringFromClass(CustomSupplementaryView.self) + type.rawValue + identifier
        if _storage.registeredSupplementaryIdentifiers[type]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryIdentifiers[type] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryIdentifiers[type] = identifiers
            register(supplementaryViewType: type, supplementaryClass, identifier: id)
        }
        let supplementaryView = dequeueReusableHeaderFooterView(withIdentifier: id)
        return supplementaryView as? CustomSupplementaryView
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UITableViewHeaderFooterView>(
        type: SupplementaryViewType,
        _ supplementaryClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil
    ) -> CustomSupplementaryView? {
        let nib = UINib(nibName: nibName, bundle: bundle)
        let id = nibName + type.rawValue
        if _storage.registeredSupplementaryNibName[type]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryNibName[type] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryNibName[type] = identifiers
            register(supplementaryViewType: type, nib, identifier: id)
        }
        let supplementaryView = dequeueReusableHeaderFooterView(withIdentifier: id)
        return supplementaryView as? CustomSupplementaryView
    }
}

#endif
