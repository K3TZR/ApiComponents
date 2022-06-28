//
//  FlagCore.swift
//  
//
//  Created by Douglas Adams on 6/21/22.
//

import ComposableArchitecture

import Shared

// ----------------------------------------------------------------------------
// MARK: - Structs and Enums


// ----------------------------------------------------------------------------
// MARK: - State, Actions & Environment

public struct FlagState: Equatable {
  public var slice: Slice
  public var subViewSelection: String
  public var canBeMinimized: Bool
  public var flagMinimized: Bool
  public var sMeterValue: CGFloat
  public var forceUpdate: Bool = false
  public var quickModes: [String]
  public var frequency: Hz = 0

  public init
  (
    slice: Slice,
    subViewSelection: String = "AUD",
    canBeMinimized: Bool = false,
    flagMinimized: Bool = false,
    sMeterValue: CGFloat = 5.0,
    quickModes: [String] = ["USB", "LSB", "CW"]
  )
  {
    self.slice = slice
    self.subViewSelection = subViewSelection
    self.canBeMinimized = canBeMinimized
    self.flagMinimized = flagMinimized
    self.sMeterValue = sMeterValue
    self.quickModes = quickModes
  }
}

public enum FlagAction: Equatable {
  
  // UI controls
  case toggle(WritableKeyPath<FlagState, Bool>, Slice.SliceProperty?)
  case subViewSelectionChanged(String)
  case splitClicked
  case rxAntennaSelection(String)
  case txAntennaSelection(String)
  case nbLevelChanged(Double)
  case nrLevelChanged(Double)
  case anfLevelChanged(Double)
  case wnbLevelChanged(Double)
  case frequencyChanged(Hz)
  case frequencySubmitted
  case audioGainChanged(Double)
  case audioPanChanged(Double)
  case agcModeChanged(String)
  case agcThresholdChanged(Double)
  case daxChannelChanged(Int)
  case modeChanged(String)
  case filterChanged(Int)
  case ritOffsetChanged(Int)
  case xitOffsetChanged(Int)
  case tuningStepChanged(Int)
  case xClicked
}

public struct FlagEnvironment {
  
  public init() {}
}

// ----------------------------------------------------------------------------
// MARK: - Reducer

public let flagReducer = Reducer<FlagState, FlagAction, FlagEnvironment>
{ state, action, environment in
  
  switch action {
    
  case .toggle(let keyPath, let property):
    // handles all buttons with a Bool state
    switch keyPath {
    case \.flagMinimized:         if state.canBeMinimized { state[keyPath: keyPath].toggle() }
    case \.slice.qskEnabled:      state[keyPath: keyPath].toggle()
    default:                      Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: property!, value: !state[keyPath: keyPath])
    }
    return .none
    
  case .subViewSelectionChanged(let selection):
    if state.subViewSelection == "none" {
      state.subViewSelection = selection
    } else if state.subViewSelection == selection {
      state.subViewSelection = "none"
    } else {
      state.subViewSelection = selection
    }
    return .none
    
//  case .sliceLetterClicked:
//    // minimized allowed if not in RightSide View
//    if state.canBeMinimized { state.flagMinimized.toggle() }
//    return .none
    
  case .rxAntennaSelection(let antenna):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .rxAnt, value: antenna)
    return .none

  case .txAntennaSelection(let antenna):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .txAnt, value: antenna)
    return .none
    
  case .splitClicked:
    // FIXME: ???
    return .none

  case .frequencyChanged(let frequency):
    state.frequency = frequency
    return .none
    
  case .frequencySubmitted:
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .frequency, value: state.frequency.hzToMhz)
    return .none
    
  case .audioGainChanged(let gain):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .audioLevel, value: gain)
    return .none
    
  case .audioPanChanged( let pan):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .audioPan, value: pan)
    return .none
    
  case .agcThresholdChanged(let threshold):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .agcThreshold, value: threshold)
    return .none
    
  case .agcModeChanged(let mode):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .agcMode, value: mode)
    return .none
    
  case .nbLevelChanged(let level):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .nbLevel, value: level)
    return .none

  case .nrLevelChanged(let level):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .nrLevel, value: level)
    return .none

  case .anfLevelChanged(let level):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .anfLevel, value: level)
    return .none

  case .wnbLevelChanged(let level):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .wnbLevel, value: level)
    return .none

  case .daxChannelChanged(let channel):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .daxChannel, value: channel)
    return .none

  case .modeChanged(let mode):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .mode, value: mode)
    return .none

  case .filterChanged(let width):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .filterHigh, value: width)
    return .none
  
  case .ritOffsetChanged(let offset):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .ritOffset, value: offset)
    return .none
  
  case .xitOffsetChanged(let offset):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .xitOffset, value: offset)
    return .none

  case .tuningStepChanged(let step):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .step, value: step)
    return .none
    
  case .xClicked:
    // close allowed if not in RightSide View
    if state.canBeMinimized { Model.shared.radio!.send("slice remove \(state.slice.id)") }
    return .none
  }
}
//  .debug("-----> RIGHTSIDEVIEW")
