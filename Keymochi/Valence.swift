//
//  WordRater.swift
//  Keymochi
//
//  Created by Claire Opila on 10/14/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

public func wordSetFromFile(file:String) -> Set<String> {
    let text = stringFromFile(file: file)!
    let words = text.characters.split { $0 == "\n" }.map { String($0) }
    return Set(words)
}

public func stringFromFile(file:String) -> String? {
    let path = Bundle.main.path(forResource: file, ofType: "txt")
    do { return try String(contentsOfFile: path!) }
    catch { return .none }
}

class Valence{
    
    let positiveWords: Set<String> = wordSetFromFile(file: "positive-words")
    let negativeWords: Set<String> = wordSetFromFile(file: "negative-words")
    //: Wrap the **lowercaseString** method in a function to allow function composition.
    func toLowercase(s:String) -> String {
        return s.lowercased()
    }
    //: **removePunctuation**, does what it says on the tin.
    func removePunctuation(str:String) -> String {
//        return str.components(separatedBy:(NSCharacterSet.punctuationCharacterSet()).joinWithSeparator("")
        return  str.components(separatedBy:CharacterSet.punctuationCharacters).joined(separator:"");
//        let str2 = strArray.joined(separator:"");
//        return str2
//    
    }
    //: Split a **String** into words, filtering out empty strings
    func words(str:String) -> [String] {
//        return  str.components(separatedBy:
//            CharacterSet.whitespaceAndNewlineCharacterSet())
//            .filter{$0 != ""};
        return str.components(separatedBy:CharacterSet.whitespacesAndNewlines).filter{$0 != ""};

    }

//    typealias Rating = [Int]
    //: Positive words are given a rating of **1**, negative **-1**, neutral **0**.
    func basicWordRater(wordsArr: [String]) -> [Int] {
        var ratingsArr: [Int] = []
        for word in wordsArr as! [String ]{
            if positiveWords.contains(word) { ratingsArr.append(1) }
            if negativeWords.contains(word) { ratingsArr.append(-1) }
            else{
                ratingsArr.append(0)
            }
        }
        return ratingsArr
        
    }
    //: Apply the **ratingFunc** function to each word in the supplied **Array**, accumulating the result

    
    func rateWords(ratingsArr: [Int]) -> NSInteger{
        var sum: NSInteger = 0
        for rating in ratingsArr {
            sum = sum + Int(rating)
        }
        return sum
        
    }

    func returnValence(str: String) -> NSInteger {
        let str1 = toLowercase(s: str)
        let str2 = removePunctuation(str: str1)
        let arrWords = words(str: str2)
        let ratedWordsArr = basicWordRater(wordsArr: arrWords)
        let overallAnalysis = rateWords(ratingsArr: ratedWordsArr)
        return overallAnalysis
    }
    

}

/*:
 # **Function composition**
 
 With all the pieces in place the rating function can now be defined.
 Simply compose together the separate functions using the forward compose operator **•>**
 
 Given an input **String**, first use **removePunctuation**, followed by **toLowercase**.
 Then split the result into an **Array** of words with the **words** function.
 Calculate a **Rating** for the **Array** by using **rateWords** with **basicWordRater** as an argument.
 Finally, convert the result into a descriptive emoji string using the **ratingDescription** function.
 */
//let rateString = removePunctuation >> toLowercase >> words >> rateWords >> basicWordRater >> ratingDescription
//}
