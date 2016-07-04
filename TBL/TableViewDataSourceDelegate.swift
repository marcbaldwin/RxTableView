/// Serves as a UITableViewDataSource and UITableViewDelegate
class TableViewDataSourceDelegate: NSObject {

    private let sectionProvider: SectionProvider

    init(sectionProvider: SectionProvider) {
        self.sectionProvider = sectionProvider
    }

    private func rowAtIndexPath(indexPath: NSIndexPath) -> Row {
        return sectionProvider.sectionAtIndex(indexPath.section).rowAtIndex(indexPath.row)
    }
}

extension TableViewDataSourceDelegate: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionProvider.sectionCount
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionProvider.sectionAtIndex(section).rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellForClass(rowAtIndexPath(indexPath).cellClass)
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionProvider.sectionAtIndex(section).header != nil ? "A" : nil
    }
}

extension TableViewDataSourceDelegate: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        rowAtIndexPath(indexPath).customizeCell(cell)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowAtIndexPath(indexPath).height
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionProvider.sectionAtIndex(section).header?.createHeader()
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = sectionProvider.sectionAtIndex(section).header else { return }
        header.customizeHeader(view)
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionProvider.sectionAtIndex(section).header?.height ?? 0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowAtIndexPath(indexPath).didSelectRow()
    }
}
