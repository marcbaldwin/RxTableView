import Foundation

protocol AnyMultipleSectionRow {

    var cellClass: AnyUITableViewCellClass { get }

    func rowCount(section: Int) -> Int
    func customize(_ cell: UITableViewCell, section: Int, row: Int)
    func heightForRow(section: Int, row: Int) -> CGFloat
    func onCellSelectedAt(section: Int, row: Int)
}

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
    @discardableResult
    public func addRow<Cell: UITableViewCell>(_ cellClass: Cell.Type, customizer: @escaping (Int, Cell) -> Void) -> MultiSectionRow<Cell> {
        let row = MultiSectionRow(cellClass: cellClass, customizer: customizer)
        rows.append(row)
        return row
    }


    /// Adds a row for each of the items returned by the array provider
    @discardableResult
    public func addRows<Cell: UITableViewCell>(_ rowCount: @escaping (Int) -> Int, cellClass: Cell.Type, customizer: @escaping (Path, Cell) -> Void) -> MultiSectionRows<Cell> {
        let row = MultiSectionRows(cellClass: cellClass, rowCount: rowCount, customizer: customizer)
        rows.append(row)
        return row
    }

    /// Adds a header to this section
    @discardableResult
    public func addHeader<H: UIView>(_ factory: @escaping (Void) -> H, customizer: @escaping (Int, H) -> Void) -> MultipleSectionHeader {
        let header = MultipleSectionHeader(factory: factory) { index, cell in
            customizer(index, cell as! H)
        }
        self.header = header
        return header
    }

    //
    // MARK: Internal
    //

    func rowAtIndex(_ rowIndex: Int, forSection sectionIndex: Int) -> (AnyMultipleSectionRow, Int) {
        var currentIndex = 0
        for provider in rows {
            let startIndex = currentIndex
            currentIndex += provider.rowCount(section: sectionIndex)
            if currentIndex > rowIndex {
                return (provider, rowIndex - startIndex)
            }
        }
        fatalError("Row index exceeds row count")
    }
}

extension MultipleSectionDescriptor: SectionProvider {

    var cellClasses: [AnyUITableViewCellClass] {
        return rows.reduce([AnyUITableViewCellClass]()) { $0 + [$1.cellClass] }
    }

    var sectionCount: Int {
        return sectionCountProvider()
    }

    func headerFor(_ section: Int) -> Header? {
        if let header = header {
            return MultipleSectionHeaderProxy(index: section, header: header)
        } else {
            return nil
        }
    }

    func numberOfRowsIn(_ section: Int) -> Int {
        return rows.reduce(0) { $0 + $1.rowCount(section: section) }
    }

    func classForCellAt(section: Int, row: Int) -> AnyUITableViewCellClass {
        return rowAtIndex(row, forSection: section).0.cellClass
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        let rowPath = rowAtIndex(row, forSection: section)
        return rowPath.0.customize(cell, section: section, row: rowPath.1)
    }

    func heightForCellAt(section: Int, row: Int) -> CGFloat {
        let rowPath = rowAtIndex(row, forSection: section)
        return rowPath.0.heightForRow(section: section, row: rowPath.1)
    }

    func onCellSelectedAt(section: Int, row: Int) {
        let rowPath = rowAtIndex(row, forSection: section)
        rowPath.0.onCellSelectedAt(section: section, row: rowPath.1)
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
