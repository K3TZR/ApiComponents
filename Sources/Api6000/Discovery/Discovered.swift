//
//  Discovered.swift
//  ApiComponents/Api6000/Discovery
//
//  Created by Douglas Adams on 3/20/22.
//

import Foundation
import Combine
import IdentifiedCollections

import Shared

//public final class Discovered: Equatable, ObservableObject {
//
//  public static func == (lhs: Discovered, rhs: Discovered) -> Bool {
//    lhs === rhs
//  }
//
//  // ----------------------------------------------------------------------------
//  // MARK: - Publishers
//
//  public var clientPublisher = PassthroughSubject<ClientUpdate, Never>()
//  public var packetPublisher = PassthroughSubject<PacketUpdate, Never>()
//  public var testPublisher = PassthroughSubject<SmartlinkTestResult, Never>()
//  public var wanStatusPublisher = PassthroughSubject<WanStatus, Never>()
//
//  public var stations = IdentifiedArrayOf<Packet>()
//
//  // ----------------------------------------------------------------------------
//  // MARK: - Singleton
//
//  public static var shared = Discovered()
//  private init() {}
//
//  // ----------------------------------------------------------------------------
//  // MARK: - Public methods
//
//  /// Process an incoming DiscoveryPacket
//  /// - Parameter newPacket: the packet
//  public func processPacket(_ packet: Packet) {
//    var newPacket = packet
//
//    // is it a Packet that has been seen previously?
//    if let knownPacketId = isKnownRadio(newPacket) {
//      // YES, has it changed?
//      if newPacket.isDifferent(from: Model.shared.packets[id: knownPacketId]!) {
//        // YES, parse the GuiClient fields
//        newPacket = newPacket.parseGuiClients()
//        let oldPacket = Model.shared.packets[id: knownPacketId]!
//
//        // maintain the id from the known packet, update the timestamp
//        newPacket.id = knownPacketId
//        newPacket.lastSeen = Date()
//        // update the known packet
//        Model.shared.packets[id: knownPacketId] = newPacket
//
//        // publish and log the packet
//        packetPublisher.send(PacketUpdate(.updated, packet: newPacket))
//        log("Discovered: \(newPacket.source.rawValue) packet updated, \(newPacket.nickname) \(newPacket.serial)", .debug, #function, #file, #line)
//
//        // find, publish & log client additions / deletions
//        findClientAdditions(in: newPacket, from: oldPacket)
//        findClientDeletions(in: newPacket, from: oldPacket)
//        return
//
//      } else {
//        // NO, update the timestamp
//        Model.shared.packets[id: knownPacketId]!.lastSeen = Date()
//
//        return
//      }
//    }
//    // NO, not seen before, parse the GuiClient fields then add it
//    newPacket = newPacket.parseGuiClients()
//    Model.shared.packets.append(newPacket)
//
//    // publish & log
//    packetPublisher.send(PacketUpdate(.added, packet: newPacket))
//    log("Discovered: \(newPacket.source.rawValue) packet added, \(newPacket.nickname) \(newPacket.serial)", .debug, #function, #file, #line)
//
//    // find, publish & log client additions
//
//
//    // FIXME: ??????
//
//
//    //    findClientAdditions(in: newPacket)
//  }
//
//  public func removePackets(ofType source: PacketSource) {
//    for packet in Model.shared.packets where packet.source == source {
//      Model.shared.packets.remove(id: packet.id)
//    }
//  }
//
//  // ----------------------------------------------------------------------------
//  // MARK: - Private methods
//
//  private func findClientAdditions(in receivedPacket: Packet, from oldPacket: Packet? = nil) {
//    // for each guiClient in the receivedPacket
//    for guiClient in receivedPacket.guiClients {
//      // if no oldPacket  OR  oldPacket does not contain this guiClient
//      if oldPacket == nil || oldPacket?.guiClients[id: guiClient.id] == nil {
//
//        // publish & log new guiClient
//        clientPublisher.send(ClientUpdate(.added, client: guiClient, source: receivedPacket.source))
//        log("Discovered: \(receivedPacket.source.rawValue) \(receivedPacket.nickname) guiClient added, \(guiClient.station)", .debug, #function, #file, #line)
//
//        // FIXME: ?????
//
////        // create a newPacket with the same source (smartlink OR local)
////        let newPacket = Packet(source: receivedPacket.source)
////        // make a mutable copy of the receivedPacket
////        var mutableReceivedPacket = receivedPacket
////        // make the receivedPackets's id equal the newly created packet's id
////        mutableReceivedPacket.id = newPacket.id
////
////        // populate the Stations array
////        stations[id: newPacket.id] = mutableReceivedPacket
////        stations[id: newPacket.id]?.guiClientStations = guiClient.station
////        stations[id: newPacket.id]?.guiClients = [guiClient]
//      }
//    }
//  }
//
//  private func findClientDeletions(in newPacket: Packet, from oldPacket: Packet) {
//
//    for guiClient in oldPacket.guiClients {
//      if newPacket.guiClients[id: guiClient.id] == nil {
//
//        // publish & log
//        clientPublisher.send(ClientUpdate(.deleted, client: guiClient, source: newPacket.source))
//        log("Discovered: \(newPacket.source.rawValue) \(newPacket.nickname) guiClient deleted, \(guiClient.station)", .debug, #function, #file, #line)
//
//        for station in stations where station.guiClientStations == guiClient.station {
//          stations.remove(station)
//        }
//      }
//    }
//  }
//
//  /// Is the packet known (i.e. in the collection)
//  /// - Parameter newPacket:  the incoming packet
//  /// - Returns:              the id, if any, of the matching packet
//  private func isKnownRadio(_ newPacket: Packet) -> UUID? {
//    var id: UUID?
//
//    for packet in Model.shared.packets where packet.serial == newPacket.serial && packet.publicIp == newPacket.publicIp {
//      id = packet.id
//      break
//    }
//    return id
//  }
//}
