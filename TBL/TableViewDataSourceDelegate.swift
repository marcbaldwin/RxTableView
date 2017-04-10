/// Serves as a UITableViewDataSource and UITableViewDelegate
class TableViewDataSourceDelegate: NSObject {

    fileprivate let sectionProvider: SectionProvider

    init(sectionProvider: SectionProvider) {
        self.sectionProvider = sectionProvider
    }

    fileprivate func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        return sectionProvider.sectionAtIndex(indexPath.section).rowAtIndex(indexPath.row)
    }
}

extension TableViewDataSourceDelegate: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionProvider.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionProvider.sectionAtIndex(section).rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellForClass(sectionProvider.classForCellAt(section: indexPath.section, row: indexPath.row))
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionProvider.sectionAtIndex(section).header != nil ? "A" : nil
    }
}

extension TableViewDataSourceDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        rowAtIndexPath(indexPath).customizeCell(cell)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowAtIndexPath(indexPath).height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionProvider.sectionAtIndex(section).header?.createHeader()
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = sectionProvider.sectionAtIndex(section).header else { return }
        header.customizeHeader(view)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionProvider.sectionAtIndex(section).header?.height ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowAtIndexPath(indexPath).didSelectRow()
    }
}
