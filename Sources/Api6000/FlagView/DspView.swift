//
//  SwiftUIView.swift
//  
//
//  Created by Douglas Adams on 4/27/22.
//

import SwiftUI
import ComposableArchitecture

// ----------------------------------------------------------------------------
// MARK: - View

struct DspView: View {
  let store: Store<FlagState, FlagAction>
  @ObservedObject var slice: Slice
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      
      HStack(spacing: 20) {
        VStack(spacing: 5) {
          Toggle("WNB", isOn: viewStore.binding(get: \.slice.wnbEnabled, send: .wnbToggle ))
          Toggle("NB", isOn: viewStore.binding(get: \.slice.nbEnabled, send: .nbToggle ))
          Toggle("NR", isOn: viewStore.binding(get: \.slice.nrEnabled, send: .nrToggle ))
          Toggle("ANF", isOn: viewStore.binding(get: \.slice.anfEnabled, send: .anfToggle ))
        }.toggleStyle(.button)
        
        VStack(spacing: -5) {
          Slider(value: viewStore.binding(get: \.slice.wnbLevel, send: { .wnbLevelChanged($0) }), in: 0...100, step: 1.0)
          Slider(value: viewStore.binding(get: \.slice.nbLevel, send: { .nbLevelChanged($0) }), in: 0...100, step: 1.0)
          Slider(value: viewStore.binding(get: \.slice.nrLevel, send: { .nrLevelChanged($0) }), in: 0...100, step: 1.0)
          Slider(value: viewStore.binding(get: \.slice.anfLevel, send: { .anfLevelChanged($0) }), in: 0...100, step: 1.0)
        }
        
        VStack(spacing: 12) {
          Text(String(format: "%2.0f", viewStore.slice.wnbLevel)).frame(width: 30)
          Text(String(format: "%2.0f", viewStore.slice.nbLevel)).frame(width: 30)
          Text(String(format: "%2.0f", viewStore.slice.nrLevel)).frame(width: 30)
          Text(String(format: "%2.0f", viewStore.slice.anfLevel)).frame(width: 30)
        }
      }
    }
    .frame(width: 275, height: 110)
    .padding(.horizontal)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct DspView_Previews: PreviewProvider {
  static var previews: some View {
    DspView(
      store: Store(
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      ), slice: Slice(0)
    )
  }
}
