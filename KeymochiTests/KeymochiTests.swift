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
        DataManager.sharedInatance.setRealm(testRealm)
      }
      
      afterEach {
        testRealm.beginWrite()
        testRealm.deleteAll()
        try! testRealm.commitWrite()
      }
      
      it("Add a data chunk to the Realm") {
        expect(testRealm.objects(DataChunk).count).to(equal(0))
        
        let dataChunk = DataChunk()
       
        DataManager.sharedInatance.addDataChunk(dataChunk)
        expect(testRealm.objects(DataChunk).count).to(equal(1))
        
        let quriedDataChunk = testRealm.objectForPrimaryKey(DataChunk.self, key: dataChunk.realmId)
        expect(quriedDataChunk).notTo(beNil())
      }
      
      it("Update a data chunk in the Realm") {
        
        let dataChunk = DataChunk()
        
        expect(dataChunk.emotion).to(beNil())
        expect(dataChunk.parseId).to(beNil())
        
        let emotion = Emotion.Neutral
        let parseId = "axcb12k"
        
        DataManager.sharedInatance.addDataChunk(dataChunk)
        DataManager.sharedInatance.updateDataChunk(dataChunk, withEmotion: emotion, andParseId: parseId)
        let quriedDataChunk = testRealm.objectForPrimaryKey(DataChunk.self, key: dataChunk.realmId)
        expect(quriedDataChunk?.emotion).to(equal(emotion))
        expect(quriedDataChunk?.parseId).to(equal(parseId))
        
      }
      
    }
  }
}