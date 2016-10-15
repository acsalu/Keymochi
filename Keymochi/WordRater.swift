//
//  WordRater.swift
//  Keymochi
//
//  Created by Claire Opila on 10/14/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift
class Valence: Object {

let positiveWords: Set<String> = wordSetFromFile("positive-words")
let negativeWords: Set<String> = wordSetFromFile("negative-words")
//: Wrap the **lowercaseString** method in a function to allow function composition.
func toLowercase(s:String) -> String {
    return s.lowercaseString
}
//: **removePunctuation**, does what it says on the tin.
func removePunctuation(str:String) -> String {
    return str.componentsSeparatedByCharactersInSet(NSCharacterSet.punctuationCharacterSet()).joinWithSeparator("")
}
//: Split a **String** into words, filtering out empty strings
func words(str:String) -> [String] {
    return str.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter { !$0.isEmpty }
}

typealias Rating = Int
//: Positive words are given a rating of **1**, negative **-1**, neutral **0**.
func basicWordRater(word:String) -> Rating {
    if positiveWords.contains(word) { return 1 }
    if negativeWords.contains(word) { return -1 }
    return 0
}
//: Apply the **ratingFunc** function to each word in the supplied **Array**, accumulating the result
func rateWords(ratingFunc:String -> Rating, words:[String]) -> Rating {
    return words.reduce(0) { rating, word in rating + ratingFunc(word) }
}

func ratingDescription(r:Rating) -> String {
    switch r {
    case Int.min..<0: return (1...abs(r)).reduce("") { str, _ in str + "😱" }
    case 1..<Int.max: return (1...r).reduce("") { str, _ in str + "😀" }
    default: return "😶"
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
let rateString = removePunctuation
    •> toLowercase
    •> words
    •> rateWords(basicWordRater)
    •> ratingDescription
}
