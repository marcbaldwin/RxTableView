import UIKit

public extension UITableView {

    public func registerClassesForCellReuse(cellClasses: UITableViewCell.Type...) {
        cellClasses.forEach { registerClassForCellReuse($0) }
    }

    public func registerClassesForCellReuse(cellClasses: [UITableViewCell.Type]) {
        cellClasses.forEach { registerClassForCellReuse($0) }
    }

    public func registerClassForCellReuse(cellClass: UITableViewCell.Type) {
        registerClass(cellClass, forCellReuseIdentifier: "\(cellClass)")
    }

    public func dequeueReusableCellForClass<T>(cellClass: T.Type) -> T {
        return dequeueReusableCellWithIdentifier("\(cellClass)")! as! T
    }
}

public extension UITableView {

    public func registerClassForHeaderFooterViewReuse(aClass: UIView.Type) {
        registerClass(aClass, forHeaderFooterViewReuseIdentifier: "\(aClass)")
    }

    public func dequeueReusableHeaderFooterViewWithClass(aClass: UIView.Type) -> UIView? {
        return dequeueReusableHeaderFooterViewWithIdentifier("\(aClass)")
    }
}