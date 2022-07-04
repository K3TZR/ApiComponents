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
//  @ObservedObject var slice: Slice
  
  public var body: some View {
    
//    let _ = Self._printChanges()
    
    Text("Flag goes here")
//    VStack(spacing: 2) {
//      HStack(spacing: 3) {
//        Text("SPLIT").font(.title2)
//        Text("TX").font(.title2)
//        Text(slice.sliceLetter ?? "--").font(.title2)
//      }
//      TextField("Frequency", value: $slice.frequency, formatter: FrequencyFormatter())
      
//        .font(.title2)
//        .multilineTextAlignment(.trailing)
//    }
  }
}

//struct FlagSmallView: View {
//  @ObservedObject var slice: Slice
////  let store: Store<FlagState, FlagAction>
////
////  public init(store: Store<FlagState, FlagAction>) {
////    self.store = store
////  }
//
//  var body: some View {
////    WithViewStore(self.store) { viewStore in
//      VStack(spacing: 2) {
//        HStack(spacing: 3) {
//          Text("SPLIT").font(.title2)
//          Text("TX").font(.title2)
//          Text(slice.sliceLetter ?? "--").font(.title2)
////            .onTapGesture { viewStore.send(.toggle(\.flagMinimized, nil)) }
//        }
////        TextField("Frequency", value: viewStore.binding(get: \.model.activeSlice!.frequency.intHzToDoubleMhz, send: { .frequencyChanged($0) } ), formatter: FrequencyFormatter())
//        TextField("Frequency", value: $slice.frequency, formatter: FrequencyFormatter())
//
////          .onSubmit( { viewStore.send(.frequencySubmitted) } )
//          .font(.title2)
//          .multilineTextAlignment(.trailing)
//      }
////    }
//    .frame(width: 100)
//  }
//}

//struct FlagLargeView: View {
//  @ObservedObject var viewStore: ViewStore<FlagState, FlagAction>
//  @ObservedObject var activeSlice: Slice
//
//  var body: some View {
//
//    let _ = Self._printChanges()
//
//    VStack(spacing: 2) {
//      FlagTopRowView(viewStore: viewStore, activeSlice: activeSlice)
//
//      HStack(spacing: 3) {
//        Image(systemName: activeSlice.locked ? "lock" : "lock.open").frame(width: 25, height: 25)
//          .onTapGesture { viewStore.send(.toggleLock) }
//
//        Group {
//          Toggle("NB", isOn: viewStore.binding(get: {_ in activeSlice.nbEnabled }, send: .toggleNb ))
//          Toggle("NR", isOn: viewStore.binding(get: {_ in activeSlice.nrEnabled }, send: .toggleNr ))
//          Toggle("ANF", isOn: viewStore.binding(get: {_ in activeSlice.anfEnabled }, send: .toggleAnf ))
//          Toggle("QSK", isOn: viewStore.binding(get: {_ in activeSlice.qskEnabled }, send: .toggleQsk ))
//            .disabled( activeSlice.mode != "CW")
//        }
//        .font(.system(size: 10))
//        .toggleStyle(.button)
//      }
//
//      TextField("Frequency", value: viewStore.binding(get: {_ in activeSlice.frequency.intHzToDoubleMhz }, send: { .frequencyChanged($0) } ), formatter: FrequencyFormatter())
//        .onSubmit( { viewStore.send(.frequencySubmitted) } )
//        .font(.title2)
//        .multilineTextAlignment(.trailing)
//      //        LevelIndicatorView(level: viewStore.sMeterValue, type: .sMeter)
//      //        FlagButtonsView(viewStore: viewStore)
//      Spacer()
//      Divider().background(.blue)
//    }
//    .frame(width: 275)
//    .padding(.horizontal)
//  }
//}

//struct FlagTopRowView: View {
//  let viewStore: ViewStore<FlagState, FlagAction>
//  @ObservedObject var activeSlice: Slice
//  
//  func filterLabel(_ slice: Slice) -> String {
//    var formattedWidth = ""
//    
//    let width = slice.filterHigh - slice.filterLow
//    switch width {
//      
//    case 1_000...:  formattedWidth = String(format: "%2.1fk", Float(width)/1000.0)
//    case 0..<1_000: formattedWidth = String(format: "%3d", width)
//    default:        formattedWidth = "0"
//    }
//    return formattedWidth
//  }
//  
//  var body: some View {
//    HStack(spacing: 3) {
//      Image(systemName: "x.circle").frame(width: 25, height: 25)
//        .onTapGesture { viewStore.send(.xClicked) }
//      
//      Picker("", selection: viewStore.binding(get: { _ in activeSlice.rxAnt } , send: { .rxAntennaSelection($0) })) {
//        ForEach(activeSlice.rxAntList, id: \.self) {
//          Text($0).font(.system(size: 10))
//        }
//      }
//      .labelsHidden()
//      .pickerStyle(.menu)
//      
//      Picker("", selection: viewStore.binding(get: { _ in activeSlice.txAnt }, send: { .txAntennaSelection($0) })) {
//        ForEach(activeSlice.txAntList, id: \.self) {
//          Text($0).font(.system(size: 10))
//        }
//      }
//      .labelsHidden()
//      .pickerStyle(.menu)
//      
//      Text( filterLabel(activeSlice) )
//      Text("SPLIT").font(.title2)
//        .onTapGesture { viewStore.send(.splitClicked) }
//        .foregroundColor(activeSlice.splitId == nil ? .gray : .yellow)
//      
//      Text("TX").font(.title2).foregroundColor(activeSlice.txEnabled ? .red : .gray)
//      Text(activeSlice.sliceLetter ?? "--").font(.title2)
//        .onTapGesture { viewStore.send(.toggle(\.flagMinimized, nil) ) }
//    }
//    .padding(.top, 10)
//  }
//}

//struct FlagButtonsView: View {
//  @ObservedObject var viewStore: ViewStore<FlagState, FlagAction>
//  
//  enum Buttons: String, CaseIterable {
//    case aud = "AUD"
//    case dsp = "DSP"
//    case mode = "MODE"
//    case xrit = "XRIT"
//    case dax = "DAX"
//  }
//  
//  var body: some View {
//    VStack(alignment: .center) {
//      
//      Picker("", selection: viewStore.binding(get: \.subViewSelection, send: { .subViewSelectionChanged($0) } )) {
//        ForEach(["AUD", "DSP", "MODE", "XRIT", "DAX"], id: \.self) {
//          Text($0)
//        }
//      }
//      .labelsHidden()
//      .pickerStyle(.segmented)
//      
//      //        switch viewStore.subViewSelection {
//      //        case Buttons.aud.rawValue:    AudView(viewStore: viewStore)
//      //        case Buttons.dsp.rawValue:    DspView(store: store, model: model)
//      //        case Buttons.mode.rawValue:   ModeView(store: store, model: model)
//      //        case Buttons.xrit.rawValue:   XritView(store: store, model: model)
//      //        case Buttons.dax.rawValue:    DaxView(store: store, model: model)
//      //        default:                      EmptyView()
//      //        }
//    }
//    .frame(width: 275)
//    .padding(.horizontal)
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

//  struct FlagButtonsView_Previews: PreviewProvider {
//    static var previews: some View {
//      FlagButtonsView(
//        store: Store(
//          initialState: FlagState( model: Model.shared ),
//          reducer: flagReducer,
//          environment: FlagEnvironment()
//        ), model: Model.shared
//      )
//      .previewDisplayName("----- Buttons -----")
//    }
//  }

//struct FlagView_Previews: PreviewProvider {
//  static var previews: some View {
//    FlagView( slice: Slice(0) )
//    .previewDisplayName("----- Flag -----")
//
    //      FlagView(
    //        store: Store(
    //          initialState: FlagState( model: Model.shared  ),
    //          reducer: flagReducer,
    //          environment: FlagEnvironment()
    //        )
    //      )
    //      .previewDisplayName("----- Flag w/AUD -----")
    //
    //      FlagView(
    //        store: Store(
    //          initialState: FlagState( model: Model.shared  ),
    //          reducer: flagReducer,
    //          environment: FlagEnvironment()
    //        )
    //      )
    //      .previewDisplayName("----- Flag w/DSP -----")
    //
    //      FlagView(
    //        store: Store(
    //          initialState: FlagState( model: Model.shared  ),
    //          reducer: flagReducer,
    //          environment: FlagEnvironment()
    //        )
    //      )
    //      .previewDisplayName("----- Flag w/MODE -----")
    //
    //      FlagView(
    //        store: Store(
    //          initialState: FlagState( model: Model.shared  ),
    //          reducer: flagReducer,
    //          environment: FlagEnvironment()
    //        )
    //      )
    //      .previewDisplayName("----- Flag w/XRIT -----")
    //
    //      FlagView(
    //        store: Store(
    //          initialState: FlagState( model: Model.shared  ),
    //          reducer: flagReducer,
    //          environment: FlagEnvironment()
    //        )
    //      )
    //      .previewDisplayName("----- Flag w/DAX -----")
    //
    //      FlagView(
    //        store: Store(
    //          initialState: FlagState( model: Model.shared  ),
    //          reducer: flagReducer,
    //          environment: FlagEnvironment()
    //        )
    //      )
    //      .previewDisplayName("----- Flag Minized -----")
    //    }
//  }
//}
