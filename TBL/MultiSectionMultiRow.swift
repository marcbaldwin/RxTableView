import Foundation

// Row descriptor for creating multiple rows for multiple sections
public class MultiSectionMultiRow<Cell: UITableViewCell> {

    let cellClass: AnyUITableViewCellClass
    let rowCount: (Int) -> Int
    let customizer: (Path, Cell) -> Void
    var height: Provider<CGFloat, Path> = .static(44)

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
}

extension MultiSectionMultiRow: AnyMultipleSectionRow {

    func rowCount(section: Int) -> Int {
        return self.rowCount(section)
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        guard let cell = cell as? Cell else { return }
        customizer((section, row), cell)
    }

    func heightForRow(section: Int, row: Int) -> CGFloat {
        return height.value((section, row))
    }
}
