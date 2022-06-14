//
//  Types.swift
//  UtilityComponents/Shared
//
//  Created by Douglas Adams on 5/16/22.
//

import Foundation

// ----------------------------------------------------------------------------
// MARK: - Aliases

// ids
public typealias AmplifierId = Handle
public typealias BandId = ObjectId
public typealias DaxIqStreamId = StreamId
public typealias DaxMicAudioStreamId = StreamId
public typealias DaxRxAudioStreamId = StreamId
public typealias DaxTxAudioStreamId = StreamId
public typealias EqualizerId = String
public typealias GuiClientId = String
public typealias MemoryId = ObjectId
public typealias MeterId = ObjectId
public typealias PanadapterId = StreamId
public typealias ProfileId = String
public typealias RadioId = String
public typealias RemoteRxAudioStreamId = StreamId
public typealias RemoteTxAudioStreamId = StreamId
public typealias SliceId = ObjectId
public typealias TnfId = ObjectId
public typealias UsbCableId = String
public typealias WaterfallId = StreamId
public typealias XvtrId = ObjectId

// other
public typealias AntennaPort = String
public typealias Handle = UInt32
public typealias Hz = Int
public typealias IdToken = String
public typealias KeyValuesArray = [(key:String, value:String)]
public typealias MHz = Double
public typealias MeterName  = String
public typealias MicrophonePort = String
public typealias ObjectId = UInt16
public typealias ProfileName = String
public typealias ReplyHandler = (_ command: String, _ seqNumber: SequenceNumber, _ responseValue: String, _ reply: String) -> Void
public typealias ReplyTuple = (replyTo: ReplyHandler?, command: String)
public typealias RfGainValue = String
public typealias SequenceNumber = UInt
public typealias StreamId = UInt32
public typealias ValuesArray = [String]

public typealias Log = (_ msg: String, _ level: LogLevel, _ function: StaticString, _ file: StaticString, _ line: Int) -> Void
