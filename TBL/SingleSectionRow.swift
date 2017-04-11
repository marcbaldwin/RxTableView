import Foundation

public class SingleSectionRow<C: UITableViewCell>  {

    let cellClass: AnyUITableViewCellClass
    fileprivate let customizer: (C) -> Void
    fileprivate var heightProvider: Provider<CGFloat, Void> = .static(44)
    fileprivate var onSelect: ((Void) -> Void)? = nil
    fileprivate var visible = When<Void>.always

    init(cellClass: C.Type, customizer: @escaping (C) -> Void) {
        self.cellClass = cellClass
        self.customizer = customizer
    }

    @discardableResult public func with(height: @escaping (Void) -> CGFloat) -> SingleSectionRow {
        self.heightProvider = .dynamic(height)
        return self
    }

    @discardableResult public func with(height: CGFloat) -> SingleSectionRow {
        self.heightProvider = .static(height)
        return self
    }

    @discardableResult public func onSelect(_ handler: @escaping (Void) -> Void) -> SingleSectionRow {
        self.onSelect = handler
        return self
    }

    @discardableResult public func visible(_ clause: When<Void>) -> SingleSectionRow {
        self.visible = clause
        return self
    }
}

extension SingleSectionRow: SingleSectionRowDelegate {

    var rowCount: Int { return visible.evaluate() ? 1 : 0 }

    func heightForRowAtIndex(_ index: Int) -> CGFloat {
        return heightProvider.value()
    }

    func customizeCell(_ cell: UITableViewCell, atIndex index: Int) {
        guard let cell = cell as? C else { fatalError() }
        customizer(cell)
    }

    func onSelectCellAtIndex(_ index: Int) {
        onSelect?()
    }
}
