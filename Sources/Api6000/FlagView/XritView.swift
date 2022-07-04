//
//  XritView.swift
//  
//
//  Created by Douglas Adams on 4/27/22.
//

import SwiftUI
import ComposableArchitecture

// ----------------------------------------------------------------------------
// MARK: - View

struct XritView: View {
  let store: Store<FlagState, FlagAction>
  @ObservedObject var model: Model
  
  let buttonWidth: CGFloat = 25
  //    let smallButtonWidth: CGFloat = 10
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      VStack {
        HStack {
          VStack {
            Toggle("RIT", isOn: viewStore.binding(get: \.model.activeSlice!.ritEnabled, send: .toggle(\.model.activeSlice!.ritEnabled, .ritEnabled) ))
              .toggleStyle(.button)

            HStack(spacing: -10) {
              TextField("offset", value: viewStore.binding(get: \.model.activeSlice!.ritOffset, send: { .ritOffsetChanged($0) } ), format: .number)
              //              .modifier(ClearButton(boundText: $ritOffsetString, trailing: false))
              
              Stepper("", value: viewStore.binding(get: \.model.activeSlice!.ritOffset, send: { .ritOffsetChanged($0) } ), in: 0...10_000)
            }.multilineTextAlignment(.trailing)
          }
          
          VStack {
            Toggle("XIT", isOn: viewStore.binding(get: \.model.activeSlice!.xitEnabled, send: .toggle(\.model.activeSlice!.xitEnabled, .xitEnabled) ))
              .toggleStyle(.button)

            HStack(spacing: -10)  {
              TextField("offset", value: viewStore.binding(get: \.model.activeSlice!.xitOffset, send: { .xitOffsetChanged($0) } ), format: .number)
              //              .modifier(ClearButton(boundText: $xitOffsetString, trailing: false))
              
              Stepper("", value: viewStore.binding(get: \.model.activeSlice!.xitOffset, send: { .xitOffsetChanged($0) } ), in: 0...10_000)
            }.multilineTextAlignment(.trailing)
          }
        }
        
        HStack(spacing: 20) {
          Text("Tuning step")
          HStack(spacing: -10) {
            TextField("step", value: viewStore.binding(get: \.model.activeSlice!.step, send: { .tuningStepChanged($0) } ), format: .number)
            //            .modifier(ClearButton(boundText: $tuningStepString, trailing: false))
            Stepper("", value: viewStore.binding(get: \.model.activeSlice!.step, send: { .tuningStepChanged($0) } ), in: 0...100_000)
          }
        }.multilineTextAlignment(.trailing)
      }
    }
    .frame(width: 275, height: 110)
    .padding(.horizontal)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct XritView_Previews: PreviewProvider {
  static var previews: some View {
    XritView(
      store: Store(
        initialState: FlagState(  model: Model.shared  ),
        reducer: flagReducer,
        environment: FlagEnvironment()
      ), model: Model.shared
    )
  }
}
