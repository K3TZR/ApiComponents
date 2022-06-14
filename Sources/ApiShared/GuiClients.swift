//
//  GuiClients.swift
//  
//
//  Created by Douglas Adams on 6/12/22.
//

import Foundation
import Combine
import IdentifiedCollections

// ----------------------------------------------------------------------------
// MARK: - GuiClients Actor
// ----------------------------------------------------------------------------

public actor GuiClients {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @MainActor @Published public var guiClientCollection = IdentifiedArrayOf<GuiClient>()

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _guiClients = IdentifiedArrayOf<GuiClient>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = GuiClients()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ guiClient: GuiClient) {
    _guiClients[id: guiClient.id] = guiClient
    Task {
      await updateModel()
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public nonisolated methods
  
  public func exists(id: Handle) -> Bool {
    _guiClients[id: id] != nil
  }

  /// Parse the GuiClient CSV fields in a packet
  public nonisolated func parseGuiClients(in packet: Packet) -> Packet {
    var updatedPacket = packet

    guard packet.guiClientPrograms != "" && packet.guiClientStations != "" && packet.guiClientHandles != "" else { return packet }
    
    let programs  = packet.guiClientPrograms.components(separatedBy: ",")
    let stations  = packet.guiClientStations.components(separatedBy: ",")
    let handles   = packet.guiClientHandles.components(separatedBy: ",")
    let ips       = packet.guiClientIps.components(separatedBy: ",")
    
    guard programs.count == handles.count && stations.count == handles.count && ips.count == handles.count else { return packet }
    
    for i in 0..<handles.count {
      // valid handle, non-blank other fields?
      if let handle = handles[i].handle, stations[i] != "", programs[i] != "" , ips[i] != "" {
        
        updatedPacket.guiClients.append(
          GuiClient(handle: handle,
                    station: stations[i],
                    program: programs[i],
                    ip: ips[i])
        )
      }
    }
    return updatedPacket
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  @MainActor private func updateModel() async {
    guiClientCollection = await _guiClients
  }
}

// ----------------------------------------------------------------------------
// MARK: - GuiClient Struct
// ----------------------------------------------------------------------------

public struct GuiClient: Equatable, Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  public var id: Handle { handle }
  
  public var clientId: GuiClientId?
  public var handle: Handle = 0
  public var host = ""
  public var ip = ""
  public var isLocalPtt = false
  public var isThisClient = false
  public var program = ""
  public var station = ""
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(handle: Handle, station: String, program: String,
              clientId: GuiClientId? = nil, host: String = "", ip: String = "",
              isLocalPtt: Bool = false, isThisClient: Bool = false) {
    
    self.handle = handle
    self.clientId = clientId
    self.host = host
    self.ip = ip
    self.isLocalPtt = isLocalPtt
    self.isThisClient = isThisClient
    self.program = program
    self.station = station
  }
  
  public static func == (lhs: GuiClient, rhs: GuiClient) -> Bool {
    lhs.handle == rhs.handle
  }
}
