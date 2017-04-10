import Foundation

protocol AnyMultipleSectionRow {

    var cellClass: AnyUITableViewCellClass { get }

    func rowCount(section: Int) -> Int
    func customize(_ cell: UITableViewCell, section: Int, row: Int)
    func heightForRow(section: Int, row: Int) -> CGFloat
}
