
/// Describes multiple but identical sections of a table
public class MultipleSectionDescriptor {

    private let sectionCountProvider: SectionCountProvider
    private var rows = [AnyMultipleSectionRow]()
    private var header: MultipleSectionHeader?

    init(sectionCountProvider: SectionCountProvider) {
        self.sectionCountProvider = sectionCountProvider
    }

    /// Adds a single row to this section
    public func addRow<T: UITableViewCell>(cellClass: T.Type, customizer: (Int, T) -> Void) -> MultipleSectionRow<T> {
        let row = MultipleSectionRow(cellClass: cellClass, customizer: customizer)
        rows.append(row)
        return row
    }

    /// Adds a header to this section
    public func addHeader<H: UIView>(factory: Void -> H, customizer: (Int, H) -> Void) -> MultipleSectionHeader {
        let header = MultipleSectionHeader(factory: factory) { index, cell in
            customizer(index, cell as! H)
        }
        self.header = header
        return header
    }

    func rowAtIndex(rowIndex: Int, forSection sectionIndex: Int) -> Row {
        return RowProxy(index: sectionIndex, row: rows[rowIndex])
    }

    func headerForSectionAtIndex(index: Int) -> Header? {
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

    func sectionAtIndex(index: Int) -> Section {
        return SectionProxy(sectionIndex: index, parent: self)
    }
}

/// Section Proxy
struct SectionProxy {

    let sectionIndex: Int
    let parent: MultipleSectionDescriptor
}

extension SectionProxy: Section {

    var rowCount: Int {
        return parent.rows.count
    }

    var header: Header? {
        return parent.headerForSectionAtIndex(sectionIndex)
    }

    func rowAtIndex(index: Int) -> Row {
        return parent.rowAtIndex(index, forSection: sectionIndex)
    }
}

protocol AnyMultipleSectionRow {

    var cellClass: AnyUITableViewCellClass { get }

    func customize(cell: UITableViewCell, input: Int)
    func heightForRowAtIndex(index: Int) -> CGFloat
}

/// Row Descriptor
public class MultipleSectionRow<T: UITableViewCell> {

    let cellClass: AnyUITableViewCellClass
    let customizer: (Int, T) -> Void
    var height: Provider<CGFloat, Int> = .Static(44)

    init(cellClass: AnyUITableViewCellClass, customizer: (Int, T) -> Void) {
        self.cellClass = cellClass
        self.customizer = customizer
    }

    public func withHeight(height: Int -> CGFloat) {
        self.height = .Dynamic(height)
    }

    public func withHeight(height: CGFloat) {
        self.height = .Static(height)
    }
}

extension MultipleSectionRow: AnyMultipleSectionRow {

    func customize(cell: UITableViewCell, input: Int) {
        guard let cell = cell as? T else { return }
        customizer(input, cell)
    }

    func heightForRowAtIndex(index: Int) -> CGFloat {
        return height.value(index)
    }
}

/// Row Proxy
struct RowProxy {

    let index: Int
    let row: AnyMultipleSectionRow
}

extension RowProxy: Row {

    var height: CGFloat {
        return row.heightForRowAtIndex(index)
    }

    var cellClass: AnyUITableViewCellClass {
        return row.cellClass
    }

    func customizeCell(cell: UITableViewCell) {
        row.customize(cell, input: index)
    }

    func didSelectRow() {
        
    }
}

public class MultipleSectionHeader {

    let factory: Void -> UIView
    let customizer: (Int, UIView) -> Void
    var height: Provider<CGFloat, Int> = .Static(20)

    init(factory: Void -> UIView, customizer: (Int, UIView) -> Void) {
        self.factory = factory
        self.customizer = customizer
    }

    public func withHeight(height: Int -> CGFloat) {
        self.height = .Dynamic(height)
    }

    public func withHeight(height: CGFloat) {
        self.height = .Static(height)
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
    
    func customizeHeader(headerView: UIView) {
        header.customizer(index, headerView)
    }
}