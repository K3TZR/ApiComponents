//
//  Model.swift
//  Api6000Components/Api6000
//
//  Created by Douglas Adams on 2/6/22.
//

import Foundation
import IdentifiedCollections

import Shared

@MainActor
public class Model: ObservableObject, Equatable {
  
  public nonisolated static func == (lhs: Model, rhs: Model) -> Bool {
    // object equality since it is a "sharedInstance"
    lhs === rhs
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @Published public var amplifiers = IdentifiedArrayOf<Amplifier>()
  @Published public var bandSettings = IdentifiedArrayOf<BandSetting>()
  @Published public var daxIqStreams = IdentifiedArrayOf<DaxIqStream>()
  @Published public var daxMicAudioStreams = IdentifiedArrayOf<DaxMicAudioStream>()
  @Published public var daxRxAudioStreams = IdentifiedArrayOf<DaxRxAudioStream>()
  @Published public var daxTxAudioStreams = IdentifiedArrayOf<DaxTxAudioStream>()
  @Published public var equalizers = IdentifiedArrayOf<Equalizer>()
  @Published public var memories = IdentifiedArrayOf<Memory>()
  @Published public var meters = IdentifiedArrayOf<Meter>()
  @Published public var panadapters = IdentifiedArrayOf<Panadapter>()
  @Published public var profiles = IdentifiedArrayOf<Profile>()
  @Published public var remoteRxAudioStreams = IdentifiedArrayOf<RemoteRxAudioStream>()
  @Published public var remoteTxAudioStreams = IdentifiedArrayOf<RemoteTxAudioStream>()
  @Published public var slices = IdentifiedArrayOf<Slice>()
  @Published public var tnfs = IdentifiedArrayOf<Tnf>()
  @Published public var usbCables = IdentifiedArrayOf<UsbCable>()
  @Published public var waterfalls = IdentifiedArrayOf<Waterfall>()
  @Published public var xvtrs = IdentifiedArrayOf<Xvtr>()

  @Published public var atu = Atu()
  @Published public var gps = Gps()
  @Published public var interlock = Interlock()
  @Published public var transmit = Transmit()
  @Published public var wan = Wan()
  @Published public var waveform = Waveform()

  @Published public var packets = IdentifiedArrayOf<Packet>()

  public func setAmplifiers(_ amplifiers: IdentifiedArrayOf<Amplifier>) { self.amplifiers = amplifiers }
  public func setAtu(_ atu: Atu) { self.atu = atu }
  public func setBandSettings(_ bandSettings: IdentifiedArrayOf<BandSetting>) { self.bandSettings = bandSettings  }
  public func setDaxIqStreams(_ daxIqStreams: IdentifiedArrayOf<DaxIqStream>) { self.daxIqStreams = daxIqStreams  }
  public func setDaxMicAudioStreams(_ daxMicAudioStreams: IdentifiedArrayOf<DaxMicAudioStream>) { self.daxMicAudioStreams = daxMicAudioStreams  }
  public func setDaxRxAudioStreams(_ daxRxAudioStreams: IdentifiedArrayOf<DaxRxAudioStream>) { self.daxRxAudioStreams = daxRxAudioStreams  }
  public func setDaxTxAudioStreams(_ daxTxAudioStreams: IdentifiedArrayOf<DaxTxAudioStream>) { self.daxTxAudioStreams = daxTxAudioStreams  }
  public func setEqualizers(_ equalizers: IdentifiedArrayOf<Equalizer>) { self.equalizers = equalizers  }
  public func setGps(_ gps: Gps) { self.gps = gps  }
  public func setInterlock(_ interlock: Interlock) { self.interlock = interlock }
  public func setMemories(_ memories: IdentifiedArrayOf<Memory>) { self.memories = memories }
  public func setMeters(_ meters: IdentifiedArrayOf<Meter>) { self.meters = meters }
  public func setRemoteRxAudioStreams(_ remoteRxAudioStreams: IdentifiedArrayOf<RemoteRxAudioStream>) { self.remoteRxAudioStreams = remoteRxAudioStreams }
  public func setRemoteTxAudioStreams(_ remoteTxAudioStreams: IdentifiedArrayOf<RemoteTxAudioStream>) { self.remoteTxAudioStreams = remoteTxAudioStreams }

  
  public func setSlices(_ slices: IdentifiedArrayOf<Slice>) { self.slices = slices }
  public func setTnfs(_ tnfs: IdentifiedArrayOf<Tnf>) { self.tnfs = tnfs }
  public func setTransmit(_ transmit: Transmit) { self.transmit = transmit }
  public func setWaterfalls(_ waterfalls: IdentifiedArrayOf<Waterfall>) { self.waterfalls = waterfalls }
  public func setPanadapters(_ panadapters: IdentifiedArrayOf<Panadapter>) { self.panadapters = panadapters }
  public func setProfiles(_ profiles: IdentifiedArrayOf<Profile>) { self.profiles = profiles }
  public func setWan(_ wan: Wan) { self.wan = wan }
  public func setWaveform(_ waveform: Waveform) { self.waveform = waveform }
  public func setXvtrs(_ xvtrs: IdentifiedArrayOf<Xvtr>) { self.xvtrs = xvtrs }
  public func setUsbCables(_ usbCables: IdentifiedArrayOf<UsbCable>) { self.usbCables = usbCables }

  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Model()
  private init() {}

  public func removePackets(ofType source: PacketSource) {
    for packet in packets where packet.source == source {
      packets.remove(id: packet.id)
    }
  }

}
