//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    typealias TableContext = ListContext<UITableView, SourceBase>
    typealias TableItemContext = ListIndexContext<UITableView, SourceBase, IndexPath>
    typealias TableSectionContext = ListIndexContext<UITableView, SourceBase, Int>
    
    func tableViewCellForRow(
        _ closure: @escaping (TableItemContext, Item) -> UITableViewCell = { (context, item) in
            let cell = context.dequeueReusableCell(UITableViewCell.self)
            cell.textLabel?.text = "\(item)"
            return cell
        }
    ) -> TableList<SourceBase> {
        TableList(self).set(\.cellForRowAt) {
            closure($0.0, $0.0.itemValue)
        }
    }
    
    func tableViewCellForRow<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        _ closure: @escaping (Cell, TableItemContext, Item) -> Void = { _, _, _ in }
    ) -> TableList<SourceBase> {
        tableViewCellForRow { (context, item) in
            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
            closure(cell, context, item)
            return cell
        }
    }
    
    func tableViewCellForRow<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        storyBoardIdentifier: String,
        _ closure: @escaping (Cell, TableItemContext, Item) -> Void = { _, _, _ in }
    ) -> TableList<SourceBase> {
        tableViewCellForRow { (context, item) in
            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
            closure(cell, context, item)
            return cell
        }
    }
}

//TableView DataSource
public extension TableListAdapter {
    //Providing Cells, Headers, and Footers
    @discardableResult
    func tableViewHeaderTitleForSection(
        _ closure: @escaping (TableSectionContext) -> String?
    ) -> TableList<SourceBase> {
        tableList.set(\.titleForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewFooterTitleForSection(
        _ closure: @escaping (TableSectionContext) -> String?
    ) -> TableList<SourceBase> {
        tableList.set(\.titleForFooterInSection) { closure($0.0) }
    }
    
    //Inserting or Deleting Table Rows
    @discardableResult
    func tableViewCommitEdittingStyleForRow(
        _ closure: @escaping (TableItemContext, UITableViewCell.EditingStyle, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.commitForRowAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewCanEditRow(
        _ closure: @escaping (TableItemContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.canEditRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Reordering Table Rows
    @discardableResult
    func tableViewCanMoveRow(
        _ closure: @escaping (TableItemContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.canMoveRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewMoveRow(
        _ closure: @escaping (TableContext, IndexPath, IndexPath) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.moveRowAtTo) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Configuring an Index
    @discardableResult
    func tableViewSectionIndexTitles(
        _ closure: @escaping (TableContext) -> [String]?
    ) -> TableList<SourceBase> {
        tableList.set(\.sectionIndexTitles) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewsectionForSectionIndexTitle(
        _ closure: @escaping (TableContext, String, Int) -> Int
    ) -> TableList<SourceBase> {
        tableList.set(\.sectionForSectionIndexTitleAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
}

//TableView Delegate
public extension TableListAdapter {
    //Configuring Rows for the Table View
    @discardableResult
    func tableViewWillDisplayRow(
        _ closure: @escaping (TableItemContext, UITableViewCell, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.willDisplayForRowAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewIndentationLevelForRow(
        _ closure: @escaping (TableItemContext, Item) -> Int
    ) -> TableList<SourceBase> {
        tableList.set(\.indentationLevelForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewShouldSpringLoadRow(
        _ closure: @escaping (TableItemContext, UISpringLoadedInteractionContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.springLoadRowAtWith) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    //Responding to Row Selections
    @discardableResult
    func tableViewWillSelectRow(
        _ closure: @escaping (TableItemContext, Item) -> IndexPath?
    ) -> TableList<SourceBase> {
        tableList.set(\.willSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidSelectRow(
        _ closure: @escaping (TableItemContext, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewWillDeselectRow(
        _ closure: @escaping (TableItemContext, Item) -> IndexPath?
    ) -> TableList<SourceBase> {
        tableList.set(\.willDeselectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidDeselectRow(
        _ closure: @escaping (TableItemContext, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didDeselectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewShouldBeginMultipleSelectionInteraction(
        _ closure: @escaping (TableItemContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.shouldBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewDidBeginMultipleSelectionInteraction(
        _ closure: @escaping (TableItemContext, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewDidEndMultipleSelectionInteraction(
        _ closure: @escaping (TableContext) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didEndMultipleSelectionInteraction) { closure($0.0) }
    }
    
    //Providing Custom Header and Footer Views
    @discardableResult
    func tableViewViewHeaderForSection(
        _ closure: @escaping (TableSectionContext) -> UIView?
    ) -> TableList<SourceBase> {
        tableList.set(\.viewForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewViewFooterForSection(
        _ closure: @escaping (TableSectionContext) -> UIView?
    ) -> TableList<SourceBase> {
        tableList.set(\.viewForFooterInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewWillDisplayHeaderView(
        _ closure: @escaping (TableSectionContext, UIView) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.willDisplayHeaderViewForSection) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func tableViewWillDisplayFooterView(
        _ closure: @escaping (TableSectionContext, UIView) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.willDisplayFooterViewForSection) { closure($0.0, $0.1.0) }
    }
    
    //Providing Header, Footer, and Row Heights
    @discardableResult
    func tableViewHeightForRow(
        _ closure: @escaping (TableItemContext, Item) -> CGFloat
    ) -> TableList<SourceBase> {
        tableList.set(\.heightForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewHeightForHeader(
        _ closure: @escaping (TableSectionContext) -> CGFloat
    ) -> TableList<SourceBase> {
        tableList.set(\.heightForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewHeightForFooter(
        _ closure: @escaping (TableSectionContext) -> CGFloat
    ) -> TableList<SourceBase> {
        tableList.set(\.heightForFooterInSection) { closure($0.0) }
    }
    
    //Estimating Heights for the Table's Content
    @discardableResult
    func tableViewEstimatedHeightForRow(
        _ closure: @escaping (TableItemContext, Item) -> CGFloat
    ) -> TableList<SourceBase> {
        tableList.set(\.estimatedHeightForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewEstimatedHeightForHeader(
        _ closure: @escaping (TableSectionContext) -> CGFloat
    ) -> TableList<SourceBase> {
        tableList.set(\.estimatedHeightForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewEstimatedHeightForFooter(
        _ closure: @escaping (TableSectionContext) -> CGFloat
    ) -> TableList<SourceBase> {
        tableList.set(\.estimatedHeightForFooterInSection) { closure($0.0) }
    }
    
    //Managing Accessory Views
    @discardableResult
    func tableViewAccessoryButtonTapped(
        _ closure: @escaping (TableItemContext, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.accessoryButtonTappedForRowWith) { closure($0.0, $0.0.itemValue) }
    }
    
    //Responding to Row Actions
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewLeadingSwipeActionsConfiguration(
        _ closure: @escaping (TableItemContext, Item) -> UISwipeActionsConfiguration
    ) -> TableList<SourceBase> {
        tableList.set(\.leadingSwipeActionsConfigurationForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewTrailingSwipeActionsConfiguration(
        _ closure: @escaping (TableItemContext, Item) -> UISwipeActionsConfiguration
    ) -> TableList<SourceBase> {
        tableList.set(\.trailingSwipeActionsConfigurationForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldShowMenuForRow(
        _ closure: @escaping (TableItemContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.shouldShowMenuForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewCanPerformActionWithSender(
        _ closure: @escaping (TableItemContext, Selector, Any?, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.canPerformActionForRowAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewPerformActionWithSender(
        _ closure: @escaping (TableItemContext, Selector, Any?, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.performActionForRowAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewEditActionsForRow(
        _ closure: @escaping (TableItemContext, Item) -> [UITableViewRowAction]?
    ) -> TableList<SourceBase> {
        tableList.set(\.editActionsForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Managing Table View Highlights
    @discardableResult
    func tableViewShouldHighlight(
        _ closure: @escaping (TableItemContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.shouldHighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidHighlight(
        _ closure: @escaping (TableItemContext, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didHighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidUnhighlight(
        _ closure: @escaping (TableItemContext, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didUnhighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Editing Table Rows
    @discardableResult
    func tableViewWillBeginEditing(
        _ closure: @escaping (TableItemContext, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.willBeginEditingRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidEndEditing(
        _ closure: @escaping (TableContext, IndexPath?) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didEndEditingRowAt) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func tableViewEditingStyle(
        _ closure: @escaping (TableItemContext, Item) -> UITableViewCell.EditingStyle
    ) -> TableList<SourceBase> {
        tableList.set(\.editingStyleForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewTitleForDeleteConfirmationButton(
        _ closure: @escaping (TableItemContext, Item) -> String?
    ) -> TableList<SourceBase> {
        tableList.set(\.titleForDeleteConfirmationButtonForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldIndentWhileEditing(
        _ closure: @escaping (TableItemContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.shouldIndentWhileEditingRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Reordering Table Rows
    @discardableResult
    func tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath(
        _ closure: @escaping (TableContext, IndexPath, IndexPath) -> IndexPath
    ) -> TableList<SourceBase> {
        tableList.set(\.targetIndexPathForMoveFromRowAtToProposedIndexPath) { closure($0.0, $0.1.0, $0.1.1) }
    }
            
    //Tracking the Removal of Views
    @discardableResult
    func tableViewdidEndDisplayingForRowAt(
        _ closure: @escaping (TableContext, UITableViewCell, IndexPath) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didEndDisplayingForRowAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewDidEndDisplayingHeaderView(
        _ closure: @escaping (TableContext, UIView, Int) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didEndDisplayingHeaderViewForSection) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewDidEndDisplayingFooterView(
        _ closure: @escaping (TableContext, UIView, Int) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didEndDisplayingFooterViewForSection) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Managing Table View Focus
    @discardableResult
    func tableViewCanFocusRow(
        _ closure: @escaping (TableItemContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.canFocusRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldUpdateFocusIn(
        _ closure: @escaping (TableContext, UITableViewFocusUpdateContext) -> Bool
    ) -> TableList<SourceBase> {
        tableList.set(\.shouldUpdateFocusIn) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func tableViewdidUpdateFocusInWith(
        _ closure: @escaping (TableContext, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.didUpdateFocusInWith) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewIndexPathForPreferredFocusedView(
        _ closure: @escaping (TableContext) -> IndexPath?
    ) -> TableList<SourceBase> {
        tableList.set(\.indexPathForPreferredFocusedView) { closure($0.0) }
    }
    
    //Instance Methods
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewContextMenuConfigurationForRow(
        _ closure: @escaping (TableItemContext, CGPoint, Item) -> UIContextMenuConfiguration
    ) -> TableList<SourceBase> {
        tableList.set(\.contextMenuConfigurationForRowAtPoint) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewPreviewForDismissingContextMenuWithConfiguration(
        _ closure: @escaping (TableContext, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> TableList<SourceBase> {
        tableList.set(\.previewForDismissingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewPreviewForHighlightingContextMenuWithConfiguration(
        _ closure: @escaping (TableContext, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> TableList<SourceBase> {
        tableList.set(\.previewForHighlightingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func tableViewWillPerformPreviewActionForMenuWithAnimator(
        _ closure: @escaping (TableContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.willPerformPreviewActionForMenuWithAnimator) { closure($0.0, $0.1.0, $0.1.1) }
    }
}


#endif
