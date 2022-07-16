//
//  Model.swift
//  Api6000Components/Api6000
//
//  Created by Douglas Adams on 2/6/22.
//

import Foundation
import Combine
import IdentifiedCollections

import Vita
import Shared

@MainActor
public class Model: Equatable, ObservableObject {
  // ----------------------------------------------------------------------------
  // MARK: - Static Equality
  
  public nonisolated static func == (lhs: Model, rhs: Model) -> Bool {
    // object equality since it is a "sharedInstance"
    lhs === rhs
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization (Singleton)
  
  public static var shared = Model()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var testerMode = false
  public var testPublisher = PassthroughSubject<SmartlinkTestResult, Never>()
  public var wanStatusPublisher = PassthroughSubject<WanStatus, Never>()
  
  @Published public var radio: Radio?
  @Published public var activeSlice: Slice?
  @Published public var activePanadapter: Panadapter?
  @Published public var activeEqualizer: Equalizer?
  
  // Dynamic Models
  public var amplifiers = IdentifiedArrayOf<Amplifier>()
  public var bandSettings = IdentifiedArrayOf<BandSetting>()
  public var daxIqStreams = IdentifiedArrayOf<DaxIqStream>()
  public var daxMicAudioStreams = IdentifiedArrayOf<DaxMicAudioStream>()
  public var daxRxAudioStreams = IdentifiedArrayOf<DaxRxAudioStream>()
  public var daxTxAudioStreams = IdentifiedArrayOf<DaxTxAudioStream>()
  public var equalizers = IdentifiedArrayOf<Equalizer>()
  public var memories = IdentifiedArrayOf<Memory>()
  public var meters = IdentifiedArrayOf<Meter>()
  public var panadapters = IdentifiedArrayOf<Panadapter>()
  public var profiles = IdentifiedArrayOf<Profile>()
  public var remoteRxAudioStreams = IdentifiedArrayOf<RemoteRxAudioStream>()
  public var remoteTxAudioStreams = IdentifiedArrayOf<RemoteTxAudioStream>()
  public var slices = IdentifiedArrayOf<Slice>()
  public var tnfs = IdentifiedArrayOf<Tnf>()
  public var usbCables = IdentifiedArrayOf<UsbCable>()
  public var waterfalls = IdentifiedArrayOf<Waterfall>()
  public var xvtrs = IdentifiedArrayOf<Xvtr>()
  
  // Static Models
  public var atu = Atu()
  public var cwx = Cwx()
  public var gps = Gps()
  public var interlock = Interlock()
  public var transmit = Transmit()
  public var wan = Wan()
  public var waveform = Waveform()
  
  // Packet collections
  public var packets = IdentifiedArrayOf<Packet>()
  public var stations = IdentifiedArrayOf<Packet>()

  // ReplyHandler collection
  public var replyHandlers = [SequenceNumber: ReplyTuple]()
//  public var replyHandlers = IdentifiedArrayOf<ReplyTuple>()

  
  public enum ObjectType: String {
    case amplifier
    case atu
    case bandSetting
    case cwx
    case daxIqStream
    case daxMicAudioStream
    case daxRxAudioStream
    case daxTxAudioStream
    case display
    case equalizer
    case gps
    case interlock
    case memory
    case meter
    case panadapter
    case profile
    case remoteRxAudioStream
    case remoteTxAudioStream
    case slice
    case stream
    case tnf
    case transmit
    case usbCable = "usb_cable"
    case wan
    case waterfall
    case waveform
    case xvtr
    
    case replyHandlers
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func addReplyHandler(_ seqNumber: UInt, replyTuple: ReplyTuple) async {
    replyHandlers[seqNumber] = replyTuple
  }

  public func removeReplyHandler(_ seqNumber: UInt) async {
    replyHandlers[seqNumber] = nil
  }
  
  public func removePackets(condition: (Packet) -> Bool) {
    for packet in packets where condition(packet) {
      let removedPacket = packets.remove(id: packet.id)
      radio?.packetPublisher.send(PacketUpdate(.deleted, packet: removedPacket!))
      log("Model: packet removed, interval = \(abs(removedPacket!.lastSeen.timeIntervalSince(Date())))", .debug, #function, #file, #line)
    }
  }

  public func streamDistributor(_ vitaPacket: Vita, _ type: ObjectType) async {
    switch type {
    case .panadapter:
      if let object = panadapters[id: vitaPacket.streamId]
      { object.vitaProcessor(vitaPacket, testerMode) }
    case .waterfall:
      if let object = waterfalls[id: vitaPacket.streamId]
      { object.vitaProcessor(vitaPacket, testerMode) }

    case .amplifier, .atu, .bandSetting, .cwx, .display, .equalizer, .gps, .interlock, .memory, .profile, .tnf, .transmit, .usbCable, .wan, .waveform, .xvtr, .replyHandlers:
      break
    case .daxIqStream:
      break
    case .daxMicAudioStream:
      break
    case .daxRxAudioStream:
      break
    case .daxTxAudioStream:
      break
    case .meter:
      await Meter.vitaProcessor(vitaPacket)
    case .remoteRxAudioStream:
      break
    case .remoteTxAudioStream:
      break
    case .slice:
      break
    case .stream:
      break
    }
  }

  public func process(_ type: ObjectType, _ statusMessage: String) async {
    
    switch type {
    case .amplifier:            await processAmplifier(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kRemoved))
    case .atu:                  await processAtu(statusMessage.keyValuesArray())
    case .bandSetting:          await processBandSetting(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kRemoved))
    case .cwx:                  await processCwx(statusMessage.keyValuesArray())
//    case .daxIqStream:          await processDaxIqStream(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
//    case .daxMicAudioStream:    await processDaxMicAudioStream(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
//    case .daxRxAudioStream:     await processDaxRxAudioStream(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
//    case .daxTxAudioStream:     await processDaxTxAudioStream(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
    case .display:              await processDisplay(statusMessage)
    case .equalizer:            await processEqualizer(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kRemoved))
    case .gps:                  await processGps(statusMessage.keyValuesArray())
    case .interlock:            await processInterlock(statusMessage.keyValuesArray())
    case .memory:               await processMemory(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kRemoved))
    case .meter:                await processMeter(statusMessage.keyValuesArray(delimiter: "#"), !statusMessage.contains(Shared.kRemoved))
    case .profile:              await processRemoteRxAudioStream(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
//    case .remoteRxAudioStream:  await processRemoteRxAudioStream(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
//    case .remoteTxAudioStream:  await processRemoteTxAudioStream(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
    case .slice:                await processSlice(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
    case .stream:               await processStream(statusMessage)
    case .tnf:                  await processTnf(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kRemoved))
    case .transmit:             await processTransmit(statusMessage.keyValuesArray())
    case .usbCable:             await processUsbCable(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kRemoved))
    case .wan:                  await processWan(statusMessage.keyValuesArray())
    case .waveform:             await processWaveform(statusMessage.keyValuesArray(delimiter: "="))
    case .xvtr:                 await processTnf(statusMessage.keyValuesArray(), !statusMessage.contains(Shared.kNotInUse))
      
    case .replyHandlers, .panadapter, .waterfall, .daxIqStream, .daxMicAudioStream, .daxRxAudioStream, .daxTxAudioStream, .remoteRxAudioStream, .remoteTxAudioStream:
      break
    }
  }
  
  private func processDisplay(_ statusMessage: String) async {
    let properties = statusMessage.keyValuesArray()
    switch properties[0].key {
    case ObjectType.panadapter.rawValue:  await processPanadapter(properties, !statusMessage.contains(Shared.kRemoved))
    case ObjectType.waterfall.rawValue:   await processWaterfall(properties, !statusMessage.contains(Shared.kRemoved))
    default: break
    }
  }
  
  private func processTransmit(_ properties: KeyValuesArray, _ inUse: Bool = true) async {
    // is it a Band Setting?
    if properties[0].key == "band" {
      // YES, drop the "band", pass it to BandSetting
      await processBandSetting(properties, inUse)
      
    } else {
      // NO, pass it to Transmit
      await transmit.parse(properties)
    }
  }

  func processInterlock(_ properties: KeyValuesArray, _ inUse: Bool = true) async {
    // is it a Band Setting?
    if properties[0].key == "band" {
      // YES, drop the "band", pass it to BandSetting
      await processBandSetting(Array(properties.dropFirst()), inUse )

    } else {
      // NO, pass it to Interlock
      await processInterlock(properties)
      interlockStateChange(interlock.state)
    }
  }

  /// Change the MOX property when an Interlock state change occurs
  ///
  /// - Parameter state:            a new Interloack state
  func interlockStateChange(_ state: String) {
    let currentMox = radio?.mox
    
    // if PTT_REQUESTED or TRANSMITTING
    if state == Interlock.States.pttRequested.rawValue || state == Interlock.States.transmitting.rawValue {
      // and mox not on, turn it on
      if currentMox == false { radio?.mox = true }
      
      // if READY or UNKEY_REQUESTED
    } else if state == Interlock.States.ready.rawValue || state == Interlock.States.unKeyRequested.rawValue {
      // and mox is on, turn it off
      if currentMox == true { radio?.mox = false  }
    }
  }

  private func processStream(_ statusMessage: String) async {
    enum Property: String {
      case daxIq                    = "dax_iq"
      case daxMic                   = "dax_mic"
      case daxRx                    = "dax_rx"
      case daxTx                    = "dax_tx"
      case remoteRx                 = "remote_audio_rx"
      case remoteTx                 = "remote_audio_tx"
    }
    let properties = statusMessage.keyValuesArray()
    
    if isForThisClient(properties, connectionHandle: radio?.connectionHandle) {
      
      // is the 1st KeyValue a StreamId?
      if let id = properties[0].key.streamId {
        // YES, is it a removal?
        if statusMessage.contains(Shared.kRemoved) {
          
          // removal, find the stream & remove it
          if daxIqStreams[id: id] != nil          { await process(.daxIqStream, statusMessage) }
          if daxMicAudioStreams[id: id] != nil    { await process(.daxMicAudioStream, statusMessage) }
          if daxRxAudioStreams[id: id] != nil     { await process(.daxRxAudioStream, statusMessage) }
          if daxTxAudioStreams[id: id] != nil     { await process(.daxTxAudioStream, statusMessage) }
          if remoteRxAudioStreams[id: id] != nil  { await process(.remoteRxAudioStream, statusMessage) }
          if remoteTxAudioStreams[id: id] != nil  { await process(.remoteTxAudioStream, statusMessage) }
          
        } else {
          // NOT a removal, check for unknown Keys
          guard let token = Property(rawValue: properties[1].value) else {
            // log it and ignore the Key
            log("Radio, unknown Stream property: \(properties[1].value)", .warning, #function, #file, #line)
            return
          }
          switch token {
            
          case .daxIq:      await process(.daxIqStream, statusMessage)
          case .daxMic:     await process(.daxMicAudioStream, statusMessage)
          case .daxRx:      await process(.daxRxAudioStream, statusMessage)
          case .daxTx:      await process(.daxTxAudioStream, statusMessage)
          case .remoteRx:   await process(.remoteRxAudioStream, statusMessage)
          case .remoteTx:   await process(.remoteTxAudioStream, statusMessage)
          }
        }
      }
    }
  }
  
  
  public func removeAll(_ type: ObjectType) {
    switch type {
    case .amplifier:              amplifiers.removeAll()
    case .bandSetting:            bandSettings.removeAll()
    case .daxIqStream:            daxIqStreams.removeAll()
    case .daxMicAudioStream:      daxMicAudioStreams.removeAll()
    case .daxRxAudioStream:       daxRxAudioStreams.removeAll()
    case .daxTxAudioStream:       daxTxAudioStreams.removeAll()
    case .memory:                 memories.removeAll()
    case .panadapter:             memories.removeAll()
    case .profile:                profiles.removeAll()
    case .remoteRxAudioStream:    remoteRxAudioStreams.removeAll()
    case .remoteTxAudioStream:    remoteTxAudioStreams.removeAll()
    case .slice:                  slices.removeAll()
    case .tnf:                    tnfs.removeAll()
    case .usbCable:               usbCables.removeAll()
    case .waterfall:              waterfalls.removeAll()
    case .xvtr:                   xvtrs.removeAll()
      
    case .atu, .cwx, .gps, .interlock, .equalizer, .meter, .transmit, .wan, .waveform, .display, .stream:
      break
      
    case .replyHandlers:          replyHandlers.removeAll()
    }
    
  }
  
  
  
  
  
  /// Process an incoming DiscoveryPacket
  /// - Parameter newPacket: the packet
  public func processPacket(_ packet: Packet) {
    var newPacket = packet
    
    // is it a Packet that has been seen previously?
    if let knownPacketId = isKnownRadio(newPacket) {
      // YES, has it changed?
      if newPacket.isDifferent(from: packets[id: knownPacketId]!) {
        // YES, parse the GuiClient fields
        newPacket = newPacket.parseGuiClients()
        let oldPacket = packets[id: knownPacketId]!
        
        // maintain the id from the known packet, update the timestamp
        newPacket.id = knownPacketId
        newPacket.lastSeen = Date()
        // update the known packet
        packets[id: knownPacketId] = newPacket
        
        // publish and log the packet
        radio?.packetPublisher.send(PacketUpdate(.updated, packet: newPacket))
        log("Model: \(newPacket.source.rawValue) packet updated, \(newPacket.nickname) \(newPacket.serial)", .debug, #function, #file, #line)
        
        // find, publish & log client additions / deletions
        findClientAdditions(in: newPacket, from: oldPacket)
        findClientDeletions(in: newPacket, from: oldPacket)
        return
        
      } else {
        // NO, update the timestamp
        packets[id: knownPacketId]!.lastSeen = Date()
        
        return
      }
    }
    // NO, not seen before, parse the GuiClient fields then add it
    newPacket = newPacket.parseGuiClients()
    packets.append(newPacket)
    
    // publish & log
    radio?.packetPublisher.send(PacketUpdate(.added, packet: newPacket))
    log("Model: \(newPacket.source.rawValue) packet added, \(newPacket.nickname) \(newPacket.serial)", .debug, #function, #file, #line)
    
    // find, publish & log client additions
    
    
    // FIXME: ??????
    
    
    //    findClientAdditions(in: newPacket)
  }
  
  
  
  
  
  
  
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
 
  /// Determine if status is for this client
  /// - Parameters:
  ///   - properties:     a KeyValuesArray
  ///   - clientHandle:   the handle of ???
  /// - Returns:          true if a mtch
  public func isForThisClient(_ properties: KeyValuesArray, connectionHandle: Handle?) -> Bool {
    var clientHandle : Handle = 0
    
    guard connectionHandle != nil else { return false }
    
    // allow a Tester app to see all Streams
    guard testerMode == false else { return true }
    
    // find the handle property
    for property in properties.dropFirst(2) where property.key == "client_handle" {
      clientHandle = property.value.handle ?? 0
    }
    return clientHandle == connectionHandle
  }

  /// Is the packet known (i.e. in the collection)
  /// - Parameter newPacket:  the incoming packet
  /// - Returns:              the id, if any, of the matching packet
  private func isKnownRadio(_ newPacket: Packet) -> UUID? {
    var id: UUID?
    
    for packet in packets where packet.serial == newPacket.serial && packet.publicIp == newPacket.publicIp {
      id = packet.id
      break
    }
    return id
  }
  
  private func findClientAdditions(in receivedPacket: Packet, from oldPacket: Packet? = nil) {
    // for each guiClient in the receivedPacket
    for guiClient in receivedPacket.guiClients {
      // if no oldPacket  OR  oldPacket does not contain this guiClient
      if oldPacket == nil || oldPacket?.guiClients[id: guiClient.id] == nil {
        
        // publish & log new guiClient
        radio?.clientPublisher.send(ClientUpdate(.added, client: guiClient, source: receivedPacket.source))
        log("Discovered: \(receivedPacket.source.rawValue) \(receivedPacket.nickname) guiClient added, \(guiClient.station)", .debug, #function, #file, #line)
        
        // FIXME: ?????
        
        //        // create a newPacket with the same source (smartlink OR local)
        //        let newPacket = Packet(source: receivedPacket.source)
        //        // make a mutable copy of the receivedPacket
        //        var mutableReceivedPacket = receivedPacket
        //        // make the receivedPackets's id equal the newly created packet's id
        //        mutableReceivedPacket.id = newPacket.id
        //
        //        // populate the Stations array
        //        stations[id: newPacket.id] = mutableReceivedPacket
        //        stations[id: newPacket.id]?.guiClientStations = guiClient.station
        //        stations[id: newPacket.id]?.guiClients = [guiClient]
      }
    }
  }
  
  private func findClientDeletions(in newPacket: Packet, from oldPacket: Packet) {
    
    for guiClient in oldPacket.guiClients {
      if newPacket.guiClients[id: guiClient.id] == nil {
        
        // publish & log
        radio?.clientPublisher.send(ClientUpdate(.deleted, client: guiClient, source: newPacket.source))
        log("Discovered: \(newPacket.source.rawValue) \(newPacket.nickname) guiClient deleted, \(guiClient.station)", .debug, #function, #file, #line)
        
        for station in stations where station.guiClientStations == guiClient.station {
          stations.remove(station)
        }
      }
    }
  }
  
  // FIXME: can these be turned into a generic????
  
  private func processAmplifier(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.handle!
    if !inUse {
      amplifiers.remove(id: id)
    } else {
      if amplifiers[id: id] == nil { amplifiers.append( Amplifier(id) ) }
      await amplifiers[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processAtu(_ properties: KeyValuesArray) async {
    await atu.parse( Array(properties.dropFirst(1)) )
  }
  
  private func processBandSetting(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.objectId!
    if !inUse {
      bandSettings.remove(id: id)
    } else {
      if bandSettings[id: id] == nil { bandSettings.append( BandSetting(id) ) }
      await bandSettings[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processCwx(_ properties: KeyValuesArray) async {
    await cwx.parse( Array(properties.dropFirst(1)) )
  }
  
  private func processDaxIqStream(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      daxIqStreams.remove(id: id)
    } else {
      if daxIqStreams[id: id] == nil { daxIqStreams.append( DaxIqStream(id) ) }
      await daxIqStreams[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processDaxMicAudioStream(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      daxMicAudioStreams.remove(id: id)
    } else {
      if daxMicAudioStreams[id: id] == nil { daxMicAudioStreams.append( DaxMicAudioStream(id) ) }
      await daxMicAudioStreams[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processDaxRxAudioStream(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      daxRxAudioStreams.remove(id: id)
    } else {
      if daxRxAudioStreams[id: id] == nil { daxRxAudioStreams.append( DaxRxAudioStream(id) ) }
      await daxRxAudioStreams[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processDaxTxAudioStream(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      daxTxAudioStreams.remove(id: id)
    } else {
      if daxTxAudioStreams[id: id] == nil { daxTxAudioStreams.append( DaxTxAudioStream(id) ) }
      await daxTxAudioStreams[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processEqualizer(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key
    if !inUse {
      equalizers.remove(id: id)
    } else {
      if equalizers[id: id] == nil { equalizers.append( Equalizer(id) ) }
      await equalizers[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processGps(_ properties: KeyValuesArray) async {
    await gps.parse( Array(properties.dropFirst(1)) )
  }
  
  private func processInterlock(_ properties: KeyValuesArray) async {
    await interlock.parse( Array(properties.dropFirst(1)) )
  }
  
  private func processMemory(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.objectId!
    if !inUse {
      memories.remove(id: id)
    } else {
      if memories[id: id] == nil { memories.append( Memory(id) ) }
      await memories[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processMeter(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let components = properties[0].key.components(separatedBy: ".")
    if components.count != 2 {return }
    let id = properties[0].key.objectId!
    if !inUse {
      meters.remove(id: id)
    } else {
      if meters[id: id] == nil { meters.append( Meter(id) ) }
      await meters[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processPanadapter(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      panadapters.remove(id: id)
    } else {
      if panadapters[id: id] == nil { panadapters.append( Panadapter(id) ) }
      await panadapters[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processProfile(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key
    if !inUse {
      profiles.remove(id: id)
    } else {
      if profiles[id: id] == nil { profiles.append( Profile(id) ) }
      await profiles[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processRemoteRxAudioStream(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      remoteRxAudioStreams.remove(id: id)
    } else {
      if remoteRxAudioStreams[id: id] == nil { remoteRxAudioStreams.append( RemoteRxAudioStream(id) ) }
      await remoteRxAudioStreams[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processRemoteTxAudioStream(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      remoteTxAudioStreams.remove(id: id)
    } else {
      if remoteTxAudioStreams[id: id] == nil { remoteTxAudioStreams.append( RemoteTxAudioStream(id) ) }
      await remoteTxAudioStreams[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processSlice(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.objectId!
    if !inUse {
      slices.remove(id: id)
    } else {
      if slices[id: id] == nil { slices.append( Slice(id) ) }
      await slices[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processTnf(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.objectId!
    if !inUse {
      tnfs.remove(id: id)
    } else {
      if tnfs[id: id] == nil { tnfs.append( Tnf(id) ) }
      await tnfs[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processTransmit(_ properties: KeyValuesArray) async {
    await wan.parse( Array(properties.dropFirst(1)) )
  }
  
  private func processUsbCable(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key
    if !inUse {
      usbCables.remove(id: id)
    } else {
      if usbCables[id: id] == nil { usbCables.append( UsbCable(id) ) }
      await usbCables[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processWan(_ properties: KeyValuesArray) async {
    await wan.parse( Array(properties.dropFirst(1)) )
  }
  
  private func processWaterfall(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.streamId!
    if !inUse {
      waterfalls.remove(id: id)
    } else {
      if waterfalls[id: id] == nil { waterfalls.append( Waterfall(id) ) }
      await waterfalls[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
  
  private func processWaveform(_ properties: KeyValuesArray) async {
    await waveform.parse( Array(properties.dropFirst(1)) )
  }
  
  private func processXvtr(_ properties: KeyValuesArray, _ inUse: Bool) async {
    // get the Id
    let id = properties[0].key.objectId!
    if !inUse {
      xvtrs.remove(id: id)
    } else {
      if xvtrs[id: id] == nil { xvtrs.append( Xvtr(id) ) }
      await xvtrs[id: id]!.parse( Array(properties.dropFirst(1)) )
    }
  }
}
