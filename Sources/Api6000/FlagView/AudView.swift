//
//  AudView.swift
//  
//
//  Created by Douglas Adams on 4/27/22.
//

import SwiftUI
import ComposableArchitecture
import CocoaAsyncSocket

import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct AudView: View {
  let store: Store<FlagState, FlagAction>
  @ObservedObject var slice: Slice
  
  @State private var choices = [
    "off",
    "slow",
    "med",
    "fast"
  ]
  
  var body: some View {

    WithViewStore(self.store) { viewStore in
      VStack(spacing: 1) {
        HStack {
          VStack(spacing: 12) {
            Image(systemName: slice.audioMute ? "speaker.slash": "speaker").font(.system(size: 20))
              .onTapGesture { viewStore.send(.toggle(\.slice.audioMute, .audioMute) )}
            Text("L")
          }.font(.system(size: 12))

          VStack(spacing: -5)  {
            Slider(value: viewStore.binding(get: \.slice.audioGain, send: { .audioGainChanged($0) } ), in: 0...100, step: 1.0)
            Slider(value: viewStore.binding(get: \.slice.audioPan, send: { .audioPanChanged($0) } ), in: 0...100, step: 1.0)

          }
          VStack(spacing: 12) {
            Text(String(format: "%2.0f", slice.audioGain)).frame(width: 30)
            Text("R")
          }.font(.system(size: 12))
        }

        HStack {
          Picker("", selection: viewStore.binding(get: \.slice.agcMode, send: { .agcModeChanged($0) } )) {
            ForEach(choices, id: \.self) {
              Text($0)
            }
          }.frame(width: 100)
          Slider(value: viewStore.binding(get: \.slice.agcThreshold, send: { .agcThresholdChanged($0) } ), in: 0...100, step: 1.0)
          Text(String(format: "%2.0f", slice.agcThreshold)).frame(width: 30)
        }.font(.system(size: 12))
      }
      .frame(width: 275, height: 110)
      .padding(.horizontal)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct AudView_Previews: PreviewProvider {
  static var previews: some View {
    AudView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      ), slice: Slice(0)
    )
  }
}
