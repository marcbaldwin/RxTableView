import UIKit

public extension UITableView {

    public func registerClassesForCellReuse(_ cellClasses: UITableViewCell.Type...) {
        cellClasses.forEach { registerClassForCellReuse($0) }
    }

    public func registerClassesForCellReuse(_ cellClasses: [UITableViewCell.Type]) {
        cellClasses.forEach { registerClassForCellReuse($0) }
    }

    public func registerClassForCellReuse(_ cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: "\(cellClass)")
    }

    public func dequeueReusableCellForClass<T>(_ cellClass: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: "\(cellClass)")! as! T
    }
}

public extension UITableView {

    public func registerClassForHeaderFooterViewReuse(_ aClass: UIView.Type) {
        register(aClass, forHeaderFooterViewReuseIdentifier: "\(aClass)")
    }

    public func dequeueReusableHeaderFooterViewWithClass(_ aClass: UIView.Type) -> UIView? {
        return dequeueReusableHeaderFooterView(withIdentifier: "\(aClass)")
    }
}
