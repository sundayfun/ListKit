//
//  ListDelegate+UICollectionView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

extension Delegate: UICollectionViewDataSource {
    // MARK: - Getting Item and Section Metrics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        context.numbersOfModel(in: section)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        context.numbersOfSections()
    }

    // MARK: - Getting Views for Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        apply(#selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? .init()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        apply(#selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)), view: collectionView, with: (indexPath, kind), index: indexPath) ?? .init()
    }

    // MARK: - Reordering Items
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        apply(#selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        apply(#selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)), view: collectionView, with: (sourceIndexPath, destinationIndexPath)) ?? ()
    }
}

extension Delegate: UICollectionViewDelegate {
    // MARK: - Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? ()
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? ()
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:)), view: collectionView, with: indexPath, index: indexPath) ?? true
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:)), view: collectionView, with: indexPath, index: indexPath) ?? ()
    }

    @available(iOS 13.0, *)
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        apply(#selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:)), view: collectionView) ?? ()
    }

    // MARK: - Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? ()
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? ()
    }

    // MARK: - Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)), view: collectionView, with: (indexPath, cell), index: indexPath) ?? ()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)), view: collectionView, with: (indexPath, view, elementKind), index: indexPath) ?? ()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)), view: collectionView, with: (indexPath, cell)) ?? ()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)), view: collectionView, with: (view, elementKind, indexPath)) ?? ()
    }

    // MARK: - Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        apply(#selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:)), view: collectionView, with: (fromLayout, toLayout)) ?? .init(currentLayout: fromLayout, nextLayout: toLayout)
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        apply(#selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:)), view: collectionView, with: (proposedContentOffset)) ?? proposedContentOffset
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        apply(#selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)), view: collectionView, with: (originalIndexPath, proposedIndexPath)) ?? proposedIndexPath
    }

    // MARK: - Managing Actions for Cells
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)), view: collectionView, with: (indexPath, action, sender), index: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)), view: collectionView, with: (indexPath, action, sender), index: indexPath) ?? ()
    }

    // MARK: - Managing Focus in a Collection View
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:)), view: collectionView, with: indexPath, index: indexPath) ?? true
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        apply(#selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:)), view: collectionView) ?? nil
    }

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:)), view: collectionView, with: context) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:)), view: collectionView, with: (context, coordinator)) ?? ()
    }

    // MARK: - Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        apply(#selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:)), view: collectionView, with: (indexPath, context), index: indexPath) ?? true
    }

    // MARK: - Instance Methods
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        apply(#selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:)), view: collectionView, with: (indexPath, point), index: indexPath) ?? nil
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(#selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:)), view: collectionView, with: (configuration)) ?? nil
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(#selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:)), view: collectionView, with: (configuration)) ?? nil
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        apply(#selector(UICollectionViewDelegate.collectionView(_:willPerformPreviewActionForMenuWith:animator:)), view: collectionView, with: (configuration, animator)) ?? ()
    }
}

extension Delegate: UICollectionViewDelegateFlowLayout {
    // MARK: - Getting the Size of Items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        apply(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)), view: collectionView, with: (indexPath, collectionViewLayout), index: indexPath)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }

    // MARK: - Getting the Section Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        apply(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)), view: collectionView, with: (section, collectionViewLayout), index: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        apply(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)), view: collectionView, with: (section, collectionViewLayout), index: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        apply(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)), view: collectionView, with: (section, collectionViewLayout), index: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? .zero
    }

    // MARK: - Getting the Header and Footer Sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        apply(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)), view: collectionView, with: (section, collectionViewLayout), index: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        apply(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)), view: collectionView, with: (section, collectionViewLayout), index: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
    }
}

#endif
