//
//  FlagView.swift
//  Components/SdrViewer/SubViews/SideViews
//
//  Created by Douglas Adams on 4/3/21.
//  Copyright © 2020-2021 Douglas Adams. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import LevelIndicatorView
import Shared

// ----------------------------------------------------------------------------
// MARK: - Views

public struct FlagView: View {
  let store: Store<FlagState, FlagAction>
  
  public init(store: Store<FlagState, FlagAction>) {
    self.store = store
  }
  
  public var body: some View {
    
    WithViewStore(self.store) { viewStore in
      if viewStore.flagMinimized {
        // ----- Small size Flag -----
        FlagSmallView(store: store)
        
      } else {
        // ----- Full size Flag -----
        FlagLargeView(store: store, slice: viewStore.slice)
      }
    }
  }
}

public struct FlagSmallView: View {
  let store: Store<FlagState, FlagAction>
  
  public init(store: Store<FlagState, FlagAction>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 2) {
        HStack(spacing: 3) {
          Text("SPLIT").font(.title2)
          Text("TX").font(.title2)
          Text(viewStore.slice.sliceLetter ?? "--").font(.title2)
            .onTapGesture { viewStore.send(.toggle(\.flagMinimized, nil)) }
        }
        TextField("Frequency", value: viewStore.binding(get: \.slice.frequency, send: { .frequencyChanged($0) } ), formatter: NumberFormatter())
        .onSubmit( { viewStore.send(.frequencySubmitted) } )
        .font(.title2)
        .multilineTextAlignment(.trailing)
      }
      .frame(width: 100)
    }
  }
}

struct FlagLargeView: View {
  let store: Store<FlagState, FlagAction>
  @ObservedObject var slice: Slice
  
  func filterWidth(_ slice: Slice) -> String {
    var formattedWidth = ""
    
    let width = slice.filterHigh - slice.filterLow
    switch width {
      
    case 1_000...:  formattedWidth = String(format: "%2.1fk", Float(width)/1000.0)
    case 0..<1_000: formattedWidth = String(format: "%3d", width)
    default:        formattedWidth = "0"
    }
    return formattedWidth
  }

  var body: some View {
    WithViewStore(self.store) { viewStore in

      VStack(spacing: 2) {
        HStack(spacing: 3) {
          Image(systemName: "x.circle").frame(width: 25, height: 25)
            .onTapGesture { viewStore.send(.xClicked) }

          Picker("", selection: viewStore.binding(get: \.slice.rxAnt , send: { .rxAntennaSelection($0) })) {
            ForEach(slice.rxAntList, id: \.self) {
              Text($0).font(.system(size: 10))
            }
          }
          .labelsHidden()
          .pickerStyle(.menu)
          
          Picker("", selection: viewStore.binding(get: \.slice.txAnt , send: { .txAntennaSelection($0) })) {
            ForEach(slice.txAntList, id: \.self) {
              Text($0).font(.system(size: 10))
            }
          }
          .labelsHidden()
          .pickerStyle(.menu)
          
          Text( filterWidth(slice) )
          Text("SPLIT").font(.title2)
            .onTapGesture { viewStore.send(.splitClicked) }
            .foregroundColor(slice.splitId == nil ? .gray : .yellow)
          
          Text("TX").font(.title2).foregroundColor(slice.txEnabled ? .red : .gray)
          Text(slice.sliceLetter ?? "--").font(.title2)
            .onTapGesture { viewStore.send(.toggle(\.flagMinimized, nil) ) }
        }
        .padding(.top, 10)
        
        HStack(spacing: 3) {
          Image(systemName: viewStore.slice.locked ? "lock" : "lock.open").frame(width: 25, height: 25)
            .onTapGesture { viewStore.send(.toggle(\.slice.locked, .locked)) }

          Group {
            Toggle("NB", isOn: viewStore.binding(get: \.slice.nbEnabled, send: .toggle(\.slice.nbEnabled, .nbEnabled) ))
            Toggle("NR", isOn: viewStore.binding(get: \.slice.nrEnabled, send: .toggle(\.slice.nrEnabled, .nrEnabled) ))
            Toggle("ANF", isOn: viewStore.binding(get: \.slice.anfEnabled, send: .toggle(\.slice.anfEnabled, .anfEnabled) ))
            Toggle("QSK", isOn: viewStore.binding(get: \.slice.qskEnabled, send: .toggle(\.slice.qskEnabled, .qskEnabled) ))
              .disabled(slice.mode != "CW")
          }
          .font(.system(size: 10))
          .toggleStyle(.button)
          
          TextField("Frequency", value: viewStore.binding(get: \.slice.frequency, send: { .frequencyChanged($0) } ), formatter: NumberFormatter())
          .onSubmit( { viewStore.send(.frequencySubmitted) } )
          .font(.title2)
          .multilineTextAlignment(.trailing)
        }
        LevelIndicatorView(level: viewStore.sMeterValue, type: .sMeter)
        FlagButtonsView(store: store, slice: slice)
      }
      .frame(width: 275)
      .padding(.horizontal)
    }
  }
}

struct FlagButtonsView: View {
  let store: Store<FlagState, FlagAction>
  @ObservedObject var slice: Slice


  enum Buttons: String, CaseIterable {
    case aud = "AUD"
    case dsp = "DSP"
    case mode = "MODE"
    case xrit = "XRIT"
    case dax = "DAX"
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      
      VStack(alignment: .center) {
        
        Picker("", selection: viewStore.binding(get: \.subViewSelection, send: { .subViewSelectionChanged($0) } )) {
          ForEach(["AUD", "DSP", "MODE", "XRIT", "DAX"], id: \.self) {
            Text($0)
          }
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        
        switch viewStore.subViewSelection {
        case Buttons.aud.rawValue:    AudView(store: store, slice: slice)
        case Buttons.dsp.rawValue:    DspView(store: store, slice: slice)
        case Buttons.mode.rawValue:   ModeView(store: store, slice: slice)
        case Buttons.xrit.rawValue:   XritView(store: store, slice: slice)
        case Buttons.dax.rawValue:    DaxView(store: store, slice: slice)
        default:                      EmptyView()
        }
      }
    }
    .frame(width: 275)
    .padding(.horizontal)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

struct FlagButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    FlagButtonsView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      ), slice: Slice(0)
    )
    .previewDisplayName("----- Buttons -----")
  }
}

struct FlagView_Previews: PreviewProvider {
  static var previews: some View {
    FlagView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      )
    )
    .previewDisplayName("----- Flag -----")
    
    FlagView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      )
    )
    .previewDisplayName("----- Flag w/AUD -----")
    
    FlagView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      )
    )
    .previewDisplayName("----- Flag w/DSP -----")
    
    FlagView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      )
    )
    .previewDisplayName("----- Flag w/MODE -----")
    
    FlagView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      )
    )
    .previewDisplayName("----- Flag w/XRIT -----")
    
    FlagView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      )
    )
    .previewDisplayName("----- Flag w/DAX -----")
    
    FlagView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      )
    )
    .previewDisplayName("----- Flag Minized -----")
  }
}
