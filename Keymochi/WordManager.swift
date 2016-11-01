//
//  WordSentiment.swift
//  Keymochi
//
//  Created by Claire Opila on 10/26/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

public func wordSetFromFile(file: String) -> Set<String> {
    let text = stringFromFile(file: file)!
    let words = text.characters.split { $0 == "\n" }.map { String($0) }
    return Set(words)
}

public func stringFromFile(file:String) -> String? {
    let path = Bundle.main.path(forResource: file, ofType: "txt")
//    print("path", path)
    do { return try String(contentsOfFile: path!) }
    catch { return .none }
}

public var positiveWords : Set<String>! =  wordSetFromFile(file: "positive-words")
public var negativeWords: Set<String>! = wordSetFromFile(file: "negative-words")

import Foundation

class WordManager  {

    var positiveWords : Set<String> =  wordSetFromFile(file: "positive-words")
    var negativeWords: Set<String> = wordSetFromFile(file: "negative-words")
    var rating: Float = 1.0000
    
//    init(positiveWords:  Set<String>, negativeWords: Set<String> ) {
//        self.positiveWords = wordSetFromFile(file: "positive-words.txt")
//        self.negativeWords = wordSetFromFile(file: "negative-words.txt")
//       
//        // do initial setup or establish an initial connection
//    }
    
    func getRating(wordArr: [String]) -> Float {
        var sum: NSInteger = 0
        var ratingArr: [NSNumber] = []
        for unformString in wordArr {
        var newWord = unformString.lowercased()
        if positiveWords.contains(newWord) { ratingArr.append(1) }
        if negativeWords.contains(newWord) { ratingArr.append(-1) }
        else{
        ratingArr.append(0)
        }
        }
        for rating in ratingArr {
        sum = sum + Int(rating)
        }
        rating = Float(sum / ratingArr.count)

        
        return rating
    }
}










