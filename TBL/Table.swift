/// Types
public typealias AnyUIViewClass = UIView.Type
public typealias AnyUITableViewCellClass = UITableViewCell.Type
public typealias SectionCountProvider = Void -> Int


/// Provides sections to be displayed in a table
protocol SectionProvider {

    var cellClasses: [AnyUITableViewCellClass] { get }
    var sectionCount: Int { get }

    func sectionAtIndex(index: Int) -> Section
}

/// Provides rows to be displayed in a table
protocol RowProvider {

    var cellClasses: [AnyUITableViewCellClass] { get }
    var rowCount: Int { get }

    func rowAtIndex(index: Int) -> Row
}

/// Describes a section of a table
protocol Section {

    var rowCount: Int { get }
    var header: Header? { get }

    func rowAtIndex(index: Int) -> Row
}

/// Describes a row in a table
protocol Row {

    var cellClass: AnyUITableViewCellClass { get }
    var height: CGFloat { get }

    func customizeCell(cell: UITableViewCell)
    func didSelectRow()
}

protocol Header {

    var height: CGFloat { get }

    func createHeader() -> UIView
    func customizeHeader(headerView: UIView)
}

/// Describes a table
public class Table {

    private var sectionProviders = [SectionProvider]()
    private var dataSourceDelegate: TableViewDataSourceDelegate?

    public init() {}

    /// Adds a single section to this table
    public func addSection() -> SingleSectionDescriptor {
        let section = SingleSectionDescriptor()
        sectionProviders.append(section)
        return section
    }

    /// Adds multiple sections to this table
    /// The result of sectionCountProvider must be consistent,
    /// if the result will change, call reloadData() on the UITableView
    public func addSections(sectionCount: SectionCountProvider) -> MultipleSectionDescriptor {
        let section = MultipleSectionDescriptor(sectionCountProvider: sectionCount)
        sectionProviders.append(section)
        return section
    }

    public func attachToTableView(tableView: UITableView) {
        dataSourceDelegate = TableViewDataSourceDelegate(sectionProvider: self)
        cellClasses.forEach(tableView.registerClassForCellReuse)
        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate
    }
}

extension Table: SectionProvider {

    var cellClasses: [AnyUITableViewCellClass] {
        return sectionProviders.reduce([AnyUITableViewCellClass]()) { $0 + $1.cellClasses }
    }

    var sectionCount: Int {
        return sectionProviders.reduce(0) { $0 + $1.sectionCount }
    }

    func sectionAtIndex(index: Int) -> Section {
        var currentSection = 0
        for sectionProvider in sectionProviders {
            let sectionStartIndex = currentSection
            currentSection += sectionProvider.sectionCount
            if currentSection > index {
                let sectionIndex = (index - sectionStartIndex)
                return sectionProvider.sectionAtIndex(sectionIndex)
            }
        }
        fatalError("Section index exceeds section count")
    }
}
