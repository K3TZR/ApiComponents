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
  @ObservedObject var model: Model
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      
      HStack(spacing: 20) {
        VStack(spacing: 5) {
          Toggle("WNB", isOn: viewStore.binding(get: \.model.activeSlice!.wnbEnabled, send: .toggle(\.model.activeSlice!.wnbEnabled, .wnbEnabled) ))
          Toggle("NB", isOn: viewStore.binding(get: \.model.activeSlice!.nbEnabled, send: .toggle(\.model.activeSlice!.nbEnabled, .nbEnabled) ))
          Toggle("NR", isOn: viewStore.binding(get: \.model.activeSlice!.nrEnabled, send: .toggle(\.model.activeSlice!.nrEnabled, .nrEnabled) ))
          Toggle("ANF", isOn: viewStore.binding(get: \.model.activeSlice!.anfEnabled, send: .toggle(\.model.activeSlice!.anfEnabled, .anfEnabled) ))
        }.toggleStyle(.button)
        
        VStack(spacing: -5) {
          Slider(value: viewStore.binding(get: \.model.activeSlice!.wnbLevel, send: { .wnbLevelChanged($0) }), in: 0...100, step: 1.0)
          Slider(value: viewStore.binding(get: \.model.activeSlice!.nbLevel, send: { .nbLevelChanged($0) }), in: 0...100, step: 1.0)
          Slider(value: viewStore.binding(get: \.model.activeSlice!.nrLevel, send: { .nrLevelChanged($0) }), in: 0...100, step: 1.0)
          Slider(value: viewStore.binding(get: \.model.activeSlice!.anfLevel, send: { .anfLevelChanged($0) }), in: 0...100, step: 1.0)
        }
        
        VStack(spacing: 12) {
          Text(String(format: "%2.0f", model.activeSlice!.wnbLevel)).frame(width: 30)
          Text(String(format: "%2.0f", model.activeSlice!.nbLevel)).frame(width: 30)
          Text(String(format: "%2.0f", model.activeSlice!.nrLevel)).frame(width: 30)
          Text(String(format: "%2.0f", model.activeSlice!.anfLevel)).frame(width: 30)
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
        initialState: FlagState( model: Model.shared  ),
        reducer: flagReducer,
        environment: FlagEnvironment()
      ), model: Model.shared
    )
  }
}
