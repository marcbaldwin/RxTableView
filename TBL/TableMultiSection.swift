
public typealias Path = (section: Int, row: Int)

/// Describes multiple but identical sections of a table
public class MultipleSectionDescriptor {

    fileprivate let sectionCountProvider: SectionCountProvider
    fileprivate var rows = [AnyMultipleSectionRow]()
    fileprivate var header: MultipleSectionHeader?

    init(sectionCountProvider: @escaping SectionCountProvider) {
        self.sectionCountProvider = sectionCountProvider
    }

    /// Adds a single row to this section
    @discardableResult public func addRow<Cell: UITableViewCell>(_ cellClass: Cell.Type, customizer: @escaping (Int, Cell) -> Void) -> MultiSectionRow<Cell> {
        let row = MultiSectionRow(cellClass: cellClass, customizer: customizer)
        rows.append(row)
        return row
    }

    
    /// Adds a row for each of the items returned by the array provider
    @discardableResult public func addRows<Cell: UITableViewCell>(_ rowCount: @escaping (Int) -> Int, cellClass: Cell.Type, customizer: @escaping (Path, Cell) -> Void) -> MultiSectionMultiRow<Cell> {
        let row = MultiSectionMultiRow(cellClass: cellClass, rowCount: rowCount, customizer: customizer)
        rows.append(row)
        return row
    }

    /// Adds a header to this section
    @discardableResult public func addHeader<H: UIView>(_ factory: @escaping (Void) -> H, customizer: @escaping (Int, H) -> Void) -> MultipleSectionHeader {
        let header = MultipleSectionHeader(factory: factory) { index, cell in
            customizer(index, cell as! H)
        }
        self.header = header
        return header
    }

    //
    // MARK: Internal
    //

    func rowAtIndex(_ rowIndex: Int, forSection sectionIndex: Int) -> Row {
        var currentIndex = 0
        for provider in rows {
            let startIndex = currentIndex
            currentIndex += provider.rowCount(section: sectionIndex)
            if currentIndex > rowIndex {
                return RowProxy(index: sectionIndex, rowIndex: rowIndex - startIndex, row: provider)
            }
        }
        fatalError("Row index exceeds row count")
    }

    func headerForSectionAtIndex(_ index: Int) -> Header? {
        if let header = header {
            return MultipleSectionHeaderProxy(index: index, header: header)
        } else {
            return nil
        }
    }
}

extension MultipleSectionDescriptor: SectionProvider {

    var cellClasses: [AnyUITableViewCellClass] {
        return rows.reduce([AnyUITableViewCellClass]()) { $0 + [$1.cellClass] }
    }

    var sectionCount: Int {
        return sectionCountProvider()
    }

    func sectionAtIndex(_ index: Int) -> Section {
        return SectionProxy(sectionIndex: index, parent: self)
    }

    func numberOfRowsIn(_ section: Int) -> Int {
        return rows.reduce(0) { $0 + $1.rowCount(section: section) }
    }

    func classForCellAt(section: Int, row: Int) -> AnyUITableViewCellClass {
        return rowAtIndex(row, forSection: section).cellClass
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        rowAtIndex(row, forSection: section).customizeCell(cell)
    }

    func heightForCellAt(section: Int, row: Int) -> CGFloat {
        return rowAtIndex(row, forSection: section).height
    }
}

/// Section Proxy
struct SectionProxy {

    let sectionIndex: Int
    let parent: MultipleSectionDescriptor
}

extension SectionProxy: Section {

    var header: Header? {
        return parent.headerForSectionAtIndex(sectionIndex)
    }

    func rowAtIndex(_ index: Int) -> Row {
        return parent.rowAtIndex(index, forSection: sectionIndex)
    }
}

/// Row Proxy
struct RowProxy {

    let index: Int
    let rowIndex: Int
    let row: AnyMultipleSectionRow
}

extension RowProxy: Row {

    var height: CGFloat {
        return row.heightForRow(section: index, row: rowIndex)
    }

    var cellClass: AnyUITableViewCellClass {
        return row.cellClass
    }

    func customizeCell(_ cell: UITableViewCell) {
        row.customize(cell, section: index, row: rowIndex)
    }

    func didSelectRow() {
        row.onCellSelectedAt(section: index, row: rowIndex)
    }
}

public class MultipleSectionHeader {

    let factory: (Void) -> UIView
    let customizer: (Int, UIView) -> Void
    var height: Provider<CGFloat, Int> = .static(20)

    init(factory: @escaping (Void) -> UIView, customizer: @escaping (Int, UIView) -> Void) {
        self.factory = factory
        self.customizer = customizer
    }

    public func with(height: @escaping (Int) -> CGFloat) {
        self.height = .dynamic(height)
    }

    public func with(height: CGFloat) {
        self.height = .static(height)
    }
}

struct MultipleSectionHeaderProxy {

    let index: Int
    let header: MultipleSectionHeader
}

extension MultipleSectionHeaderProxy: Header {

    var height: CGFloat {
        return header.height.value(index)
    }

    func createHeader() -> UIView {
        return header.factory()
    }
    
    func customizeHeader(_ headerView: UIView) {
        header.customizer(index, headerView)
    }
}
