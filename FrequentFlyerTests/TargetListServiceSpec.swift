import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class TargetListServiceSpec: QuickSpec {
    class MockNSUserDefaultsService: NSUserDefaultsService {
        override func getDataForKey(key: String) -> NSData? {
            return dataDictionary[key]
        }
        
        var dataDictionary = [String : NSData]()
        
        func returnData(data: NSData, forKey key: String) {
            dataDictionary[key] = data
        }
    }
    
    class MockTargetListDataDeserializer: TargetListDataDeserializer {
        var inputResponseData: NSData?
        var deserializedTargetList: [Target]?
        
        override func deserialize(responseData: NSData) -> (targetList: [Target]?, error: DeserializationError?) {
            inputResponseData = responseData
            deserializedTargetList = [Target(name: "turtle target", api: "turtle api", teamName: "turtle team", token: Token(value: "val"))]
            return (deserializedTargetList!, nil)
        }
    }
    
    override func spec() {
        describe("TargetListService") {
            var subject: TargetListService!
            var mockNSUserDefaultsService: MockNSUserDefaultsService!
            var mockTargetListDataDeserializer: MockTargetListDataDeserializer!
            
            beforeEach {
                subject = TargetListService()
                
                mockNSUserDefaultsService = MockNSUserDefaultsService()
                subject.nsUserDefaultsService = mockNSUserDefaultsService
                
                mockTargetListDataDeserializer = MockTargetListDataDeserializer()
                subject.targetListDataDeserializer = mockTargetListDataDeserializer
            }
            
            describe("Getting a target list") {
                var outputTargetList: [Target]?
                
                context("When the user defaults service returns nil") {
                    beforeEach {
                        outputTargetList = subject.getTargetList()
                    }
                    
                    it("returns an empty Target list") {
                        expect(outputTargetList).toNot(beNil())
                        expect(outputTargetList!.count).to(equal(0))
                    }
                }
                
                context("When the user defaults service returns some data for targets") {
                    var storedTargetsData: NSData!
                    
                    beforeEach {
                        storedTargetsData = NSData()
                        mockNSUserDefaultsService.returnData(storedTargetsData, forKey: "targets")
                        outputTargetList = subject.getTargetList()
                    }
                    
                    it("passes the retrieved data to the deserializer") {
                        expect(mockTargetListDataDeserializer.inputResponseData).to(beIdenticalTo(storedTargetsData))
                    }
                    
                    it("returns the deserialized target list data") {
                        expect(outputTargetList![0]).to(beIdenticalTo(mockTargetListDataDeserializer!.deserializedTargetList![0]))
                    }
                }
            }
        }
    }
}
