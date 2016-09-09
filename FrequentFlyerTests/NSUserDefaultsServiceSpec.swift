import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class NSUserDefaultsServiceSpec: QuickSpec {
    override func spec() {
        describe("NSUserDefaultsService") {
            var subject: NSUserDefaultsService!
            
            beforeEach {
                subject = NSUserDefaultsService()
            }
            
            describe("Getting data from NSUserDefaults") {
                context("When asking for data that is not there") {
                    var fetchedData: NSData?
                    
                    beforeEach {
                        fetchedData = subject.getDataForKey("turtle mystery")
                    }
                    
                    it("returns nil") {
                        expect(fetchedData).to(beNil())
                    }
                }
                
                context("When asking for data that exists") {
                    var fetchedData: NSData?
                    var storedData: NSData?
                    
                    beforeEach {
                        let sillyString = "silly turtle string"
                        storedData = sillyString.dataUsingEncoding(NSUTF8StringEncoding)
                        NSUserDefaults.standardUserDefaults().setObject(storedData, forKey: "silly data")
                        
                        fetchedData = subject.getDataForKey("silly data")
                    }
                    
                    afterEach {
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("silly data")
                    }
                    
                    it("returns the data stored under that key") {
                        expect(fetchedData).to(equal(storedData))
                    }
                }
            }
            
            describe("Setting data on NSUserDefaults") {
                var storedData: NSData?
                var fetchedData: NSData?
                
                beforeEach {
                    let sillyString = "silly turtle string"
                    storedData = sillyString.dataUsingEncoding(NSUTF8StringEncoding)
                    subject.setData(storedData!, forKey: "silly data")
                    
                    fetchedData = NSUserDefaults.standardUserDefaults().dataForKey("silly data")
                }
                
                afterEach {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("silly data")
                }
                
                it("returns the data stored under that key") {
                    expect(fetchedData).to(equal(storedData))
                }
            }
        }
    }
}
