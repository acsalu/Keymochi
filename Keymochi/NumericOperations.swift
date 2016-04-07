//
//  NumericOperations.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/24/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

protocol ArithmeticType: IntegerLiteralConvertible {
  func + (lhs: Self, rhs: Self) -> Self
  func - (lhs: Self, rhs: Self) -> Self
  func * (lhs: Self, rhs: Self) -> Self
  func / (lhs: Self, rhs: Self) -> Self
}

extension Int: ArithmeticType {}
extension Double: ArithmeticType {}
extension Float: ArithmeticType {}

protocol DoubleConvertible {
  var doubleValue: Double { get }
}

extension Int: DoubleConvertible {
  var doubleValue: Double { return Double(self) }
}

extension Double: DoubleConvertible {
  var doubleValue: Double { return Double(self) }
}

extension Float: DoubleConvertible {
  var doubleValue: Double { return Double(self) }
}

extension SequenceType where Generator.Element: ArithmeticType {
  var sum: Generator.Element {
    return reduce(0) { $0 + $1 }
  }
}

extension CollectionType where Generator.Element: DoubleConvertible, Generator.Element: ArithmeticType, Index.Distance: DoubleConvertible, Index == Int {
  var mean: Double? {
    guard !isEmpty else {
      return nil
    }
    return sum.doubleValue / count.doubleValue
  }
  
  var standardDeveation: Double? {
    guard !isEmpty else {
      return nil
    }
    let mean = self.mean!
    return sqrt(map { pow($0.doubleValue - mean.doubleValue, 2.0) }.reduce(0) { $0 + $1 })
  }
}