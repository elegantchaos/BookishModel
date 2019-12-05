// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Datastore
import XCTest
import XCTestExtensions

@testable import BookishModel
@testable import Actions

class ModelTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        modelChannel.enabled = true
    }
    
//    func makeTestContainer() -> CollectionContainer {
//        let url = URL(fileURLWithPath: "/dev/null")
//        let collection = CollectionContainer(name: "Test", url: url, mode: .empty, indexed: false)
////        collection.configure(for: url)
//        return collection
//    }

    func check(book: Book, series: Series, position: Int, ignore: SeriesEntry? = nil) -> Bool {
        for entry in book.entries {
            if entry == ignore {
                continue
            }

            XCTAssertEqual(entry.series, series)
            XCTAssertEqual(entry.position, Int16(position))
            return (entry.series == series) && (entry.position == Int16(position))
        }
        
        return false
    }
    
    func check(book: Book, seriesName: String, position: Int, ignore: SeriesEntry? = nil) -> Bool {
        for entry in book.entries {
            if entry == ignore {
                continue
            }
            
            XCTAssertEqual(entry.series?.name, seriesName)
            XCTAssertEqual(entry.position, Int16(position))
            return (entry.series!.name == seriesName) && (entry.position == Int16(position))
        }
        
        return false
    }

    func check(relationship: Relationship, book: Book, person: Person) {
        XCTAssertEqual(book.roles.count, 1)
        XCTAssertEqual(relationship.books.count, 1)
        XCTAssertEqual(relationship.books.first, book)
        XCTAssertEqual(relationship.person, person)
    }

    class StoreMonitor: SimpleTestMonitor<StoreMonitor> {
        let store: Datastore
        init(expectation: XCTestExpectation, store: Datastore, checker: @escaping Checker) {
            self.store = store
            super.init(expectation: expectation, checker: checker)
        }
    }

    func checkStore(checker: @escaping StoreMonitor.Checker) -> Bool {
        let expectation = self.expectation(description: "completed")
        var monitor: StoreMonitor?
        Datastore.load(name: "Test") { result in
            switch result {
            case .failure(let error):
                XCTFail("failed to make store: \(error)")
                expectation.fulfill()
            case .success(let store):
                let newMonitor = StoreMonitor(expectation: expectation, store: store, checker: checker)
                monitor = newMonitor
                checker(newMonitor)
            }
        }

        wait(for: [expectation], timeout: 10.0)
        return monitor?.status == .ok
    }

    
      class ContainerMonitor: SimpleTestMonitor<ContainerMonitor> {
          let container: CollectionContainer
          init(expectation: XCTestExpectation, container: CollectionContainer, checker: @escaping Checker) {
              self.container = container
              super.init(expectation: expectation, checker: checker)
          }
      }
      
      func checkContainer(withURL url: URL = URL(fileURLWithPath: "/dev/null"), checker: @escaping ContainerMonitor.Checker) -> Bool {
          let expectation = self.expectation(description: "completed")
          var monitor: ContainerMonitor? = nil
          CollectionContainer.load(name: "test", url: url, mode: .empty, indexed: false) { result in
              switch result {
                  case .failure(let error):
                      XCTFail("load failed \(error)")
                      expectation.fulfill()
                  
                  case .success(let container):
                      let newMonitor  = ContainerMonitor(expectation: expectation, container: container, checker: checker)
                      checker(newMonitor)
                      monitor = newMonitor
              }
          }

          wait(for: [expectation], timeout: 10.0)
          return monitor?.status == .ok
      }

      typealias ActionMonitor = WrappedTestMonitor<ContainerMonitor>
      
      func checkAction(_ action: Action, withInfo info: ActionInfo, checker: @escaping (ActionMonitor) -> Void) -> Bool {
          let actionManager = ActionManager()
          actionManager.register([action])
          let result = checkContainer() { monitor in
              info[ActionContext.modelKey] = monitor.container
              info.registerNotification(notification: { (stage, context) in
                  if stage == .didPerform {
                      let actionMonitor = ActionMonitor(wrappedMonitor: monitor)
                      checker(actionMonitor)
                  }
              })
              
              actionManager.perform(identifier: action.identifier, info: info)
          }
          
          return result
      }

}
