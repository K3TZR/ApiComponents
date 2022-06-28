//
//  Model.swift
//  Api6000Components/Api6000
//
//  Created by Douglas Adams on 2/6/22.
//

import Foundation
import IdentifiedCollections

import Shared

public class Model: Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Static Equality
  
  public static func == (lhs: Model, rhs: Model) -> Bool {
    // object equality since it is a "sharedInstance"
    lhs === rhs
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static properties
  
  private static let q = DispatchQueue(label: "ModelQ", attributes: [.concurrent])
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var radio: Radio?
  public var activeSlice: Slice?
  
  // Dynamic Models
  public var amplifiers: IdentifiedArrayOf<Amplifier> {
    get { Model.q.sync { _amplifiers } }
    set { Model.q.sync(flags: .barrier) { _amplifiers = newValue }}}
  public var bandSettings: IdentifiedArrayOf<BandSetting> {
    get { Model.q.sync { _bandSettings } }
    set { Model.q.sync(flags: .barrier) { _bandSettings = newValue }}}
  public var daxIqStreams: IdentifiedArrayOf<DaxIqStream> {
    get { Model.q.sync { _daxIqStreams } }
    set { Model.q.sync(flags: .barrier) { _daxIqStreams = newValue }}}
  public var daxMicAudioStreams: IdentifiedArrayOf<DaxMicAudioStream> {
    get { Model.q.sync { _daxMicAudioStreams } }
    set { Model.q.sync(flags: .barrier) { _daxMicAudioStreams = newValue }}}
  public var daxRxAudioStreams: IdentifiedArrayOf<DaxRxAudioStream> {
    get { Model.q.sync { _daxRxAudioStreams } }
    set { Model.q.sync(flags: .barrier) { _daxRxAudioStreams = newValue }}}
  public var daxTxAudioStreams: IdentifiedArrayOf<DaxTxAudioStream> {
    get { Model.q.sync { _daxTxAudioStreams } }
    set { Model.q.sync(flags: .barrier) { _daxTxAudioStreams = newValue }}}
  public var equalizers: IdentifiedArrayOf<Equalizer> {
    get { Model.q.sync { _equalizers } }
    set { Model.q.sync(flags: .barrier) { _equalizers = newValue }}}
  public var memories: IdentifiedArrayOf<Memory> {
    get { Model.q.sync { _memories } }
    set { Model.q.sync(flags: .barrier) { _memories = newValue }}}
  public var meters: IdentifiedArrayOf<Meter> {
    get { Model.q.sync { _meters } }
    set { Model.q.sync(flags: .barrier) { _meters = newValue }}}
  public var panadapters: IdentifiedArrayOf<Panadapter> {
    get { Model.q.sync { _panadapters } }
    set { Model.q.sync(flags: .barrier) { _panadapters = newValue }}}
  public var profiles: IdentifiedArrayOf<Profile> {
    get { Model.q.sync { _profiles } }
    set { Model.q.sync(flags: .barrier) { _profiles = newValue }}}
  public var remoteRxAudioStreams: IdentifiedArrayOf<RemoteRxAudioStream> {
    get { Model.q.sync { _remoteRxAudioStreams } }
    set { Model.q.sync(flags: .barrier) { _remoteRxAudioStreams = newValue }}}
  public var remoteTxAudioStreams: IdentifiedArrayOf<RemoteTxAudioStream> {
    get { Model.q.sync { _remoteTxAudioStreams } }
    set { Model.q.sync(flags: .barrier) { _remoteTxAudioStreams = newValue }}}
  public var slices: IdentifiedArrayOf<Slice> {
    get { Model.q.sync { _slices } }
    set { Model.q.sync(flags: .barrier) { _slices = newValue }}}
  public var tnfs: IdentifiedArrayOf<Tnf> {
    get { Model.q.sync { _tnfs } }
    set { Model.q.sync(flags: .barrier) { _tnfs = newValue }}}
  public var usbCables: IdentifiedArrayOf<UsbCable> {
    get { Model.q.sync { _usbCables } }
    set { Model.q.sync(flags: .barrier) { _usbCables = newValue }}}
  public var waterfalls: IdentifiedArrayOf<Waterfall> {
    get { Model.q.sync { _waterfalls } }
    set { Model.q.sync(flags: .barrier) { _waterfalls = newValue }}}
  public var xvtrs: IdentifiedArrayOf<Xvtr> {
    get { Model.q.sync { _xvtrs } }
    set { Model.q.sync(flags: .barrier) { _xvtrs = newValue }}}
  
  // Static Models
  public var atu: Atu {
    get { Model.q.sync { _atu } }
    set { Model.q.sync(flags: .barrier) { _atu = newValue }}}
  public var cwx: Cwx {
    get { Model.q.sync { _cwx } }
    set { Model.q.sync(flags: .barrier) { _cwx = newValue }}}
  public var gps: Gps {
    get { Model.q.sync { _gps } }
    set { Model.q.sync(flags: .barrier) { _gps = newValue }}}
  public var interlock: Interlock {
    get { Model.q.sync { _interlock } }
    set { Model.q.sync(flags: .barrier) { _interlock = newValue }}}
  public var transmit: Transmit {
    get { Model.q.sync { _transmit } }
    set { Model.q.sync(flags: .barrier) { _transmit = newValue }}}
  public var wan: Wan {
    get { Model.q.sync { _wan } }
    set { Model.q.sync(flags: .barrier) { _wan = newValue }}}
  public var waveform: Waveform {
    get { Model.q.sync { _waveform } }
    set { Model.q.sync(flags: .barrier) { _waveform = newValue }}}

  // Packet collection
  public var packets: IdentifiedArrayOf<Packet> {
    get { Model.q.sync { _packets } }
    set { Model.q.sync(flags: .barrier) { _packets = newValue }}}

  // ReplyHandler collection
  public var replyHandlers : [SequenceNumber: ReplyTuple] {
    get { Model.q.sync { _replyHandlers } }
    set { Model.q.sync(flags: .barrier) { _replyHandlers = newValue }}}


  // Backing stores (Dynamic models)
  private var _amplifiers = IdentifiedArrayOf<Amplifier>()
  private var _bandSettings = IdentifiedArrayOf<BandSetting>()
  private var _daxIqStreams = IdentifiedArrayOf<DaxIqStream>()
  private var _daxMicAudioStreams = IdentifiedArrayOf<DaxMicAudioStream>()
  private var _daxRxAudioStreams = IdentifiedArrayOf<DaxRxAudioStream>()
  private var _daxTxAudioStreams = IdentifiedArrayOf<DaxTxAudioStream>()
  private var _equalizers = IdentifiedArrayOf<Equalizer>()
  private var _memories = IdentifiedArrayOf<Memory>()
  private var _meters = IdentifiedArrayOf<Meter>()
  private var _panadapters = IdentifiedArrayOf<Panadapter>()
  private var _profiles = IdentifiedArrayOf<Profile>()
  private var _remoteRxAudioStreams = IdentifiedArrayOf<RemoteRxAudioStream>()
  private var _remoteTxAudioStreams = IdentifiedArrayOf<RemoteTxAudioStream>()
  private var _slices = IdentifiedArrayOf<Slice>()
  private var _tnfs = IdentifiedArrayOf<Tnf>()
  private var _usbCables = IdentifiedArrayOf<UsbCable>()
  private var _waterfalls = IdentifiedArrayOf<Waterfall>()
  private var _xvtrs = IdentifiedArrayOf<Xvtr>()

  // Backing stores (Static models)
  private var _atu = Atu()
  private var _cwx = Cwx()
  private var _gps = Gps()
  private var _interlock = Interlock()
  //  public internal(set) var netCwStream = NetCwStream()
  private var _transmit = Transmit()
  private var _wan = Wan()
  private var _waveform = Waveform()
  //  public internal(set) var wanServer = WanServer()

  // Backing stores (other)
  private var _packets = IdentifiedArrayOf<Packet>()
  private var _replyHandlers = [SequenceNumber: ReplyTuple]()

  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Model()
  private init() {}

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func removePackets(ofType source: PacketSource) {
    for packet in packets where packet.source == source {
      packets.remove(id: packet.id)
    }
  }
  
  public func removeSlice(id: SliceId) {
    slices.remove(id: id)
  }
}
