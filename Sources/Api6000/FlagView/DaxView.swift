//
//  DaxView.swift
//  
//
//  Created by Douglas Adams on 4/27/22.
//

import SwiftUI
import ComposableArchitecture

// ----------------------------------------------------------------------------
// MARK: - View

struct DaxView: View {
  let store: Store<FlagState, FlagAction>
  @ObservedObject var model: Model

  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      HStack {
        Picker("DAX Channel", selection: viewStore.binding(get: \.model.activeSlice!.daxChannel, send: { .daxChannelChanged($0) } )) {
          ForEach(Radio.kDaxChannels, id: \.self) {
            Text($0)
              .tag(Int($0) ?? 0)
          }
        }.frame(width: 200)
      }
    }
    .frame(width: 275, height: 110)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct DaxView_Previews: PreviewProvider {
  static var previews: some View {
    DaxView(
      store: Store(
        initialState: FlagState( model: Model.shared ),
        reducer: flagReducer,
        environment: FlagEnvironment()
      ), model: Model.shared
    )
  }
}
