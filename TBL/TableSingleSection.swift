
///
protocol SingleSectionRowDelegate {

    var cellClass: AnyUITableViewCellClass { get }

    func customizeCell(_ cell: UITableViewCell, atIndex index: Int)
    func heightForRowAtIndex(_ index: Int) -> CGFloat
    func onSelectCellAtIndex(_ index: Int)
}

/// Describes a single section of a table
public class SingleSectionDescriptor {

    var header: Header? = nil
    fileprivate var rowProviders = [RowProvider]()

    /// Adds a single row to this section
    @discardableResult public func addRow<C: UITableViewCell>(_ cellClass: C.Type, customizer: @escaping (C) -> Void) -> SingleSectionRow<C> {
        let row = SingleSectionRow(cellClass: cellClass, customizer: customizer)
        rowProviders.append(row)
        return row
    }

    /// Adds a row for each of the items returned by the array provider
    @discardableResult public func addRowForEach<C: UITableViewCell, T>(_ provider: @escaping (Void) -> [T], cellClass: C.Type, customizer: @escaping (T, C) -> Void) -> SingleSectionRows<C, T> {
        let row = SingleSectionRows(itemProvider: provider, cellClass: cellClass, customizer: customizer)
        rowProviders.append(row)
        return row
    }
}

extension SingleSectionDescriptor: SectionProvider {

    var cellClasses: [AnyUITableViewCellClass] {
        return rowProviders.reduce([AnyUITableViewCellClass]()) { $0 + $1.cellClasses }
    }

    var sectionCount: Int { return 1 }

    func sectionAtIndex(_ index: Int) -> Section { return self }

    func numberOfRowsIn(_ section: Int) -> Int {
        return rowProviders.reduce(0) { $0 + $1.rowCount }
    }

    func classForCellAt(section: Int, row: Int) -> AnyUITableViewCellClass {
        return rowAtIndex(row).cellClass
    }

    func heightForCellAt(section: Int, row: Int) -> CGFloat {
        return rowAtIndex(row).height
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        rowAtIndex(row).customizeCell(cell)
    }
}

extension SingleSectionDescriptor: Section {

    func rowAtIndex(_ index: Int) -> Row {
        var currentIndex = 0
        for provider in rowProviders {
            let startIndex = currentIndex
            currentIndex += provider.rowCount
            if currentIndex > index {
                let rowIndex = (index - startIndex)
                return provider.rowAtIndex(rowIndex)
            }
        }
        fatalError("Row index exceeds row count")
    }
}

// MARK: Single Row

public class SingleSectionRow<C: UITableViewCell>  {

    let cellClass: AnyUITableViewCellClass
    fileprivate let customizer: (C) -> Void
    fileprivate var heightProvider: Provider<CGFloat, Void> = .static(44)
    fileprivate var onSelect: ((Void) -> Void)? = nil
    fileprivate var visible = When<Void>.always

    init(cellClass: C.Type, customizer: @escaping (C) -> Void) {
        self.cellClass = cellClass
        self.customizer = customizer
    }

    @discardableResult public func with(height: @escaping (Void) -> CGFloat) -> SingleSectionRow {
        self.heightProvider = .dynamic(height)
        return self
    }

    @discardableResult public func with(height: CGFloat) -> SingleSectionRow {
        self.heightProvider = .static(height)
        return self
    }

    @discardableResult public func onSelect(_ handler: @escaping (Void) -> Void) -> SingleSectionRow {
        self.onSelect = handler
        return self
    }

    @discardableResult public func visible(_ clause: When<Void>) -> SingleSectionRow {
        self.visible = clause
        return self
    }
}

extension SingleSectionRow: RowProvider {

    var cellClasses: [AnyUITableViewCellClass] { return [cellClass] }
    var rowCount: Int { return visible.evaluate() ? 1 : 0 }

    func rowAtIndex(_ index: Int) -> Row { return self }
}

extension SingleSectionRow: Row {

    var height: CGFloat { return heightProvider.value() }

    func customizeCell(_ cell: UITableViewCell) {
        guard let cell = cell as? C else { fatalError() }
        customizer(cell)
    }

    func didSelectRow() {
        onSelect?()
    }
}

// MARK: Multiple Rows

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

extension SingleSectionRows: RowProvider {

    var cellClasses: [AnyUITableViewCellClass] { return [cellClass] }
    var rowCount: Int { return itemProvider().count }

    func rowAtIndex(_ index: Int) -> Row {
        return SingleSectionRowProxy(index: index, delegate: self)
    }
}

extension SingleSectionRows: SingleSectionRowDelegate {

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

struct SingleSectionRowProxy {

    let index: Int
    let delegate: SingleSectionRowDelegate
}

extension SingleSectionRowProxy: Row {

    var cellClass: AnyUITableViewCellClass { return delegate.cellClass }
    var height: CGFloat { return delegate.heightForRowAtIndex(index) }

    func customizeCell(_ cell: UITableViewCell) {
        delegate.customizeCell(cell, atIndex: index)
    }

    func didSelectRow() {
        delegate.onSelectCellAtIndex(index)
    }
}
