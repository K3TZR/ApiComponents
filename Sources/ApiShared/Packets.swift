//
//  Packets.swift
//  
//
//  Created by Douglas Adams on 6/12/22.
//

import Foundation
import Combine
import IdentifiedCollections

public enum PacketSource: String, Equatable {
  case local = "Local"
  case smartlink = "Smartlink"
}

public struct PacketUpdate: Equatable {
  public var action: ActionType
  public var packet: Packet

  public init(_ action: ActionType, packet: Packet) {
    self.action = action
    self.packet = packet
  }
}

public struct ClientUpdate: Equatable {
  
  public init(_ action: ActionType, client: GuiClient, source: PacketSource) {
    self.action = action
    self.client = client
    self.source = source
  }
  public var action: ActionType
  public var client: GuiClient
  public var source: PacketSource
}

public enum ActionType: String {
  case added
  case deleted
  case updated
}

public var clientPublisher = PassthroughSubject<ClientUpdate, Never>()
public var packetPublisher = PassthroughSubject<PacketUpdate, Never>()
public var testPublisher = PassthroughSubject<SmartlinkTestResult, Never>()
public var wanStatusPublisher = PassthroughSubject<WanStatus, Never>()


public actor Packets {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @MainActor @Published var packetCollection = IdentifiedArrayOf<Packet>()


  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _packets = IdentifiedArrayOf<Packet>()
  
  private enum PacketToken: String {
    case lastSeen                   = "last_seen"
    
    case availableClients           = "available_clients"
    case availablePanadapters       = "available_panadapters"
    case availableSlices            = "available_slices"
    case callsign
    case discoveryProtocolVersion   = "discovery_protocol_version"
    case version                    = "version"
    case fpcMac                     = "fpc_mac"
    case guiClientHandles           = "gui_client_handles"
    case guiClientHosts             = "gui_client_hosts"
    case guiClientIps               = "gui_client_ips"
    case guiClientPrograms          = "gui_client_programs"
    case guiClientStations          = "gui_client_stations"
    case inUseHost                  = "inuse_host"
    case inUseHostWan               = "inusehost"
    case inUseIp                    = "inuse_ip"
    case inUseIpWan                 = "inuseip"
    case licensedClients            = "licensed_clients"
    case maxLicensedVersion         = "max_licensed_version"
    case maxPanadapters             = "max_panadapters"
    case maxSlices                  = "max_slices"
    case model
    case nickname                   = "nickname"
    case port
    case publicIp                   = "ip"
    case publicIpWan                = "public_ip"
    case publicTlsPort              = "public_tls_port"
    case publicUdpPort              = "public_udp_port"
    case publicUpnpTlsPort          = "public_upnp_tls_port"
    case publicUpnpUdpPort          = "public_upnp_udp_port"
    case radioLicenseId             = "radio_license_id"
    case radioName                  = "radio_name"
    case requiresAdditionalLicense  = "requires_additional_license"
    case serial                     = "serial"
    case status
    case upnpSupported              = "upnp_supported"
    case wanConnected               = "wan_connected"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Packets()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ packet: Packet) {
    _packets[id: packet.id] = packet
    Task {
      await updateModel()
    }
  }
  
  public func exists(id: UUID) -> Bool {
    _packets[id: id] != nil
  }
    
  /// Conditionally remove a packet
  /// - Parameter condition:  a closure defining the condition for removal
  public func removeExpired(_ asof: Date) {
    for packet in _packets where packet.source == .local && packet.lastSeen < asof {
      let removedPacket = _packets.remove(id: packet.id)
      packetPublisher.send(PacketUpdate(.deleted, packet: removedPacket!))
      log("Packets: packet removed, interval = \(abs(removedPacket!.lastSeen.timeIntervalSince(Date())))", .debug, #function, #file, #line)
    }
  }

  public func remove(type source: PacketSource) {
    for packet in _packets where packet.source == source {
      remove(packet.id)
    }
  }
  
  /// Remove a Packet
  /// - Parameter id:   a Packet Id
  public func remove(_ id: UUID)  {
    _packets.remove(id: id)
    log("Packet \(id.uuidString): removed", .debug, #function, #file, #line)
    Task {
      await updateModel()
    }
  }
  
  /// Remove all Packets
  public func removeAll()  {
    for packet in _packets {
      remove(packet.id)
    }
  }

  
  
  private func findClientAdditions(in receivedPacket: Packet, from oldPacket: Packet? = nil) {
    // for each guiClient in the receivedPacket
    for guiClient in receivedPacket.guiClients {
      // if no oldPacket  OR  oldPacket does not contain this guiClient
      if oldPacket == nil || oldPacket?.guiClients[id: guiClient.id] == nil {
        
        // publish & log new guiClient
        clientPublisher.send(ClientUpdate(.added, client: guiClient, source: receivedPacket.source))
        log("Packets: \(receivedPacket.source.rawValue) \(receivedPacket.nickname) guiClient added, \(guiClient.station)", .debug, #function, #file, #line)
  
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
        clientPublisher.send(ClientUpdate(.deleted, client: guiClient, source: newPacket.source))
        log("Packets: \(newPacket.source.rawValue) \(newPacket.nickname) guiClient deleted, \(guiClient.station)", .debug, #function, #file, #line)
        
        // FIXME: ?????
              
//        for station in stations where station.guiClientStations == guiClient.station {
//          stations.remove(station)
//        }
      }
    }
  }

  
  
  
  
  // ----------------------------------------------------------------------------
  // MARK: - Public nonisolated methods
  
  public nonisolated func parseProperties(_ properties: KeyValuesArray) -> Packet {
    // create a minimal packet with now as "lastSeen"
    var packet = Packet()
    
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = PacketToken(rawValue: property.key) else {
        // log it and ignore the Key
        #if DEBUG
        fatalError("Packets: Unknown token - \(property.key) = \(property.value)")
        #else
        continue
        #endif
      }
      switch token {
        
        // these fields in the received packet are copied to the Packet struct
      case .callsign:                   packet.callsign = property.value
      case .guiClientHandles:           packet.guiClientHandles = property.value
      case .guiClientHosts:             packet.guiClientHosts = property.value
      case .guiClientIps:               packet.guiClientIps = property.value
      case .guiClientPrograms:          packet.guiClientPrograms = property.value
      case .guiClientStations:          packet.guiClientStations = property.value
      case .inUseHost, .inUseHostWan:   packet.inUseHost = property.value
      case .inUseIp, .inUseIpWan:       packet.inUseIp = property.value
      case .model:                      packet.model = property.value
      case .nickname, .radioName:       packet.nickname = property.value
      case .port:                       packet.port = property.value.iValue
      case .publicIp, .publicIpWan:     packet.publicIp = property.value
      case .publicTlsPort:              packet.publicTlsPort = property.value.iValueOpt
      case .publicUdpPort:              packet.publicUdpPort = property.value.iValueOpt
      case .publicUpnpTlsPort:          packet.publicUpnpTlsPort = property.value.iValueOpt
      case .publicUpnpUdpPort:          packet.publicUpnpUdpPort = property.value.iValueOpt
      case .serial:                     packet.serial = property.value
      case .status:                     packet.status = property.value
      case .upnpSupported:              packet.upnpSupported = property.value.bValue
      case .version:                    packet.version = property.value

        // these fields in the received packet are NOT copied to the Packet struct
      case .availableClients:           break // ignored
      case .availablePanadapters:       break // ignored
      case .availableSlices:            break // ignored
      case .discoveryProtocolVersion:   break // ignored
      case .fpcMac:                     break // ignored
      case .licensedClients:            break // ignored
      case .maxLicensedVersion:         break // ignored
      case .maxPanadapters:             break // ignored
      case .maxSlices:                  break // ignored
      case .radioLicenseId:             break // ignored
      case .requiresAdditionalLicense:  break // ignored
      case .wanConnected:               break // ignored

        // satisfy the switch statement
      case .lastSeen:                   break
      }
    }
    return packet
  }

  /// Process an incoming DiscoveryPacket
  /// - Parameter packet: the new packet
  public func processPacket(_ packet: Packet) {
    var newPacket = packet
    
    // is it a Packet that has been seen previously?
    if let knownPacketId = isKnownRadio(newPacket) {
      // YES, has it changed?
      if newPacket.isDifferent(from: _packets[id: knownPacketId]!) {
        // YES, parse the GuiClient fields
        newPacket = GuiClients.shared.parseGuiClients(in: newPacket)
        let oldPacket = _packets[id: knownPacketId]!
        
        // maintain the id from the known packet, update the timestamp
        newPacket.id = knownPacketId
        newPacket.lastSeen = Date()
        // update the known packet
        _packets[id: knownPacketId] = newPacket

        // publish and log the packet
        packetPublisher.send(PacketUpdate(.updated, packet: newPacket))
        log("Packets: \(newPacket.source.rawValue) packet updated, \(newPacket.nickname) \(newPacket.serial)", .debug, #function, #file, #line)

        // find, publish & log client additions / deletions
        findClientAdditions(in: newPacket, from: oldPacket)
        findClientDeletions(in: newPacket, from: oldPacket)

        Task {
          await updateModel()
        }
        return
      
      } else {
        // NO, update the timestamp
        _packets[id: knownPacketId]!.lastSeen = Date()

        return
      }
    }
    // NO, not seen before, parse the GuiClient fields then add it
    newPacket = GuiClients.shared.parseGuiClients(in: newPacket)
    add( newPacket )

    // publish & log
    packetPublisher.send(PacketUpdate(.added, packet: newPacket))
    log("Packets: \(newPacket.source.rawValue) packet added, \(newPacket.nickname) \(newPacket.serial)", .debug, #function, #file, #line)

    // find, publish & log client additions

    
    // FIXME: ??????
    
    
    //    findClientAdditions(in: newPacket)
    
    Task {
      await updateModel()
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods

  /// Is the packet known (i.e. in the collection)
  /// - Parameter newPacket:  the incoming packet
  /// - Returns:              the id, if any, of the matching packet
  private func isKnownRadio(_ newPacket: Packet) -> UUID? {
    var id: UUID?
    
    for packet in _packets where packet.serial == newPacket.serial && packet.publicIp == newPacket.publicIp {
      id = packet.id
      break
    }
    return id
  }

  @MainActor private func updateModel() async {
    packetCollection = await _packets
  }
}

// ----------------------------------------------------------------------------
// MARK: - Packet struct

public struct Packet: Identifiable, Equatable, Hashable {
  
  public init(source: PacketSource = .local) {
    id = UUID()
    lastSeen = Date() // now
    self.source = source
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  // these fields are NOT in the received packet but are in the Packet struct
  public var id: UUID
  public var lastSeen: Date
  public var source: PacketSource
  public var isPortForwardOn = false
  public var guiClients = IdentifiedArrayOf<GuiClient>()
  public var localInterfaceIP = ""
  public var requiresHolePunch = false
  public var negotiatedHolePunchPort = 0
  public var wanHandle = ""

  // PACKET TYPE                                     LAN   WAN

  // these fields in the received packet ARE COPIED to the Packet struct
  public var callsign = ""                        //  X     X
  public var guiClientHandles = ""                //  X     X
  public var guiClientPrograms = ""               //  X     X
  public var guiClientStations = ""               //  X     X
  public var guiClientHosts = ""                  //  X     X
  public var guiClientIps = ""                    //  X     X
  public var inUseHost = ""                       //  X     X
  public var inUseIp = ""                         //  X     X
  public var model = ""                           //  X     X
  public var nickname = ""                        //  X     X   in WAN as "radio_name"
  public var port = 0                             //  X
  public var publicIp = ""                        //  X     X   in LAN as "ip"
  public var publicTlsPort: Int?                  //        X
  public var publicUdpPort: Int?                  //        X
  public var publicUpnpTlsPort: Int?              //        X
  public var publicUpnpUdpPort: Int?              //        X
  public var serial = ""                          //  X     X
  public var status = ""                          //  X     X
  public var upnpSupported = false                //        X
  public var version = ""                         //  X     X

  // these fields in the received packet ARE NOT COPIED to the Packet struct
//  public var availableClients = 0                 //  X         ignored
//  public var availablePanadapters = 0             //  X         ignored
//  public var availableSlices = 0                  //  X         ignored
//  public var discoveryProtocolVersion = ""        //  X         ignored
//  public var fpcMac = ""                          //  X         ignored
//  public var licensedClients = 0                  //  X         ignored
//  public var maxLicensedVersion = ""              //  X     X   ignored
//  public var maxPanadapters = 0                   //  X         ignored
//  public var maxSlices = 0                        //  X         ignored
//  public var radioLicenseId = ""                  //  X     X   ignored
//  public var requiresAdditionalLicense = false    //  X     X   ignored
//  public var wanConnected = false                 //  X         ignored


  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public static func ==(lhs: Packet, rhs: Packet) -> Bool {
    // same serial number
    return lhs.serial == rhs.serial && lhs.publicIp == rhs.publicIp
  }
  
  public func isDifferent(from knownPacket: Packet) -> Bool {
    // status
    guard status == knownPacket.status else { return true }
    //    guard self.availableClients == currentPacket.availableClients else { return true }
    //    guard self.availablePanadapters == currentPacket.availablePanadapters else { return true }
    //    guard self.availableSlices == currentPacket.availableSlices else { return true }
    // GuiClient
    guard self.guiClientHandles == knownPacket.guiClientHandles else { return true }
    guard self.guiClientPrograms == knownPacket.guiClientPrograms else { return true }
    guard self.guiClientStations == knownPacket.guiClientStations else { return true }
    guard self.guiClientHosts == knownPacket.guiClientHosts else { return true }
    guard self.guiClientIps == knownPacket.guiClientIps else { return true }
    // networking
    guard port == knownPacket.port else { return true }
    guard inUseHost == knownPacket.inUseHost else { return true }
    guard inUseIp == knownPacket.inUseIp else { return true }
    guard publicIp == knownPacket.publicIp else { return true }
    guard publicTlsPort == knownPacket.publicTlsPort else { return true }
    guard publicUdpPort == knownPacket.publicUdpPort else { return true }
    guard publicUpnpTlsPort == knownPacket.publicUpnpTlsPort else { return true }
    guard publicUpnpUdpPort == knownPacket.publicUpnpUdpPort else { return true }
    // user fields
    guard callsign == knownPacket.callsign else { return true }
    guard model == knownPacket.model else { return true }
    guard nickname == knownPacket.nickname else { return true }
    return false
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(publicIp)
  }

}
