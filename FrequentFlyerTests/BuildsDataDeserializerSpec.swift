import XCTest
import Quick
import Nimble
@testable import FrequentFlyer

class BuildsDataDeserializerSpec: QuickSpec {
    override func spec() {
        describe("BuildsDataDeserializer") {
            var subject: BuildsDataDeserializer!
            
            beforeEach {
                subject = BuildsDataDeserializer()
            }
            
            describe("Deserializing builds data that is all valid") {
                var result: (builds: [Build]?, error: DeserializationError?)
                
                beforeEach {
                    let validDataJSONArray = [
                        [
                            "id" : 2,
                            "status" : "status 2",
                            "job_name" : "turtle job name"
                        ],
                        [
                            "id" : 1,
                            "status" : "status 1",
                            "job_name" : "crab job name"
                        ]
                    ]
                    
                    let validData = try! NSJSONSerialization.dataWithJSONObject(validDataJSONArray, options: .PrettyPrinted)
                    result = subject.deserialize(validData)
                }
                
                it("returns a build for each JSON build entry") {
                    guard let builds = result.builds else {
                        fail("Failed to return any builds from the JSON data")
                        return
                    }
                    
                    if builds.count != 2 {
                        fail("Expected to return 2 builds, returned \(builds.count)")
                        return
                    }
                    
                    expect(builds[0]).to(equal(Build(id: 2, jobName: "turtle job name", status: "status 2")))
                    expect(builds[1]).to(equal(Build(id: 1, jobName: "crab job name", status: "status 1")))
                }
                
                it("returns no error") {
                    expect(result.error).to(beNil())
                }
            }
            
            describe("Deserializing build data where some of the data is invalid") {
                var result: (builds: [Build]?, error: DeserializationError?)
                
                context("Missing required 'status' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "status" : "status",
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 2,
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 1,
                                "status" : "status 1",
                                "job_name" : "crab job name"
                            ]
                        ]
                        
                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }
                    
                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }
                        
                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }
                        
                        expect(builds[0]).to(equal(Build(id: 3, jobName: "turtle job name", status: "status")))
                        expect(builds[1]).to(equal(Build(id: 1, jobName: "crab job name", status: "status 1")))
                    }
                    
                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
                
                context("'status' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "status" : "status",
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 2,
                                "status" : 100,
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 1,
                                "status" : "status 1",
                                "job_name" : "crab job name"
                            ]
                        ]
                        
                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }
                    
                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }
                        
                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }
                        
                        expect(builds[0]).to(equal(Build(id: 3, jobName: "turtle job name", status: "status")))
                        expect(builds[1]).to(equal(Build(id: 1, jobName: "crab job name", status: "status 1")))
                    }
                    
                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
                
                context("Missing required 'job_name' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "status" : "status",
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 2,
                                "status" : "crab status",
                                "job_name" : "crab job name"
                            ],
                            [
                                "id" : 1,
                                "status" : "status 1",
                            ]
                        ]
                        
                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }
                    
                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }
                        
                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }
                        
                        expect(builds[0]).to(equal(Build(id: 3, jobName: "turtle job name", status: "status")))
                        expect(builds[1]).to(equal(Build(id: 2, jobName: "crab job name", status: "crab status")))
                    }
                    
                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
                
                context("'job_name' field is not a string") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : 3,
                                "status" : "status",
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 2,
                                "status" : "crab status",
                                "job_name" : "crab job name"
                            ],
                            [
                                "id" : 1,
                                "status" : "status 1",
                                "job_name" : 1000
                            ]
                        ]
                        
                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }
                    
                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }
                        
                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }
                        
                        expect(builds[0]).to(equal(Build(id: 3, jobName: "turtle job name", status: "status")))
                        expect(builds[1]).to(equal(Build(id: 2, jobName: "crab job name", status: "crab status")))
                    }
                    
                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
                
                context("Missing required 'id' field") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "status" : "status",
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 2,
                                "status" : "crab status",
                                "job_name" : "crab job name"
                            ],
                            [
                                "id" : 1,
                                "status" : "status 1",
                                "job_name" : "crab job name"
                            ]
                        ]
                        
                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }
                    
                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }
                        
                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }
                        
                        expect(builds[0]).to(equal(Build(id: 2, jobName: "crab job name", status: "crab status")))
                        expect(builds[1]).to(equal(Build(id: 1, jobName: "crab job name", status: "status 1")))
                    }
                    
                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
                
                context("'id' field is not an int") {
                    beforeEach {
                        let partiallyValidDataJSONArray = [
                            [
                                "id" : "id value",
                                "status" : "status",
                                "job_name" : "turtle job name"
                            ],
                            [
                                "id" : 2,
                                "status" : "crab status",
                                "job_name" : "crab job name"
                            ],
                            [
                                "id" : 1,
                                "status" : "status 1",
                                "job_name" : "crab job name"
                            ]
                        ]
                        
                        let partiallyValidData = try! NSJSONSerialization.dataWithJSONObject(partiallyValidDataJSONArray, options: .PrettyPrinted)
                        result = subject.deserialize(partiallyValidData)
                    }
                    
                    it("returns a build for each valid JSON build entry") {
                        guard let builds = result.builds else {
                            fail("Failed to return any builds from the JSON data")
                            return
                        }
                        
                        if builds.count != 2 {
                            fail("Expected to return 2 builds, returned \(builds.count)")
                            return
                        }
                        
                        expect(builds[0]).to(equal(Build(id: 2, jobName: "crab job name", status: "crab status")))
                        expect(builds[1]).to(equal(Build(id: 1, jobName: "crab job name", status: "status 1")))
                    }
                    
                    it("returns no error") {
                        expect(result.error).to(beNil())
                    }
                }
            }
            
            describe("Given data cannot be interpreted as JSON") {
                var result: (builds: [Build]?, error: DeserializationError?)
                
                beforeEach {
                    let buildsDataString = "some string"
                    
                    let invalidbuildsData = buildsDataString.dataUsingEncoding(NSUTF8StringEncoding)
                    result = subject.deserialize(invalidbuildsData!)
                }
                
                it("returns nil for the builds") {
                    expect(result.builds).to(beNil())
                }
                
                it("returns an error") {
                    expect(result.error).to(equal(DeserializationError(details: "Could not interpret data as JSON dictionary", type: .InvalidInputFormat)))
                }
            }
        }
    }
}
