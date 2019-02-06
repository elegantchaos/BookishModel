// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Series: DetailOwner {
    public func getProvider() -> DetailProvider {
        return SeriesDetailProvider()
    }
}

class SeriesDetailProvider: DetailProvider {
    var sortedEntries = [SeriesEntry]()
    
    var titleProperty: String? {
        return "name"
    }
    
    var subtitleProperty: String? {
        return nil
    }
    
    var sectionCount: Int {
        return 1
    }
    
    func sectionTitle(for section: Int) -> String {
        return ""
    }
    
    func itemCount(for section: Int) -> Int {
        return sortedEntries.count
    }
    
    func info(section: Int, row: Int) -> DetailItem {
        let book = sortedEntries[row].book
        let info = PersonBookDetailItem(book: book, absolute: row, index: row, source: nil)
        return info
    }
    
    func filter(for selection: [ModelObject], editing: Bool, context: DetailContext) {
        if let series = selection.first as? Series, let entries = series.entries?.sortedArray(using: context.entrySorting) as? [SeriesEntry] {
            sortedEntries.removeAll()
            sortedEntries.append(contentsOf: entries)
        }
    }
}




/*
 
 override func configureView() {
 if let series = representedObject, nameLabel != nil {
 bindings.append(TextFieldBinding(for: nameLabel, to: series, path: "name"))
 bindings.append(TextViewBinding(for: notesView, to: series, path: "notes", setIfNull: true))
 if let imageData = series.image {
 imageView.image = UIImage(data: imageData)
 } else {
 imageView.image = placeholderImage
 }
 
 let entries = series.entries?.sortedArray(using: application.viewModel.entrySorting) as! [SeriesEntry]
 sortedEntries.removeAll()
 sortedEntries.append(contentsOf: entries)
 }
 }
 
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return sortedEntries.count
 }
 
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let entry = sortedEntries[indexPath.row]
 let cell = tableView.dequeueReusableCell(withIdentifier: "book") as! SeriesBookRow // if we fail here, it's a coding error as all possible view types should have been registered
 if let book = entry.book {
 cell.setup(row: indexPath.row, book: book)
 }
 
 return cell
 }
 
 */

