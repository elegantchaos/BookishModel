// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import XCTest
import CoreData
import Actions

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
        XCTAssertTrue(check(book: book, series: series, position: 2))
    }

    func testAction() {
        let performed = expectation(description: "performed")
        let manager = ActionManager()
        let container = makeTestContainer()
        manager.register([ScanSeriesAction(identifier: "ScanSeries")])
        let info = ActionInfo(sender: self)
        info[ActionContext.modelKey] = container.managedObjectContext
        info.registerNotification { (stage, context) in
            if stage == .didPerform {
                performed.fulfill()
            }
        }
        
        manager.perform(identifier: "ScanSeries", info: info)
        wait(for: [performed], timeout: 1.0)
    }
    
    func test1() {
        // name, series and book all in the title
        let book = scanBook(title: "The Amtrak Wars: Cloud Warrior Bk. 1")
        XCTAssertEqual(book.name, "Cloud Warrior")
        XCTAssertTrue(check(book: book, seriesName: "The Amtrak Wars", position: 1))
    }
    
    func test2() {
        // name series in the title, series in the subtitle
        let book = scanBook(title: "Carpe Jugulum (Discworld Novel)", subtitle: "Discworld Novel")
        XCTAssertEqual(book.name, "Carpe Jugulum")
        XCTAssertTrue(check(book: book, seriesName: "Discworld Novel", position: 0))

    }

    func test3() {
        // series in brackets with "S." at the end
        let book = scanBook(title: "Effendi: The Second Arabesk (Arabesk S.)")
        XCTAssertEqual(book.name, "Effendi: The Second Arabesk")
        XCTAssertTrue(check(book: book, seriesName: "Arabesk", position: 0))
        
    }

    func test4() {
        // series in brackets and subtitle, but with "The" appended in the title
        let book = scanBook(title: "The Darkest Road (The Fionavar Tapestry)", subtitle: "Fionavar Tapestry")
        XCTAssertEqual(book.name, "The Darkest Road")
        XCTAssertTrue(check(book: book, seriesName: "Fionavar Tapestry", position: 0))

        let book2 = scanBook(title: "The Darkest Road (Fionavar Tapestry)", subtitle: "The Fionavar Tapestry")
        XCTAssertEqual(book2.name, "The Darkest Road")
        XCTAssertTrue(check(book: book2, seriesName: "Fionavar Tapestry", position: 0))
    }

    func test5() {
        // series and book in the subtitle, in brackets
        let book = scanBook(title: "Ancillary Justice", subtitle: "(Imperial Radch Book 1)")
        XCTAssertEqual(book.name, "Ancillary Justice")
        XCTAssertTrue(check(book: book, seriesName: "Imperial Radch", position: 1))
    }
    
    func test6() {
        // series in brackets in the title, and in the subtitle, but with "A" appended in the title
        let book = scanBook(title: "The Colour of Magic (A Discworld Novel)", subtitle: "Discworld Novel")
        XCTAssertEqual(book.name, "The Colour of Magic")
        XCTAssertTrue(check(book: book, seriesName: "Discworld Novel", position: 0))

        let book2 = scanBook(title: "The Colour of Magic (Discworld Novel)", subtitle: "A Discworld Novel")
        XCTAssertEqual(book2.name, "The Colour of Magic")
        XCTAssertTrue(check(book: book2, seriesName: "Discworld Novel", position: 0))
    }

    func test7() {
        // series, name and number in the title, series also in the subtitle
        let book = scanBook(title: "Chung Kuo: Beneath the Tree of Heaven Bk. 5", subtitle: "Chung Kuo")
        XCTAssertEqual(book.name, "Beneath the Tree of Heaven")
        XCTAssertTrue(check(book: book, seriesName: "Chung Kuo", position: 5))
    }

    func test8() {
        // name and book, series in brackets with "S." at the end
        let book = scanBook(title: "Name Book 2 (Series S.)")
        XCTAssertEqual(book.name, "Name")
        XCTAssertTrue(check(book: book, seriesName: "Series", position: 2))
    }

    func test9() {
        // series in brackets with "S." at the end, also set as the subtitle
        let book = scanBook(title: "Effendi: The Second Arabesk (Arabesk S.)", subtitle: "Arabesk")
        XCTAssertEqual(book.name, "Effendi: The Second Arabesk")
        XCTAssertEqual(book.subtitle, "")
        XCTAssertTrue(check(book: book, seriesName: "Arabesk", position: 0))
    }

    func test10() {
        // series in brackets with "S." at the end, also set as the subtitle
        let book = scanBook(title: "The Better Part of Valour: A Confederation Novel (Valour Confederation Book 2)")
        XCTAssertEqual(book.name, "The Better Part of Valour: A Confederation Novel")
        XCTAssertEqual(book.subtitle, "")
        XCTAssertTrue(check(book: book, seriesName: "Valour Confederation", position: 2))
    }

    func test11() {
        // subtitle is name of series, with number at the end
        let book = scanBook(title: "The Amber Citadel", subtitle: "Jewelfire Trilogy 1")
        XCTAssertEqual(book.name, "The Amber Citadel")
        XCTAssertEqual(book.subtitle, "")
        XCTAssertTrue(check(book: book, seriesName: "Jewelfire Trilogy", position: 1))
    }
    
    func test12() {
        // subtitle is name of series, with number at the end
        seriesDetectorChannel.enabled = true
        let book = scanBook(title: "A Dance With Dragons: Part 1 Dreams and Dust (A Song of Ice and Fire, Book 5)")
        XCTAssertEqual(book.name, "A Dance With Dragons: Part 1 Dreams and Dust")
        XCTAssertEqual(book.subtitle, "")
        XCTAssertTrue(check(book: book, seriesName: "A Song of Ice and Fire", position: 5))
    }

    
}


