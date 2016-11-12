//
//  KeymochiTests.swift
//  KeymochiTests
//
//  Created by Huai-Che Lu on 2/28/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
@testable import Keymochi

class DataManagerSpec: QuickSpec {
    override func spec() {
        describe("DataManager") {
            var testRealm: Realm!
            
            beforeEach {
                var config = Realm.Configuration()
                config.inMemoryIdentifier = "data-manager-spec"
                testRealm = try! Realm(configuration: config)
                DataManager.sharedInatance.realm = testRealm
            }
            
            afterEach {
                testRealm.beginWrite()
                testRealm.deleteAll()
                try! testRealm.commitWrite()
            }
            
            it("Add a data chunk to the Realm") {
                expect(testRealm.objects(DataChunk.self).count).to(equal(0))
                
                let dataChunk = DataChunk()
                
                DataManager.sharedInatance.addDataChunk(dataChunk)
                expect(testRealm.objects(DataChunk.self).count).to(equal(1))
                
                let quriedDataChunk = testRealm.object(ofType: DataChunk.self, forPrimaryKey: dataChunk.realmId as AnyObject)
                expect(quriedDataChunk).notTo(beNil())
            }
        }
    }
}
