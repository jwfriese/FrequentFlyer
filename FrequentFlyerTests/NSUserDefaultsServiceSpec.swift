import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class NSUserDefaultsServiceSpec: XCTestCase {
    func test_getDataForKey_whenTheDataDoesNotExist_returnsNil() {
        let subject = NSUserDefaultsService()
        
        let fetchedData = subject.getDataForKey("turtle mystery")
        expect(fetchedData).to(beNil())
    }
    
    func test_setDataForKey_setsTheDataOnStandardNSUserDefaults() {
        let subject = NSUserDefaultsService()
        
        let sillyString = "silly turtle string"
        let storedData = sillyString.dataUsingEncoding(NSUTF8StringEncoding)
        subject.setData(storedData!, forKey: "silly turtle data")
        
        let fetchedData = NSUserDefaults.standardUserDefaults().dataForKey("silly turtle data")
        
        expect(fetchedData).to(equal(storedData))
        NSUserDefaults.standardUserDefaults().removeObjectForKey("silly turtle data")
    }
}
