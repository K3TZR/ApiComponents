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
  @ObservedObject var model: Model

  func filterLabel(_ slice: Slice, _ index: Int) -> String {
    var formattedWidth = ""
    
    let width = slice.filters[index].high - slice.filters[index].low
    switch width {
      
    case 1_000...:  formattedWidth = String(format: "%2.1fk", Float(width)/1000.0)
    case 0..<1_000: formattedWidth = String(format: "%3d", width)
    default:        formattedWidth = "0"
    }
    return formattedWidth
  }

  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      let buttonWidth: CGFloat = 50
      
      VStack {
        HStack{
          Picker("", selection: viewStore.binding(get: \.model.activeSlice!.mode, send: { .modeChanged($0) } )) {
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
            Button(action: { viewStore.send( .filterChanged(0)) }) {Text( filterLabel(model.activeSlice!, 0) )}
            Button(action: { viewStore.send( .filterChanged(1)) }) {Text( filterLabel(model.activeSlice!, 1) )}
            Button(action: { viewStore.send( .filterChanged(2)) }) {Text( filterLabel(model.activeSlice!, 2) )}
            Button(action: { viewStore.send( .filterChanged(3)) }) {Text( filterLabel(model.activeSlice!, 3) )}
            Button(action: { viewStore.send( .filterChanged(4)) }) {Text( filterLabel(model.activeSlice!, 4) )}
          }
          .frame(width: buttonWidth)
        }
        HStack {
          Group {
            Button(action: { viewStore.send( .filterChanged(5)) }) {Text( filterLabel(model.activeSlice!, 5) )}
            Button(action: { viewStore.send( .filterChanged(6)) }) {Text( filterLabel(model.activeSlice!, 6) )}
            Button(action: { viewStore.send( .filterChanged(7)) }) {Text( filterLabel(model.activeSlice!, 7) )}
            Button(action: { viewStore.send( .filterChanged(8)) }) {Text( filterLabel(model.activeSlice!, 8) )}
            Button(action: { viewStore.send( .filterChanged(9)) }) {Text( filterLabel(model.activeSlice!, 9) )}
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
          initialState: FlagState( model: Model.shared ),
          reducer: flagReducer,
          environment: FlagEnvironment()
        ), model: Model.shared
      )
    }
}
