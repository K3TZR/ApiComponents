//
//  PropertyWrappers.swift
//  UtilityComponents/Shared
//
//  Created by Douglas Adams on 5/16/22.
//

import Foundation

// ----------------------------------------------------------------------------
// MARK: - Property Wrappers

@propertyWrapper
public class Atomic<Value> {
  public var projectedValue: Atomic { return self }
  
  private var value: Value
  private var queue: DispatchQueue
  
  public init(_ wrappedValue: Value, _ queue: DispatchQueue) {
    self.value = wrappedValue
    self.queue = queue
  }
  
  public var wrappedValue: Value {
    get { queue.sync { value }}
    set { queue.sync { value = newValue }} }
  
  public func mutate(_ mutation: (inout Value) -> Void) {
    return queue.sync { mutation(&value) }
  }
}
