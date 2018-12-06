// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import XCTest
import CoreData
@testable import BookishModel

class SeriesScannerTests: ModelTestCase {

    func scanBook(title: String, subtitle: String? = nil) -> Book {
        let container = makeTestContainer()
        let context = container.viewContext
        
        let book = Book(context: context)
        book.name = title
        book.subtitle = subtitle

        let scanner = SeriesScanner(context: context)
        scanner.run()
        
        return book
    }
    
    func test1() {
        // name, series and book all in the title
        let book = scanBook(title: "The Amtrak Wars: Cloud Warrior Bk. 1")
        XCTAssertEqual(book.name, "Cloud Warrior")
        XCTAssertEqual(book.series?.series?.name, "The Amtrak Wars")
        XCTAssertEqual(book.series?.index, 1)
    }
    
    func test2() {
        // name series in the title, series in the subtitle
        let book = scanBook(title: "Carpe Jugulum (Discworld Novel)", subtitle: "Discworld Novel")
        XCTAssertEqual(book.name, "Carpe Jugulum")
        XCTAssertEqual(book.series?.series?.name, "Discworld Novel")
        XCTAssertEqual(book.series?.index, 0)

    }

    func test3() {
        // series in brackets with "S." at the end
        let book = scanBook(title: "Effendi: The Second Arabesk (Arabesk S.)")
        XCTAssertEqual(book.name, "Effendi: The Second Arabesk")
        XCTAssertEqual(book.series?.series?.name, "Arabesk")
        XCTAssertEqual(book.series?.index, 0)
        
    }

    func test4() {
        // series in brackets and subtitle, but with "The" appended in the title
        let book = scanBook(title: "The Darkest Road (The Fionavar Tapestry)", subtitle: "Fionavar Tapestry")
        XCTAssertEqual(book.name, "The Darkest Road")
        XCTAssertEqual(book.series?.series?.name, "Fionavar Tapestry")
        XCTAssertEqual(book.series?.index, 0)
        
    }

    func test5() {
        // series and book in the subtitle, in brackets
        let book = scanBook(title: "Ancillary Justice", subtitle: "(Imperial Radch Book 1)")
        XCTAssertEqual(book.name, "Ancillary Justice")
        XCTAssertEqual(book.series?.series?.name, "Imperial Radch")
        XCTAssertEqual(book.series?.index, 1)
        
    }
    
    func test6() {
        // series in brackets in the title, and in the subtitle, but with "A" appended in the title
        let book = scanBook(title: "The Colour of Magic (A Discworld Novel)", subtitle: "Discworld Novel")
        XCTAssertEqual(book.name, "The Colour of Magic")
        XCTAssertEqual(book.series?.series?.name, "Discworld Novel")
        XCTAssertEqual(book.series?.index, 0)
    }

    func test7() {
        // series, name and number in the title, series also in the subtitle
        let book = scanBook(title: "Chung Kuo: Beneath the Tree of Heaven Bk. 5", subtitle: "Chung Kuo")
        XCTAssertEqual(book.name, "Beneath the Tree of Heaven")
        XCTAssertEqual(book.series?.series?.name, "Chung Kuo")
        XCTAssertEqual(book.series?.index, 5)
        
    }
}


