/// Types
public typealias AnyUIViewClass = UIView.Type
public typealias AnyUITableViewCellClass = UITableViewCell.Type
public typealias SectionCountProvider = (Void) -> Int


/// Provides sections to be displayed in a table
protocol SectionProvider {

    var cellClasses: [AnyUITableViewCellClass] { get }
    var sectionCount: Int { get }

    func headerFor(_ section: Int) -> Header?

    func numberOfRowsIn(_ section: Int) -> Int
    func classForCellAt(section: Int, row: Int) -> AnyUITableViewCellClass
    func heightForCellAt(section: Int, row: Int) -> CGFloat
    func customize(_ cell: UITableViewCell, section: Int, row: Int)
    func onCellSelectedAt(section: Int, row: Int)
}

/// Describes a row in a table
protocol Row {

    var cellClass: AnyUITableViewCellClass { get }
    var height: CGFloat { get }

    func customizeCell(_ cell: UITableViewCell)
    func didSelectRow()
}

protocol Header {

    var height: CGFloat { get }

    func createHeader() -> UIView
    func customizeHeader(_ headerView: UIView)
}

/// Describes a table
open class Table {

    fileprivate var sectionProviders = [SectionProvider]()
    fileprivate var dataSourceDelegate: TableViewDataSourceDelegate?

    public init() {}

    /// Adds a single section to this table
    open func addSection() -> SingleSectionDescriptor {
        let section = SingleSectionDescriptor()
        sectionProviders.append(section)
        return section
    }

    /// Adds multiple sections to this table
    /// The result of sectionCountProvider must be consistent,
    /// if the result will change, call reloadData() on the UITableView
    open func addSections(_ sectionCount: @escaping SectionCountProvider) -> MultipleSectionDescriptor {
        let section = MultipleSectionDescriptor(sectionCountProvider: sectionCount)
        sectionProviders.append(section)
        return section
    }

    open func attachToTableView(_ tableView: UITableView) {
        dataSourceDelegate = TableViewDataSourceDelegate(sectionProvider: self)
        cellClasses.forEach(tableView.registerClassForCellReuse)
        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate
    }

    //
    // Private
    //
    fileprivate func sectionProviderAt(_ index: Int) -> (SectionProvider, Int) {
        var currentSection = 0
        for sectionProvider in sectionProviders {
            let sectionStartIndex = currentSection
            currentSection += sectionProvider.sectionCount
            if currentSection > index {
                return (sectionProvider, index - sectionStartIndex)
            }
        }
        fatalError("Section index exceeds section count")
    }
}

extension Table: SectionProvider {

    var cellClasses: [AnyUITableViewCellClass] {
        return sectionProviders.reduce([AnyUITableViewCellClass]()) { $0 + $1.cellClasses }
    }

    var sectionCount: Int {
        return sectionProviders.reduce(0) { $0 + $1.sectionCount }
    }

    func headerFor(_ section: Int) -> Header? {
        let sectionOffset = sectionProviderAt(section)
        return sectionOffset.0.headerFor(sectionOffset.1)
    }

    func numberOfRowsIn(_ section: Int) -> Int {
        let sectionOffset = sectionProviderAt(section)
        return sectionOffset.0.numberOfRowsIn(sectionOffset.1)
    }

    func classForCellAt(section: Int, row: Int) -> AnyUITableViewCellClass {
        let sectionOffset = sectionProviderAt(section)
        return sectionOffset.0.classForCellAt(section: sectionOffset.1, row: row)
    }

    func heightForCellAt(section: Int, row: Int) -> CGFloat {
        let sectionOffset = sectionProviderAt(section)
        return sectionOffset.0.heightForCellAt(section: sectionOffset.1, row: row)
    }

    func customize(_ cell: UITableViewCell, section: Int, row: Int) {
        let sectionOffset = sectionProviderAt(section)
        sectionOffset.0.customize(cell, section: sectionOffset.1, row: row)
    }

    func onCellSelectedAt(section: Int, row: Int) {
        let sectionOffset = sectionProviderAt(section)
        sectionOffset.0.onCellSelectedAt(section: sectionOffset.1, row: row)
    }
}
