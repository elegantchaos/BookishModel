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
        let context = container.managedObjectContext
        
        let book = Book(context: context)
        book.name = title
        book.subtitle = subtitle

        let scanner = SeriesScanner(context: context)
        scanner.run()
        
        return book
    }
    
    func testCoverage() {
        let _ = SeriesDetector().detect(name: "", subtitle: "")
    }
    
    func testNoMatch() {
        // name, series and book all in the title
        let book = scanBook(title: "Nothing To Match Here (Oh No)")
        XCTAssertEqual(book.name, "Nothing To Match Here (Oh No)")
        XCTAssertNil(book.subtitle)
        XCTAssertEqual(book.entries?.count ?? 0, 0)
    }

    func testExistingSeries() {
        // name, series and book all in the title
        let container = makeTestContainer()
        let context = container.managedObjectContext

        let series = Series(context: context)
        series.name = "Test Series"
        let book = Book(context: context)
        book.name = "Test Series: Test Book No. 2"
        
        let scanner = SeriesScanner(context: context)
        scanner.run()
        XCTAssertEqual(book.name, "Test Book")
        check(book: book, series: series, position: 2)
    }

    func test1() {
        // name, series and book all in the title
        let book = scanBook(title: "The Amtrak Wars: Cloud Warrior Bk. 1")
        XCTAssertEqual(book.name, "Cloud Warrior")
        check(book: book, seriesName: "The Amtrak Wars", position: 1)
    }
    
    func test2() {
        // name series in the title, series in the subtitle
        let book = scanBook(title: "Carpe Jugulum (Discworld Novel)", subtitle: "Discworld Novel")
        XCTAssertEqual(book.name, "Carpe Jugulum")
        check(book: book, seriesName: "Discworld Novel", position: 0)

    }

    func test3() {
        // series in brackets with "S." at the end
        let book = scanBook(title: "Effendi: The Second Arabesk (Arabesk S.)")
        XCTAssertEqual(book.name, "Effendi: The Second Arabesk")
        check(book: book, seriesName: "Arabesk", position: 0)
        
    }

    func test4() {
        // series in brackets and subtitle, but with "The" appended in the title
        let book = scanBook(title: "The Darkest Road (The Fionavar Tapestry)", subtitle: "Fionavar Tapestry")
        XCTAssertEqual(book.name, "The Darkest Road")
        check(book: book, seriesName: "Fionavar Tapestry", position: 0)

        let book2 = scanBook(title: "The Darkest Road (Fionavar Tapestry)", subtitle: "The Fionavar Tapestry")
        XCTAssertEqual(book2.name, "The Darkest Road")
        check(book: book2, seriesName: "Fionavar Tapestry", position: 0)
    }

    func test5() {
        // series and book in the subtitle, in brackets
        let book = scanBook(title: "Ancillary Justice", subtitle: "(Imperial Radch Book 1)")
        XCTAssertEqual(book.name, "Ancillary Justice")
        check(book: book, seriesName: "Imperial Radch", position: 1)
    }
    
    func test6() {
        // series in brackets in the title, and in the subtitle, but with "A" appended in the title
        let book = scanBook(title: "The Colour of Magic (A Discworld Novel)", subtitle: "Discworld Novel")
        XCTAssertEqual(book.name, "The Colour of Magic")
        check(book: book, seriesName: "Discworld Novel", position: 0)

        let book2 = scanBook(title: "The Colour of Magic (Discworld Novel)", subtitle: "A Discworld Novel")
        XCTAssertEqual(book2.name, "The Colour of Magic")
        check(book: book2, seriesName: "Discworld Novel", position: 0)
    }

    func test7() {
        // series, name and number in the title, series also in the subtitle
        let book = scanBook(title: "Chung Kuo: Beneath the Tree of Heaven Bk. 5", subtitle: "Chung Kuo")
        XCTAssertEqual(book.name, "Beneath the Tree of Heaven")
        check(book: book, seriesName: "Chung Kuo", position: 5)
    }

    func test8() {
        // name and book, series in brackets with "S." at the end
        let book = scanBook(title: "Name Book 2 (Series S.)")
        XCTAssertEqual(book.name, "Name")
        check(book: book, seriesName: "Series", position: 2)
    }

    func test9() {
        // series in brackets with "S." at the end, also set as the subtitle
        let book = scanBook(title: "Effendi: The Second Arabesk (Arabesk S.)", subtitle: "Arabesk")
        XCTAssertEqual(book.name, "Effendi: The Second Arabesk")
        XCTAssertEqual(book.subtitle, "")
        check(book: book, seriesName: "Arabesk", position: 0)
    }

}


