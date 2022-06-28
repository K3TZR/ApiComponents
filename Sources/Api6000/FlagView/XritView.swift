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
  @ObservedObject var slice: Slice
  
  let buttonWidth: CGFloat = 25
  //    let smallButtonWidth: CGFloat = 10
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      VStack {
        HStack {
          VStack {
            Toggle("RIT", isOn: viewStore.binding(get: \.slice.ritEnabled, send: .toggle(\.slice.ritEnabled, .ritEnabled) ))
              .toggleStyle(.button)

            HStack(spacing: -10) {
              TextField("offset", value: viewStore.binding(get: \.slice.ritOffset, send: { .ritOffsetChanged($0) } ), format: .number)
              //              .modifier(ClearButton(boundText: $ritOffsetString, trailing: false))
              
              Stepper("", value: viewStore.binding(get: \.slice.ritOffset, send: { .ritOffsetChanged($0) } ), in: 0...10_000)
            }.multilineTextAlignment(.trailing)
          }
          
          VStack {
            Toggle("XIT", isOn: viewStore.binding(get: \.slice.xitEnabled, send: .toggle(\.slice.xitEnabled, .xitEnabled) ))
              .toggleStyle(.button)

            HStack(spacing: -10)  {
              TextField("offset", value: viewStore.binding(get: \.slice.xitOffset, send: { .xitOffsetChanged($0) } ), format: .number)
              //              .modifier(ClearButton(boundText: $xitOffsetString, trailing: false))
              
              Stepper("", value: viewStore.binding(get: \.slice.xitOffset, send: { .xitOffsetChanged($0) } ), in: 0...10_000)
            }.multilineTextAlignment(.trailing)
          }
        }
        
        HStack(spacing: 20) {
          Text("Tuning step")
          HStack(spacing: -10) {
            TextField("step", value: viewStore.binding(get: \.slice.step, send: { .tuningStepChanged($0) } ), format: .number)
            //            .modifier(ClearButton(boundText: $tuningStepString, trailing: false))
            Stepper("", value: viewStore.binding(get: \.slice.step, send: { .tuningStepChanged($0) } ), in: 0...100_000)
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
        initialState: FlagState(slice: Slice(0)),
        reducer: flagReducer,
        environment: FlagEnvironment()
      ), slice: Slice(0)
    )
  }
}
