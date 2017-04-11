
///
protocol SingleSectionRowDelegate {

    var cellClass: AnyUITableViewCellClass { get }
    var rowCount: Int { get }

    func customizeCell(_ cell: UITableViewCell, atIndex index: Int)
    func heightForRowAtIndex(_ index: Int) -> CGFloat
    func onSelectCellAtIndex(_ index: Int)
}

/// Describes a single section of a table
public class SingleSectionDescriptor {

    var header: Header? = nil
    fileprivate var rowProviders = [SingleSectionRowDelegate]()

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
        return rowProviders.reduce([AnyUITableViewCellClass]()) { $0 + [$1.cellClass] }
    }

    var sectionCount: Int { return 1 }

    func headerFor(_ section: Int) -> Header? {
        return header
    }

    func numberOfRowsIn(_ section: Int) -> Int {
        return rowProviders.reduce(0) { $0 + $1.rowCount }
    }

    func classForCellAt(section: Int, row: Int) -> AnyUITableViewCellClass {
        let rowOffset = rowAtIndex(row)
        return rowOffset.0.cellClass
    }

    func heightForCellAt(section: Int, row: Int) -> CGFloat {
        let rowOffset = rowAtIndex(row)
        return rowOffset.0.heightForRowAtIndex(rowOffset.1)
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        let rowOffset = rowAtIndex(row)
        return rowOffset.0.customizeCell(cell, atIndex: rowOffset.1)
    }

    func onCellSelectedAt(section: Int, row: Int) {
        let rowOffset = rowAtIndex(row)
        rowOffset.0.onSelectCellAtIndex(rowOffset.1)
    }

    private func rowAtIndex(_ index: Int) -> (SingleSectionRowDelegate, Int) {
        var currentIndex = 0
        for provider in rowProviders {
            let startIndex = currentIndex
            currentIndex += provider.rowCount
            if currentIndex > index {
                let rowIndex = (index - startIndex)
                return (provider, rowIndex)
            }
        }
        fatalError("Row index exceeds row count")
    }
}
