//
//  ModeView.swift
//  
//
//  Created by Douglas Adams on 4/27/22.
//

import SwiftUI
import ComposableArchitecture

// ----------------------------------------------------------------------------
// MARK: - View

struct ModeView: View {
  let store: Store<FlagState, FlagAction>
  @ObservedObject var slice: Slice

  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      let buttonWidth: CGFloat = 50
      
      VStack {
        HStack{
          Picker("", selection: viewStore.binding(get: \.slice.mode, send: { .modeChanged($0) } )) {
            ForEach(Slice.Mode.allCases, id: \.self) {
              Text($0.rawValue)
                .tag($0.rawValue)
            }
          }
          .labelsHidden()
          Button(action: { viewStore.send( .modeChanged(viewStore.quickModes[0])) }) {Text(viewStore.quickModes[0])}
          Button(action: { viewStore.send( .modeChanged(viewStore.quickModes[1])) }) {Text(viewStore.quickModes[1])}
          Button(action: { viewStore.send( .modeChanged(viewStore.quickModes[2])) }) {Text(viewStore.quickModes[2])}
        }
        HStack {
          Group {
            Button(action: { viewStore.send( .filterChanged( slice.filters[0].value) ) }) {Text(slice.filters[0].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[1].value) ) }) {Text(slice.filters[1].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[2].value) ) }) {Text(slice.filters[2].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[3].value) ) }) {Text(slice.filters[3].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[4].value) ) }) {Text(slice.filters[4].label)}
          }
          .frame(width: buttonWidth)
        }
        HStack {
          Group {
            Button(action: { viewStore.send( .filterChanged( slice.filters[5].value) ) }) {Text(slice.filters[5].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[6].value) ) }) {Text(slice.filters[6].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[7].value) ) }) {Text(slice.filters[7].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[8].value) ) }) {Text(slice.filters[8].label)}
            Button(action: { viewStore.send( .filterChanged( slice.filters[9].value) ) }) {Text(slice.filters[9].label)}
          }
          .frame(width: buttonWidth)
        }
      }
    }
    .frame(width: 275, height: 110)
    .padding(.horizontal)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct ModeView_Previews: PreviewProvider {
    static var previews: some View {
      ModeView(
        store: Store(
          initialState: FlagState(slice: Slice(0)),
          reducer: flagReducer,
          environment: FlagEnvironment()
        ), slice: Slice(0)
      )
    }
}
