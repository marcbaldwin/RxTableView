
///
protocol SingleSectionRowDelegate {

    var cellClass: AnyUITableViewCellClass { get }

    func customizeCell(cell: UITableViewCell, atIndex index: Int)
    func heightForRowAtIndex(index: Int) -> CGFloat
    func onSelectCellAtIndex(index: Int)
}

/// Describes a single section of a table
public class SingleSectionDescriptor {

    var header: Header? = nil
    private var rowProviders = [RowProvider]()

    /// Adds a single row to this section
    public func addRow<C: UITableViewCell>(cellClass: C.Type, customizer: C -> Void) -> SingleSectionRow<C> {
        let row = SingleSectionRow(cellClass: cellClass, customizer: customizer)
        rowProviders.append(row)
        return row
    }

    /// Adds a row for each of the items returned by the array provider
    public func addRowForEach<C: UITableViewCell, T>(provider: Void -> [T], cellClass: C.Type, customizer: (T, C) -> Void) -> SingleSectionRows<C, T> {
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

    func sectionAtIndex(index: Int) -> Section { return self }
}

extension SingleSectionDescriptor: Section {

    var rowCount: Int {
        return rowProviders.reduce(0) { $0 + $1.rowCount }
    }

    func rowAtIndex(index: Int) -> Row {
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
    private let customizer: C -> Void
    private var height: Provider<CGFloat, Void> = .Static(44)
    private var onSelect: (Void -> Void)? = nil
    private var visible = When<Void>.Always

    init(cellClass: C.Type, customizer: C -> Void) {
        self.cellClass = cellClass
        self.customizer = customizer
    }

    public func withHeight(height: Void -> CGFloat) -> SingleSectionRow {
        self.height = .Dynamic(height)
        return self
    }

    public func withHeight(height: CGFloat) -> SingleSectionRow {
        self.height = .Static(height)
        return self
    }

    public func onSelect(handler: Void -> Void) -> SingleSectionRow {
        self.onSelect = handler
        return self
    }

    public func visible(clause: When<Void>) -> SingleSectionRow {
        self.visible = clause
        return self
    }
}

extension SingleSectionRow: RowProvider {

    var cellClasses: [AnyUITableViewCellClass] { return [cellClass] }
    var rowCount: Int { return visible.evaluate() ? 1 : 0 }

    func rowAtIndex(index: Int) -> Row { return self }
}

extension SingleSectionRow: Row {

    var height: CGFloat { return height.value() }

    func customizeCell(cell: UITableViewCell) {
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
    private let itemProvider: Void -> [T]
    private var customizer: (T, C) -> Void
    private var height: Provider<CGFloat, Int> = .Static(44)
    private var onSelect: (T -> Void)? = nil

    init(itemProvider: Void -> [T], cellClass: AnyUITableViewCellClass, customizer: (T, C) -> Void) {
        self.itemProvider = itemProvider
        self.cellClass = cellClass
        self.customizer = customizer
    }

    public func withHeight(height: Int -> CGFloat) -> SingleSectionRows {
        self.height = .Dynamic(height)
        return self
    }

    public func onSelect(handler: T -> Void) -> SingleSectionRows {
        self.onSelect = handler
        return self
    }

    private func item(index: Int) -> T {
        return itemProvider()[index]
    }
}

extension SingleSectionRows: RowProvider {

    var cellClasses: [AnyUITableViewCellClass] { return [cellClass] }
    var rowCount: Int { return itemProvider().count }

    func rowAtIndex(index: Int) -> Row {
        return SingleSectionRowProxy(index: index, delegate: self)
    }
}

extension SingleSectionRows: SingleSectionRowDelegate {

    func customizeCell(cell: UITableViewCell, atIndex index: Int) {
        guard let cell = cell as? C else { fatalError() }
        customizer(item(index), cell)
    }

    func heightForRowAtIndex(index: Int) -> CGFloat {
        return height.value(index)
    }

    func onSelectCellAtIndex(index: Int) {
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

    func customizeCell(cell: UITableViewCell) {
        delegate.customizeCell(cell, atIndex: index)
    }

    func didSelectRow() {
        delegate.onSelectCellAtIndex(index)
    }
}