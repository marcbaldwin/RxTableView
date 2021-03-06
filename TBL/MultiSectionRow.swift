import Foundation

/// Single row descriptor for multiple sections
public class MultiSectionRow<C: UITableViewCell> {

    let cellClass: AnyUITableViewCellClass
    let customizer: (Int, C) -> Void
    var height: Provider<CGFloat, Int> = .static(44)
    var selectionHandler: ((Int) -> Void)? = nil

    init(cellClass: AnyUITableViewCellClass, customizer: @escaping (Int, C) -> Void) {
        self.cellClass = cellClass
        self.customizer = customizer
    }

    public func with(height: @escaping (Int) -> CGFloat) {
        self.height = .dynamic(height)
    }

    public func with(height: CGFloat) {
        self.height = .static(height)
    }

    @discardableResult
    public func onSelect(_ handler: @escaping (Int) -> Void) -> Self {
        self.selectionHandler = handler
        return self
    }
}

extension MultiSectionRow: AnyMultipleSectionRow {

    func rowCount(section: Int) -> Int {
        return 1
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        guard let cell = cell as? C else { fatalError() }
        customizer(section, cell)
    }

    func heightForRow(section: Int, row: Int) -> CGFloat {
        return height.value(section)
    }

    func onCellSelectedAt(section: Int, row: Int) {
        selectionHandler?(section)
    }
}
