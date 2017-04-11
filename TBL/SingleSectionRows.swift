import Foundation

public class SingleSectionRows<C: UITableViewCell, T> {

    let cellClass: AnyUITableViewCellClass
    fileprivate let itemProvider: (Void) -> [T]
    fileprivate var customizer: (T, C) -> Void
    fileprivate var height: Provider<CGFloat, Int> = .static(44)
    fileprivate var onSelect: ((T) -> Void)? = nil

    init(itemProvider: @escaping (Void) -> [T], cellClass: AnyUITableViewCellClass, customizer: @escaping (T, C) -> Void) {
        self.itemProvider = itemProvider
        self.cellClass = cellClass
        self.customizer = customizer
    }

    @discardableResult public func with(height: @escaping (Int) -> CGFloat) -> SingleSectionRows {
        self.height = .dynamic(height)
        return self
    }

    @discardableResult public func onSelect(_ handler: @escaping (T) -> Void) -> SingleSectionRows {
        self.onSelect = handler
        return self
    }

    fileprivate func item(_ index: Int) -> T {
        return itemProvider()[index]
    }
}

extension SingleSectionRows: SingleSectionRowDelegate {

    var rowCount: Int { return itemProvider().count }

    func customizeCell(_ cell: UITableViewCell, atIndex index: Int) {
        guard let cell = cell as? C else { fatalError() }
        customizer(item(index), cell)
    }

    func heightForRowAtIndex(_ index: Int) -> CGFloat {
        return height.value(index)
    }

    func onSelectCellAtIndex(_ index: Int) {
        onSelect?(item(index))
    }
}
