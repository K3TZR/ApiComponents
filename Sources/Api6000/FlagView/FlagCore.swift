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
  public var model: Model { Model.shared }
//  public var activeSlice: Slice?
  public var subViewSelection: String
  public var canBeMinimized: Bool
  public var flagMinimized: Bool
  public var sMeterValue: CGFloat
  public var forceUpdate: Bool = false
  public var quickModes: [String]
//  public var frequency: Double = 0

  public init
  (
//    model: Model,
//    activeSlice: Slice? = nil,
    subViewSelection: String = "AUD",
    canBeMinimized: Bool = false,
    flagMinimized: Bool = false,
    sMeterValue: CGFloat = 5.0,
    quickModes: [String] = ["USB", "LSB", "CW"]
  )
  {
//    self.model = model
//    self.activeSlice = activeSlice
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
  case frequencyChanged(Double)
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
  case toggleLock
  case toggleNb
  case toggleNr
  case toggleAnf
  case toggleQsk
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
    case \.model.activeSlice!.qskEnabled:      state[keyPath: keyPath].toggle()
    default:                      Slice.setSliceProperty(radio: state.model.radio!, id: state.model.activeSlice!.id, property: property!, value: !state[keyPath: keyPath])
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
    
  case .rxAntennaSelection(let antenna):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .rxAnt, value: antenna)
    }
    return .none
    
  case .txAntennaSelection(let antenna):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .txAnt, value: antenna)
    }
    return .none
    
  case .splitClicked:
    // FIXME: ???
    return .none

  case .frequencyChanged(let frequency):
//    state.frequency = frequency
    return .none
    
  case .frequencySubmitted:
//    if let slice = state.model.activeSlice {
//      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .frequency, value: state.frequency)
//    }
    return .none
    
  case .audioGainChanged(let gain):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .audioLevel, value: gain)
    }
    return .none
    
  case .audioPanChanged( let pan):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .audioPan, value: pan)
    }
    return .none
    
  case .agcThresholdChanged(let threshold):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .agcThreshold, value: threshold)
    }
    return .none
    
  case .agcModeChanged(let mode):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .agcMode, value: mode)
    }
    return .none
    
  case .nbLevelChanged(let level):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .nbLevel, value: level)
    }
    return .none

  case .nrLevelChanged(let level):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .nrLevel, value: level)
    }
    return .none
    
  case .anfLevelChanged(let level):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .anfLevel, value: level)
    }
    return .none
    
  case .wnbLevelChanged(let level):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .wnbLevel, value: level)
    }
    return .none
    
  case .daxChannelChanged(let channel):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .daxChannel, value: channel)
    }
    return .none
    
  case .modeChanged(let mode):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .mode, value: mode)
    }
    return .none

  case .filterChanged(let index):
    if let slice = state.model.activeSlice {
      Slice.setFilter(radio: Model.shared.radio!, id: slice.id, low: slice.filters[index].low, high: slice.filters[index].high)
    }
    return .none
    
  case .ritOffsetChanged(let offset):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .ritOffset, value: offset)}
    return .none
    
  case .xitOffsetChanged(let offset):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .xitOffset, value: offset)
    }
    return .none
    
  case .tuningStepChanged(let step):
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .step, value: step)
    }
    return .none
    
  case .xClicked:
    // close allowed if not in RightSide View
    if let slice = state.model.activeSlice {
      if state.canBeMinimized { Model.shared.radio!.send("slice remove \(slice.id)") }
    }
    return .none
    
  case .toggleLock:
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .locked, value: !slice.locked)
    }
    return .none

  case .toggleNb:
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .nbEnabled, value: !slice.nbEnabled)
    }
    return .none

  case .toggleNr:
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .nrEnabled, value: !slice.nrEnabled)
    }
    return .none

  case .toggleAnf:
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .anfEnabled, value: !slice.anfEnabled)
    }
    return .none

  case .toggleQsk:
    if let slice = state.model.activeSlice {
      Slice.setSliceProperty(radio: Model.shared.radio!, id: slice.id, property: .qskEnabled, value: !slice.qskEnabled)
    }
    return .none
  }
}
//  .debug("-----> RIGHTSIDEVIEW")



extension Int {
    var intHzToDoubleMhz: Double { Double(self) / 1_000_000 }
}

extension Double {
    var doubleMhzToIntHz: Int { Int( self * 1_000_000 ) }
}
