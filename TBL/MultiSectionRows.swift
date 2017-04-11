import Foundation

// Row descriptor for creating multiple rows for multiple sections
public class MultiSectionRows<Cell: UITableViewCell> {

    let cellClass: AnyUITableViewCellClass
    let rowCount: (Int) -> Int
    let customizer: (Path, Cell) -> Void
    var height: Provider<CGFloat, Path> = .static(44)
    var selectionHandler: ((Path) -> Void)? = nil

    init(cellClass: AnyUITableViewCellClass, rowCount: @escaping (Int) -> Int, customizer: @escaping (Path, Cell) -> Void) {
        self.cellClass = cellClass
        self.rowCount = rowCount
        self.customizer = customizer
    }

    @discardableResult
    public func with(height: @escaping (Path) -> CGFloat) -> Self {
        self.height = .dynamic(height)
        return self
    }

    @discardableResult
    public func with(height: CGFloat) -> Self {
        self.height = .static(height)
        return self
    }

    @discardableResult
    public func onSelect(_ handler: @escaping (Path) -> Void) -> Self {
        self.selectionHandler = handler
        return self
    }
}

extension MultiSectionRows: AnyMultipleSectionRow {

    func rowCount(section: Int) -> Int {
        return self.rowCount(section)
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        guard let cell = cell as? Cell else { fatalError() }
        customizer((section, row), cell)
    }

    func heightForRow(section: Int, row: Int) -> CGFloat {
        return height.value((section, row))
    }

    func onCellSelectedAt(section: Int, row: Int) {
        selectionHandler?((section, row))
    }
}
