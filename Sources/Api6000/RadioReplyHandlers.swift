//
//  RadioReplyHandlers.swift
//  Api6000Components/Api6000
//
//  Created by Douglas Adams on 1/21/22.
//

import Foundation

import Shared

extension Radio {
  // ----------------------------------------------------------------------------
  // MARK: - ReplyHandlers

  /// Add a Reply Handler for a specific Sequence/Command
  /// - Parameters:
  ///   - sequenceId:     sequence number of the Command
  ///   - replyTuple:     a Reply Tuple
  func addReplyHandler(_ seqNumber: UInt, replyTuple: ReplyTuple) {
      // add the handler
    Model.shared.replyHandlers[seqNumber] = replyTuple
  }
  
  /// Parse a Reply
  /// - Parameters:
  ///   - commandSuffix:      a Reply Suffix
  func parseReply(_ replySuffix: Substring) {
    // separate it into its components
    let components = replySuffix.components(separatedBy: "|")
    
    // ignore incorrectly formatted replies
    if components.count < 2 {
      log("Radio: incomplete reply, r\(replySuffix)", .warning, #function, #file, #line)
      return
    }
    // find the command using the sequence number
    if let replyTuple = Model.shared.replyHandlers[ components[0].uValue ] {
      // found
      let command = replyTuple.command
      let reply = components[1]
      let otherData = components.count < 3 ? "" : components[2]
      // Remove the object from the notification list
      Model.shared.replyHandlers[components[0].sequenceNumber] = nil
      
      // Anything other than kNoError is an error, log it and ignore the Reply
      guard reply == kNoError else {
        // ignore non-zero reply from "client program" command
        if !command.hasPrefix("client program ") {
          log("Radio, reply to c\(components[0].sequenceNumber), \(command): non-zero reply \(reply), \(flexErrorString(errorCode: otherData))", .error, #function, #file, #line)
        }
        return
      }
      
      // which command?
      switch command {
        
      case "client gui":    parseGuiReply( otherData.keyValuesArray() )
      case "slice list":    sliceList = otherData.valuesArray().compactMap {$0.objectId}
      case "ant list":      antennaList = otherData.valuesArray( delimiter: "," )
      case "info":          parseInfoReply( (otherData.replacingOccurrences(of: "\"", with: "")).keyValuesArray(delimiter: ",") )
      case "mic list":      micList = otherData.valuesArray(  delimiter: "," )
      case "radio uptime":  uptime = Int(otherData) ?? 0
      case "version":       parseVersionReply( otherData.keyValuesArray(delimiter: "#") )
      default:              if command.hasPrefix("wan validate") { updateState(to: .wanHandleValidated(success: reply == Shared.kNoError)) }
      }

      // was a Handler specified?
      if let handler = replyTuple.replyTo {
        // YES, call the Handler
        handler(command, components[0].sequenceNumber, reply, otherData)
      }
    }
  }
}
