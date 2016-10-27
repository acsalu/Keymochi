//
//  WordSentiment.swift
//  Keymochi
//
//  Created by Claire Opila on 10/26/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

class WordManager  {

//    var positiveWords : Set<String> = []
//    var negativeWords: Set<String> = []
    
//    init(positiveWords:  Set<String>, negativeWords: Set<String> ) {
//        self.positiveWords = positiveWords
//        self.negativeWords = negativeWords
//       
//        // do initial setup or establish an initial connection
//    }

    class func wordSetFromFile(file: String) -> Set<String> {
        let text = stringFromFile(file: file)!
        let words = text.characters.split { $0 == "\n" }.map { String($0) }
        return Set(words)
    }

    class func stringFromFile(file:String) -> String? {
        let path = Bundle.main.path(forResource: file, ofType: "txt")
        do { return try String(contentsOfFile: path!) }
        catch { return .none }
    }


//    class var positiveWords : Set<String> {
//         return WordManager.wordSetFromFile(file: "positive-words")
//    }
//    
//    class var negativeWords: Set<String> {
//        return WordManager.wordSetFromFile(file: "negative-words")
//    }
    

    var positiveWords = WordManager.wordSetFromFile(file: "positive-words")
    var negativeWords = WordManager.wordSetFromFile(file: "negative-words")
}

//    class func formatString (wordArr : [String]) -> Float {
//        var sum: NSInteger = 0
//        var ratingArr: [NSNumber]
//        for unformString in wordArr {
//            var newWord = unformString.lowercased()
//            if positiveWords.contains(newWord) { ratingArr.append(1) }
//            if negativeWords.contains(newWord) { ratingArr.append(-1) }
//            else{
//                ratingArr.append(0)
//            }
//            for rating in ratingArr {
//                sum = sum + Int(rating)
//            }
//            let weighted = sum/ratingArr.count
//            return Float(weighted)
//            
//        }
//    }

    
//}











