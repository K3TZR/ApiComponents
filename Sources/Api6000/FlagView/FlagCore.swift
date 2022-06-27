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
  public var flagMinimized: Bool
  public var sMeterValue: CGFloat
  public var forceUpdate: Bool = false

  public init
  (
    slice: Slice,
    subViewSelection: String = "AUD",
    flagMinimized: Bool = false,
    sMeterValue: CGFloat = 5.0
  )
  {
    self.slice = slice
    self.subViewSelection = subViewSelection
    self.flagMinimized = flagMinimized
    self.sMeterValue = sMeterValue
  }
}

public enum FlagAction: Equatable {
  
  // UI controls
  case toggle(WritableKeyPath<FlagState, Bool>)
  case subViewSelectionChanged(String)
  case sliceLetterClicked
  case splitClicked
  case rxAntennaSelection(String)
  case txAntennaSelection(String)
  case nbToggle
  case nrToggle
  case anfToggle
  case qskToggle
  case wnbToggle
  case nbLevelChanged(Double)
  case nrLevelChanged(Double)
  case anfLevelChanged(Double)
  case wnbLevelChanged(Double)
  case frequencyChanged(String)
  case muteToggle
  case audioGainChanged(Double)
  case audioPanChanged(Double)
  case agcModeChanged(String)
  case agcThresholdChanged(Double)
}

public struct FlagEnvironment {
  
  public init() {}
}

// ----------------------------------------------------------------------------
// MARK: - Reducer

public let flagReducer = Reducer<FlagState, FlagAction, FlagEnvironment>
{ state, action, environment in
  
  switch action {
    
  case .toggle(let keyPath):
    // handles all buttons with a Bool state
    state[keyPath: keyPath].toggle()
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
    
  case .sliceLetterClicked:
    // FIXME: only on Panadapter not RightSide
//    state.flagMinimized.toggle()
    return .none
    
  case .rxAntennaSelection(let antenna):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .rxAnt, value: antenna)
    return .none

  case .txAntennaSelection(let antenna):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .txAnt, value: antenna)
    return .none
    
  case .splitClicked:
    // FIXME: ???
    return .none

  case .nbToggle:
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .nbEnabled, value: !state.slice.nbEnabled )
    return .none

  case .nrToggle:
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .nrEnabled, value: !state.slice.nrEnabled)
    return .none

  case .anfToggle:
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .anfEnabled, value: !state.slice.anfEnabled)
    return .none

  case .qskToggle:
    // FIXME: no command, modify directly
    //    Slice.setProperty(radio: state.model.radio!, id: state.model.radio!.activeSlice!, property: .qskEnabled, value: !state.model.slices[id: state.model.radio!.activeSlice!]!.qskEnabled)
    return .none

  case .frequencyChanged(let frequency):
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .frequency, value: frequency)
    return .none
    
  case .muteToggle:
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .audioMute, value: !state.slice.audioMute)
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
    
  case .wnbToggle:
    Slice.setProperty(radio: Model.shared.radio!, id: state.slice.id, property: .wnbEnabled, value: !state.slice.wnbEnabled)
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
  }
}
//  .debug("-----> RIGHTSIDEVIEW")
