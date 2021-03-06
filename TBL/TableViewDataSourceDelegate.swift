/// Serves as a UITableViewDataSource and UITableViewDelegate
class TableViewDataSourceDelegate: NSObject {

    fileprivate let sectionProvider: SectionProvider

    init(sectionProvider: SectionProvider) {
        self.sectionProvider = sectionProvider
    }
}

extension TableViewDataSourceDelegate: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionProvider.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionProvider.numberOfRowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellForClass(sectionProvider.classForCellAt(section: indexPath.section, row: indexPath.row))
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionProvider.headerFor(section) != nil ? "A" : nil
    }
}

extension TableViewDataSourceDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        sectionProvider.customize(cell, section: indexPath.section, row: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionProvider.heightForCellAt(section: indexPath.section, row: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sectionProvider.onCellSelectedAt(section: indexPath.section, row: indexPath.row)
    }

    // MARK: Header

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionProvider.headerFor(section)?.createHeader()
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = sectionProvider.headerFor(section) else { return }
        header.customizeHeader(view)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionProvider.headerFor(section)?.height ?? 0
    }
}
