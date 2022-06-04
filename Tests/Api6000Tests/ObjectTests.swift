//
//  ObjectTests.swift
//  Api6000/Api6000Tests
//
//  Created by Douglas Adams on 2/11/20.
//
import XCTest
@testable import Api6000
import Shared

final class ObjectTests: XCTestCase {
  
  // ------------------------------------------------------------------------------
  // MARK: - Amplifier
  
  ///   Format:  <Id, > <"ant", ant> <"ip", ip> <"model", model> <"port", port> <"serial_num", serialNumber>
  func testAmplifierParse() {
    let status = "0x12345678 ant=ANT1 ip=10.0.1.106 model=PGXL port=4123 serial_num=1234-5678-9012 state=STANDBY"
    
    let id = status.keyValuesArray()[0].key.handle!
    
    Amplifier.parseStatus(status.keyValuesArray(), true)
    
    if let amplifier = Model.shared.amplifiers[id: id] {
      
      XCTAssertEqual(amplifier.id, "0x12345678".handle!, file: #function)
      XCTAssertEqual(amplifier.ant, "ANT1", "ant", file: #function)
      XCTAssertEqual(amplifier.ip, "10.0.1.106", file: #function)
      XCTAssertEqual(amplifier.model, "PGXL", file: #function)
      XCTAssertEqual(amplifier.port, 4123, file: #function)
      XCTAssertEqual(amplifier.serialNumber, "1234-5678-9012", file: #function)
      XCTAssertEqual(amplifier.state, "STANDBY", file: #function)
      
      Model.shared.amplifiers[id: id]?.ant = "ANT2"
      Model.shared.amplifiers[id: id]?.ip = "11.1.217.1"
      Model.shared.amplifiers[id: id]?.model = "QIYM"
      Model.shared.amplifiers[id: id]?.port = 3214
      Model.shared.amplifiers[id: id]?.serialNumber = "2109-8765-4321"
      
      if let updatedAmplifier = Model.shared.amplifiers[id: id] {
        XCTAssertEqual(updatedAmplifier.id, "0x12345678".handle!, file: #function)
        XCTAssertEqual(updatedAmplifier.ant, "ANT2", file: #function)
        XCTAssertEqual(updatedAmplifier.ip, "11.1.217.1", file: #function)
        XCTAssertEqual(updatedAmplifier.model, "QIYM", file: #function)
        XCTAssertEqual(updatedAmplifier.port, 3214, file: #function)
        XCTAssertEqual(updatedAmplifier.serialNumber, "2109-8765-4321", file: #function)
        XCTAssertEqual(updatedAmplifier.state, "STANDBY", file: #function)
        
        Amplifier.remove(id)
        
        if Model.shared.amplifiers[id: id] != nil {
          XCTFail("----->>>>> Amplifier NOT removed <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated Amplifier <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Amplifier NOT added <<<<<-----", file: #function)
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Atu
  
  func testAtuParse() async {
    let status = "status=TUNE_MANUAL_BYPASS atu_enabled=1 memories_enabled=1 using_mem=0"

    Atu.parseProperties(status.keyValuesArray())

    XCTAssertEqual(Model.shared.atu.enabled, true, "Enabled", file: #function)
    XCTAssertEqual(Model.shared.atu.memoriesEnabled, true, "Memories Enabled", file: #function)
    XCTAssertEqual(Model.shared.atu.status, "TUNE_MANUAL_BYPASS", "Status", file: #function)
    XCTAssertEqual(Model.shared.atu.usingMemory, false, "Using Memory", file: #function)

    Model.shared.atu.enabled = false
    Model.shared.atu.memoriesEnabled = false
    Model.shared.atu.status = "TUNE"
    Model.shared.atu.usingMemory = true

    XCTAssertEqual(Model.shared.atu.enabled, false, "Enabled", file: #function)
    XCTAssertEqual(Model.shared.atu.memoriesEnabled, false, "Memories Enabled", file: #function)
    XCTAssertEqual(Model.shared.atu.status, "TUNE", "Status", file: #function)
    XCTAssertEqual(Model.shared.atu.usingMemory, true, "Using Memory", file: #function)
  }

  // ------------------------------------------------------------------------------
  // MARK: - BandSetting
  
  func testBandSettingParse() async {
    let status = "9 band_name=20 acc_txreq_enable=0 rca_txreq_enable=0 acc_tx_enabled=0 tx1_enabled=0 tx2_enabled=0 tx3_enabled=0"
    let statusRemoved = "9 removed"

    
    let id = status.keyValuesArray()[0].key.objectId!
    
    BandSetting.parseStatus(status.keyValuesArray(), !status.contains(Shared.kRemoved))
    
    if let bandSetting = Model.shared.bandSettings[id: id] {
      
      XCTAssertEqual(bandSetting.accTxEnabled, false, "AccTxEnabled", file: #function)
      XCTAssertEqual(bandSetting.accTxReqEnabled, false, "AccTxReqEnabled", file: #function)
      XCTAssertEqual(bandSetting.rcaTxReqEnabled, false, "RcaTxReqEnabled", file: #function)
      XCTAssertEqual(bandSetting.tx1Enabled, false, "Tx1Enabled", file: #function)
      XCTAssertEqual(bandSetting.tx2Enabled, false, "Tx2Enabled", file: #function)
      XCTAssertEqual(bandSetting.tx3Enabled, false, "Tx3Enabled", file: #function)

      Model.shared.bandSettings[id: id]!.accTxEnabled = true
      Model.shared.bandSettings[id: id]!.accTxReqEnabled = false
      Model.shared.bandSettings[id: id]!.rcaTxReqEnabled = false
      Model.shared.bandSettings[id: id]!.tx1Enabled = true
      Model.shared.bandSettings[id: id]!.tx2Enabled = true
      Model.shared.bandSettings[id: id]!.tx3Enabled = true
      
      if let updatedBandSetting = Model.shared.bandSettings[id: id] {
        XCTAssertEqual(updatedBandSetting.accTxEnabled, true, "AccTxEnabled", file: #function)
        XCTAssertEqual(updatedBandSetting.accTxReqEnabled, false, "AccTxReqEnabled", file: #function)
        XCTAssertEqual(updatedBandSetting.rcaTxReqEnabled, false, "RcaTxReqEnabled", file: #function)
        XCTAssertEqual(updatedBandSetting.tx1Enabled, true, "Tx1Enabled", file: #function)
        XCTAssertEqual(updatedBandSetting.tx2Enabled, true, "Tx2Enabled", file: #function)
        XCTAssertEqual(updatedBandSetting.tx3Enabled, true, "Tx3Enabled", file: #function)

        BandSetting.parseStatus(statusRemoved.keyValuesArray(), !statusRemoved.contains(Shared.kRemoved))
        
        if Model.shared.bandSettings[id: id] != nil {
          XCTFail("----->>>>> BandSetting removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated BandSetting <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> BandSetting NOT added <<<<<-----", file: #function)
    }
  }

  func testBandSettingParse_2() {
    let status = "998 band_name=WWV rfpower=50 tunepower=10 hwalc_enabled=1 inhibit=0"
    let statusRemoved = "998 removed"

    let id = status.keyValuesArray()[0].key.objectId!
    
    BandSetting.parseStatus(status.keyValuesArray(), !status.contains(Shared.kRemoved))
    
    if let bandSetting = Model.shared.bandSettings[id: id] {
      
      XCTAssertEqual(bandSetting.bandName, "WWV", "AccTxEnabled", file: #function)
      XCTAssertEqual(bandSetting.hwAlcEnabled, true, "HwAlcEnabled", file: #function)
      XCTAssertEqual(bandSetting.inhibit, false, "Inhibit", file: #function)
      XCTAssertEqual(bandSetting.rfPower, 50, "RfPower", file: #function)
      XCTAssertEqual(bandSetting.tunePower, 10, "TunePower", file: #function)

      Model.shared.bandSettings[id: id]!.bandName = "75"
      Model.shared.bandSettings[id: id]!.hwAlcEnabled = false
      Model.shared.bandSettings[id: id]!.inhibit = true
      Model.shared.bandSettings[id: id]!.rfPower = 76
      Model.shared.bandSettings[id: id]!.tunePower = 22
      
      if let updatedBandSetting = Model.shared.bandSettings[id: id] {
        XCTAssertEqual(updatedBandSetting.bandName, "75", "BandName", file: #function)
        XCTAssertEqual(updatedBandSetting.hwAlcEnabled, false, "HwAlcEnabled", file: #function)
        XCTAssertEqual(updatedBandSetting.inhibit, true, "Inhibit", file: #function)
        XCTAssertEqual(updatedBandSetting.rfPower, 76, "RfPower", file: #function)
        XCTAssertEqual(updatedBandSetting.tunePower, 22, "TunePower", file: #function)

        BandSetting.parseStatus(statusRemoved.keyValuesArray(), !statusRemoved.contains(Shared.kRemoved))
        
        if Model.shared.bandSettings[id: id] != nil {
          XCTFail("----->>>>> BandSetting removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated BandSetting <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> BandSetting NOT added <<<<<-----", file: #function)
    }
  }

  // ------------------------------------------------------------------------------
  // MARK: - Cwx
  
  // FIXME:
  
  // ------------------------------------------------------------------------------
  // MARK: - DaxIqStream
  
  func testDaxIqStreamParse() async {
    let status = "0x20000000 type=dax_iq daxiq_channel=3 pan=0x40000000 ip=10.0.1.107 daxiq_rate=48000"
    let statusRemoved = "0x20000000 removed"
    let id = status.keyValuesArray()[0].key.streamId!
    
    DaxIqStream.parseStatus(status.keyValuesArray(), !status.contains(Shared.kRemoved))
    
    if let daxIqStream = Model.shared.daxIqStreams[id: id] {
      
      XCTAssertEqual(daxIqStream.clientHandle, "0".handle!, "ClientHandle", file: #function)
      XCTAssertEqual(daxIqStream.channel, 3, "Channel", file: #function)
      XCTAssertEqual(daxIqStream.pan, "0x40000000".streamId, "Pan", file: #function)
      XCTAssertEqual(daxIqStream.ip, "10.0.1.107", "Ip", file: #function)
      XCTAssertEqual(daxIqStream.rate, 48_000, "Rate", file: #function)

      Model.shared.daxIqStreams[id: id]?.clientHandle = "2345".handle!
      Model.shared.daxIqStreams[id: id]?.channel = 2
      Model.shared.daxIqStreams[id: id]?.pan = "0x40000001".streamId!
      Model.shared.daxIqStreams[id: id]?.ip = "10.0.1.1"
      Model.shared.daxIqStreams[id: id]?.rate = 24_000

      if let updatedDaxIqStream = Model.shared.daxIqStreams[id: id] {
        XCTAssertEqual(updatedDaxIqStream.clientHandle, "2345".handle!, "ClientHandle", file: #function)
        XCTAssertEqual(updatedDaxIqStream.channel, 2, "Channel", file: #function)
        XCTAssertEqual(updatedDaxIqStream.pan, "0x40000001".streamId!, "Pan", file: #function)
        XCTAssertEqual(updatedDaxIqStream.ip, "10.0.1.1", "Ip", file: #function)
        XCTAssertEqual(updatedDaxIqStream.rate, 24_000, "Rate", file: #function)

        DaxIqStream.parseStatus(statusRemoved.keyValuesArray(), !statusRemoved.contains(Shared.kRemoved))

        if Model.shared.daxIqStreams[id: id] != nil {
          XCTFail("----->>>>> DaxIqStream removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated DaxIqStream <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> DaxIqStream NOT added <<<<<-----", file: #function)
    }
  }

  // ------------------------------------------------------------------------------
  // MARK: - DaxMicAudioStream
  
  func testDaxMicAudioStreamParse() async {
    
    // FIXME: NEED STATUS STRING
    
    let status = ""
    
    let id = status.keyValuesArray()[0].key.streamId!
    
    DaxMicAudioStream.parseStatus(status.keyValuesArray(), true)
    
    if let daxMicAudioStream = Model.shared.daxMicAudioStreams[id: id] {
      
      XCTAssertEqual(daxMicAudioStream.clientHandle, "1234".handle!, "ClientHandle", file: #function)
      XCTAssertEqual(daxMicAudioStream.ip, "192.168.1.200", "Ip", file: #function)

      Model.shared.daxMicAudioStreams[id: id]?.clientHandle = "2345".handle!
      Model.shared.daxMicAudioStreams[id: id]?.ip = "10.0.1.1"
      
      if let updatedDaxMicAudioStream = Model.shared.daxMicAudioStreams[id: id] {
        XCTAssertEqual(updatedDaxMicAudioStream.clientHandle, "2345".handle!, "ClientHandle", file: #function)
        XCTAssertEqual(updatedDaxMicAudioStream.ip, "10.0.1.1", "Ip", file: #function)
        
        DaxRxAudioStream.remove(id)
        
        if Model.shared.daxRxAudioStreams[id: id] != nil {
          XCTFail("----->>>>> DaxRxAudioStream removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated DaxRxAudioStream <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> DaxRxAudioStream NOT added <<<<<-----", file: #function)
    }
  }

  // ------------------------------------------------------------------------------
  // MARK: - DaxRxAudioStream
  
  func testDaxRxAudioStreamParse() async {
    
    // FIXME: NEED STATUS STRING
    
    let status = ""
    
    let id = status.keyValuesArray()[0].key.streamId!
    
    DaxRxAudioStream.parseStatus(status.keyValuesArray(), true)
    
    if let daxRxAudioStream = Model.shared.daxRxAudioStreams[id: id] {
      
      XCTAssertEqual(daxRxAudioStream.clientHandle, "1234".handle!, "ClientHandle", file: #function)
      XCTAssertEqual(daxRxAudioStream.daxChannel, 0, "DaxChannel", file: #function)
      XCTAssertEqual(daxRxAudioStream.ip, "192.168.1.200", "Ip", file: #function)

      Model.shared.daxRxAudioStreams[id: id]?.clientHandle = "2345".handle!
      Model.shared.daxRxAudioStreams[id: id]?.daxChannel = 1
      Model.shared.daxRxAudioStreams[id: id]?.ip = "10.0.1.1"
      
      if let updatedDaxRxAudioStream = Model.shared.daxRxAudioStreams[id: id] {
        XCTAssertEqual(updatedDaxRxAudioStream.clientHandle, "2345".handle!, "ClientHandle", file: #function)
        XCTAssertEqual(updatedDaxRxAudioStream.daxChannel, 1, "DaxChannel", file: #function)
        XCTAssertEqual(updatedDaxRxAudioStream.ip, "10.0.1.1", "Ip", file: #function)
        
        DaxRxAudioStream.remove(id)
        
        if Model.shared.daxRxAudioStreams[id: id] != nil {
          XCTFail("----->>>>> DaxRxAudioStream removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated DaxRxAudioStream <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> DaxRxAudioStream NOT added <<<<<-----", file: #function)
    }
  }

  // ------------------------------------------------------------------------------
  // MARK: - DaxTxAudioStream
  
  func testDaxTxAudioStreamParse() async {
    
    // FIXME: NEED STATUS STRING
    
    let status = ""
    
    let id = status.keyValuesArray()[0].key.streamId!
    
    DaxTxAudioStream.parseStatus(status.keyValuesArray(), true)
    
    if let daxTxAudioStream = Model.shared.daxTxAudioStreams[id: id] {
      
      XCTAssertEqual(daxTxAudioStream.clientHandle, "1234".handle!, "ClientHandle", file: #function)
      XCTAssertEqual(daxTxAudioStream.isTransmitChannel, true, "IsTransmitChannel", file: #function)
      XCTAssertEqual(daxTxAudioStream.ip, "192.168.1.200", "Ip", file: #function)

      Model.shared.daxTxAudioStreams[id: id]?.clientHandle = "2345".handle!
      Model.shared.daxTxAudioStreams[id: id]?.isTransmitChannel = false
      Model.shared.daxTxAudioStreams[id: id]?.ip = "10.0.1.1"

      
      if let updatedDaxTxAudioStream = Model.shared.daxTxAudioStreams[id: id] {
        XCTAssertEqual(updatedDaxTxAudioStream.clientHandle, "2345".handle!, "ClientHandle", file: #function)
        XCTAssertEqual(updatedDaxTxAudioStream.isTransmitChannel, false, "DaxChannel", file: #function)
        XCTAssertEqual(updatedDaxTxAudioStream.ip, "10.0.1.1", "Ip", file: #function)
        
        DaxTxAudioStream.remove(id)
        
        if Model.shared.daxTxAudioStreams[id: id] != nil {
          XCTFail("----->>>>> DaxTxAudioStream removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated DaxTxAudioStream <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> DaxTxAudioStream NOT added <<<<<-----", file: #function)
    }
  }

  // ------------------------------------------------------------------------------
  // MARK: - Equalizer
  
  func testEqualizerRxParse() {
    equalizerParse(status: "rxsc mode=0 63Hz=0 125Hz=10 250Hz=20 500Hz=30 1000Hz=-10 2000Hz=-20 4000Hz=-30 8000Hz=-40")
  }
  func testEqualizerTxParse() {
    equalizerParse(status: "txsc mode=0 63Hz=0 125Hz=10 250Hz=20 500Hz=30 1000Hz=-10 2000Hz=-20 4000Hz=-30 8000Hz=-40")
  }

  func equalizerParse(status: String) {
    
    let id = status.keyValuesArray()[0].key
    
    if id == "rxsc" || id == "txsc" {
      Equalizer.parseStatus(status.keyValuesArray(), true)
      
      if let equalizer = Model.shared.equalizers[id: id] {
        XCTAssertEqual(equalizer.eqEnabled, false, "eqEnabled", file: #function)
        XCTAssertEqual(equalizer.level63Hz, 0, "level63Hz", file: #function)
        XCTAssertEqual(equalizer.level125Hz, 10, "level125Hz", file: #function)
        XCTAssertEqual(equalizer.level250Hz, 20, "level250Hz", file: #function)
        XCTAssertEqual(equalizer.level500Hz, 30, "level500Hz", file: #function)
        XCTAssertEqual(equalizer.level1000Hz, -10, "level1000Hz", file: #function)
        XCTAssertEqual(equalizer.level2000Hz, -20, "level2000Hz", file: #function)
        XCTAssertEqual(equalizer.level4000Hz, -30, "level4000Hz", file: #function)
        XCTAssertEqual(equalizer.level8000Hz, -40, "level8000Hz", file: #function)
        
        Model.shared.equalizers[id: id]?.eqEnabled = true
        Model.shared.equalizers[id: id]?.level63Hz    = 10
        Model.shared.equalizers[id: id]?.level125Hz   = -10
        Model.shared.equalizers[id: id]?.level250Hz   = 15
        Model.shared.equalizers[id: id]?.level500Hz   = -20
        Model.shared.equalizers[id: id]?.level1000Hz  = 30
        Model.shared.equalizers[id: id]?.level2000Hz  = -30
        Model.shared.equalizers[id: id]?.level4000Hz  = 40
        Model.shared.equalizers[id: id]?.level8000Hz  = -35
        
        if let updatedEqualizer = Model.shared.equalizers[id: id] {
          XCTAssertEqual(updatedEqualizer.eqEnabled, true, "eqEnabled", file: #function)
          XCTAssertEqual(updatedEqualizer.level63Hz, 10, "level63Hz", file: #function)
          XCTAssertEqual(updatedEqualizer.level125Hz, -10, "level125Hz", file: #function)
          XCTAssertEqual(updatedEqualizer.level250Hz, 15, "level250Hz", file: #function)
          XCTAssertEqual(updatedEqualizer.level500Hz, -20, "level500Hz", file: #function)
          XCTAssertEqual(updatedEqualizer.level1000Hz, 30, "level1000Hz", file: #function)
          XCTAssertEqual(updatedEqualizer.level2000Hz, -30, "level2000Hz", file: #function)
          XCTAssertEqual(updatedEqualizer.level4000Hz, 40, "level4000Hz", file: #function)
          XCTAssertEqual(updatedEqualizer.level8000Hz, -35, "level8000Hz", file: #function)
          
        } else {
          XCTFail("----->>>>> Unable to access updated Equalizer <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Equalizer NOT added <<<<<-----", file: #function)
      }
      Equalizer.remove(id)
      
      if Model.shared.equalizers[id: id] != nil {
        XCTFail("----->>>>> Equalizer NOT removed <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Invalid Equalizer type - \(id) <<<<<-----", file: #function)
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Gps
  
  // FIXME:
  
  // ------------------------------------------------------------------------------
  // MARK: - Interlock
  
  func testInterlockParse() async {
    let status = "acc_txreq_enable=1 rca_txreq_enable=0 acc_tx_enabled=1 tx1_enabled=0 tx2_enabled=0 tx3_enabled=0 tx_delay=5 acc_tx_delay=10 tx1_delay=10 tx2_delay=15 tx3_delay=20 acc_txreq_polarity=0 rca_txreq_polarity=1 timeout=10"

    Interlock.parseProperties(status.keyValuesArray())

    XCTAssertEqual(Model.shared.interlock.accTxEnabled, true, "AccTxEnabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.accTxDelay, 10, "AccTxDelay", file: #function)
    XCTAssertEqual(Model.shared.interlock.accTxReqEnabled, true, "AccTxReqEnabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.accTxReqPolarity, false, "AccTxReqPolarity", file: #function)
    XCTAssertEqual(Model.shared.interlock.amplifier, "", "Amplifier", file: #function)
    XCTAssertEqual(Model.shared.interlock.rcaTxReqEnabled, false, "RcaTxReqEnabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.rcaTxReqPolarity, true, "RcaTxReqPolarity", file: #function)
    XCTAssertEqual(Model.shared.interlock.reason, "", "Reason", file: #function)
    XCTAssertEqual(Model.shared.interlock.source, "", "Source", file: #function)
    XCTAssertEqual(Model.shared.interlock.state, "", "State", file: #function)
    XCTAssertEqual(Model.shared.interlock.timeout, 10, "Timeout", file: #function)
    XCTAssertEqual(Model.shared.interlock.txAllowed, false, "TxAllowed", file: #function)
    XCTAssertEqual(Model.shared.interlock.txClientHandle, "0".handle, "TxClientHandle", file: #function)
    XCTAssertEqual(Model.shared.interlock.txDelay, 5, "TxDelay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx1Delay, 10, "Tx1Delay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx1Enabled, false, "Tx1Enabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx2Delay, 15, "Tx2Delay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx2Enabled, false, "Tx2Enabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx3Delay, 20, "Tx3Delay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx3Enabled, false, "Tx3Enabled", file: #function)

    Model.shared.interlock.accTxEnabled = false
    Model.shared.interlock.accTxDelay =  25
    Model.shared.interlock.accTxReqEnabled =  false
    Model.shared.interlock.accTxReqPolarity =  true
    Model.shared.interlock.amplifier =  "Tuner"
    Model.shared.interlock.rcaTxReqEnabled =  true
    Model.shared.interlock.rcaTxReqPolarity =  false
    Model.shared.interlock.reason =  "Reason2"
    Model.shared.interlock.source =  "Switch"
    Model.shared.interlock.state =  "Standby"
    Model.shared.interlock.timeout =  26
    Model.shared.interlock.txAllowed =  true
    Model.shared.interlock.txClientHandle =  "2345".handle!
    Model.shared.interlock.txDelay =  13
    Model.shared.interlock.tx1Delay =  22
    Model.shared.interlock.tx1Enabled =  true
    Model.shared.interlock.tx2Delay =  26
    Model.shared.interlock.tx2Enabled =  true
    Model.shared.interlock.tx3Delay =  18
    Model.shared.interlock.tx3Enabled =  true

    XCTAssertEqual(Model.shared.interlock.accTxEnabled, false, "AccTxEnabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.accTxDelay, 25, "AccTxDelay", file: #function)
    XCTAssertEqual(Model.shared.interlock.accTxReqEnabled, false, "AccTxReqEnabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.accTxReqPolarity, true, "AccTxReqPolarity", file: #function)
    XCTAssertEqual(Model.shared.interlock.amplifier, "Tuner", "Amplifier", file: #function)
    XCTAssertEqual(Model.shared.interlock.rcaTxReqEnabled, true, "RcaTxReqEnabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.rcaTxReqPolarity, false, "RcaTxReqPolarity", file: #function)
    XCTAssertEqual(Model.shared.interlock.reason, "Reason2", "Reason", file: #function)
    XCTAssertEqual(Model.shared.interlock.source, "Switch", "Source", file: #function)
    XCTAssertEqual(Model.shared.interlock.state, "Standby", "State", file: #function)
    XCTAssertEqual(Model.shared.interlock.timeout, 26, "Timeout", file: #function)
    XCTAssertEqual(Model.shared.interlock.txAllowed, true, "TxAllowed", file: #function)
    XCTAssertEqual(Model.shared.interlock.txClientHandle, "2345".handle, "TxClientHandle", file: #function)
    XCTAssertEqual(Model.shared.interlock.txDelay, 13, "TxDelay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx1Delay, 22, "Tx1Delay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx1Enabled, true, "Tx1Enabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx2Delay, 26, "Tx2Delay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx2Enabled, true, "Tx2Enabled", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx3Delay, 18, "Tx3Delay", file: #function)
    XCTAssertEqual(Model.shared.interlock.tx3Enabled, true, "Tx3Enabled", file: #function)

  }

  // ------------------------------------------------------------------------------
  // MARK: - Memory
  
  func testMemoryParse() {
    
    let status = "1 owner=K3TZR group= freq=14.100000 name= mode=USB step=100 repeater=SIMPLEX repeater_offset=0.000000 tone_mode=OFF tone_value=67.0 power=100 rx_filter_low=100 rx_filter_high=2900 highlight=0 highlight_color=0x00000000 squelch=1 squelch_level=20 rtty_mark=2 rtty_shift=170 digl_offset=2210 digu_offset=1500"
    
    let id = status.keyValuesArray()[0].key.objectId!
    
    Memory.parseStatus(status.keyValuesArray(), true)
    
    if let memory = Model.shared.memories[id: id] {
      XCTAssertEqual(memory.owner, "K3TZR", "owner", file: #function)
      XCTAssertEqual(memory.group, "", "Group", file: #function)
      XCTAssertEqual(memory.frequency, 14_100_000, "frequency", file: #function)
      XCTAssertEqual(memory.name, "", "name", file: #function)
      XCTAssertEqual(memory.mode, "USB", "mode", file: #function)
      XCTAssertEqual(memory.step, 100, "step", file: #function)
      XCTAssertEqual(memory.offsetDirection, "SIMPLEX", "offsetDirection", file: #function)
      XCTAssertEqual(memory.offset, 0, "offset", file: #function)
      XCTAssertEqual(memory.toneMode, "OFF", "toneMode", file: #function)
      XCTAssertEqual(memory.toneValue, 67.0, "toneValue", file: #function)
      XCTAssertEqual(memory.filterLow, 100, "filterLow", file: #function)
      XCTAssertEqual(memory.filterHigh, 2_900, "filterHigh", file: #function)
      //      XCTAssertEqual(object.highlight, false, "highlight", file: #function)
      //      XCTAssertEqual(object.highlightColor, "0x00000000".streamId, "highlightColor", file: #function)
      XCTAssertEqual(memory.squelchEnabled, true, "squelchEnabled", file: #function)
      XCTAssertEqual(memory.squelchLevel, 20, "squelchLevel", file: #function)
      XCTAssertEqual(memory.rttyMark, 2, "rttyMark", file: #function)
      XCTAssertEqual(memory.rttyShift, 170, "rttyShift", file: #function)
      XCTAssertEqual(memory.digitalLowerOffset, 2210, "digitalLowerOffset", file: #function)
      XCTAssertEqual(memory.digitalUpperOffset, 1500, "digitalUpperOffset", file: #function)
      
      Model.shared.memories[id: id]?.owner = "DL3LSM"
      Model.shared.memories[id: id]?.group = "X"
      Model.shared.memories[id: id]?.frequency = 7_125_000
      Model.shared.memories[id: id]?.name = "40"
      Model.shared.memories[id: id]?.mode = "LSB"
      Model.shared.memories[id: id]?.step = 212
      Model.shared.memories[id: id]?.offsetDirection = "UP"
      Model.shared.memories[id: id]?.offset = 10
      Model.shared.memories[id: id]?.toneMode = "ON"
      Model.shared.memories[id: id]?.toneValue = 76.0
      Model.shared.memories[id: id]?.filterLow = 200
      Model.shared.memories[id: id]?.filterHigh = 3_000
      //      object.highligh
      //      object.highligh "0x01010101".streamId!
      Model.shared.memories[id: id]?.squelchEnabled = false
      Model.shared.memories[id: id]?.squelchLevel = 19
      Model.shared.memories[id: id]?.rttyMark = 3
      Model.shared.memories[id: id]?.rttyShift = 269
      Model.shared.memories[id: id]?.digitalLowerOffset = 3321
      Model.shared.memories[id: id]?.digitalUpperOffset = 2612
      
      if let updatedMemory = Model.shared.memories[id: id] {
        XCTAssertEqual(updatedMemory.owner, "DL3LSM", "owner", file: #function)
        XCTAssertEqual(updatedMemory.group, "X", "group", file: #function)
        XCTAssertEqual(updatedMemory.frequency, 7_125_000, "frequency", file: #function)
        XCTAssertEqual(updatedMemory.name, "40", "name", file: #function)
        XCTAssertEqual(updatedMemory.mode, "LSB", "mode", file: #function)
        XCTAssertEqual(updatedMemory.step, 212, "step", file: #function)
        XCTAssertEqual(updatedMemory.offsetDirection, "UP", "offsetDirection", file: #function)
        XCTAssertEqual(updatedMemory.offset, 10, "offset", file: #function)
        XCTAssertEqual(updatedMemory.toneMode, "ON", "toneMode", file: #function)
        XCTAssertEqual(updatedMemory.toneValue, 76.0, "toneValue", file: #function)
        XCTAssertEqual(updatedMemory.filterLow, 200, "filterLow", file: #function)
        XCTAssertEqual(updatedMemory.filterHigh, 3_000, "filterHigh", file: #function)
        //      XCTAssertEqual(object.highlight, true, "highlight", file: #function)
        //      XCTAssertEqual(object.highlightColor, "0x01010101".streamId, "highlightColor", file: #function)
        XCTAssertEqual(updatedMemory.squelchEnabled, false, "squelchEnabled", file: #function)
        XCTAssertEqual(updatedMemory.squelchLevel, 19, "squelchLevel", file: #function)
        XCTAssertEqual(updatedMemory.rttyMark, 3, "rttyMark", file: #function)
        XCTAssertEqual(updatedMemory.rttyShift, 269, "rttyShift", file: #function)
        XCTAssertEqual(updatedMemory.digitalLowerOffset, 3321, "digitalLowerOffset", file: #function)
        XCTAssertEqual(updatedMemory.digitalUpperOffset, 2612, "digitalUpperOffset", file: #function)
        
        Memory.remove(id)
        
        if Model.shared.memories[id: id] != nil {
          XCTFail("----->>>>> Memory removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated Memory <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Memory NOT added <<<<<-----", file: #function)
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Meter
  
  func testMeterParse() {
    let status = "1.src=COD-#1.num=1#1.nam=MICPEAK#1.low=-150.0#1.hi=20.0#1.desc=Signal strength of MIC output in CODEC#1.unit=dBFS#1.fps=40#"
    
    Meter.parseStatus(status.keyValuesArray(delimiter: "#"), true)
    
    let firstKey = status.keyValuesArray(delimiter: "#")[0].key
    let idString = String(firstKey.prefix(while: { $0 != "."} ))
    let id = idString.objectId!

    if let meter = Model.shared.meters[id: id] {
      
      XCTAssertEqual(meter.source, "cod-", "source", file: #function)
      XCTAssertEqual(meter.name, "micpeak", "name", file: #function)
      XCTAssertEqual(meter.low, -150.0, "low", file: #function)
      XCTAssertEqual(meter.high, 20.0, "high", file: #function)
      XCTAssertEqual(meter.desc, "Signal strength of MIC output in CODEC", "desc", file: #function)
      XCTAssertEqual(meter.units, "dbfs", "units", file: #function)
      XCTAssertEqual(meter.fps, 40, "fps", file: #function)
      
      Meter.remove(id)
      
      if Model.shared.meters[id: id] != nil {
        XCTFail("----->>>>> Meter removal FAILED <<<<<-----", file: #function)
      }
      
    } else {
      XCTFail("----->>>>> Meter NOT added <<<<<-----", file: #function)
    }
  }
  
  // ------------------------------------------------------------------------------
  //  // MARK: - NetCwStream

  // FIXME:
  
  //  func testNetCwStream () {
  //    let type = "NetCwStream"
  //    var existingObjects = false
  //
  //    Swift.print("\n-------------------- \(#function) --------------------\n")
  //
  //    let radio = discoverRadio(logState: .limited(to: [type + ".swift"]))
  //    guard radio != nil else { return }
  //
  //    if radio!.netCwStream.isActive {
  //      existingObjects = true
  //      if showInfoMessages { Swift.print("\n***** Existing \(type) removed") }
  //
  //      // remove it
  //      radio!.netCwStream.remove()
  //      sleep(2)
  //    }
  //    if radio!.netCwStream.isActive == false {
  //
  //      if showInfoMessages && existingObjects { Swift.print("***** Existing \(type)(s) removal confirmed") }
  //
  //      if showInfoMessages { Swift.print("\n***** \(type) requested") }
  //
  //      // ask for new
  //      radio!.requestNetCwStream()
  //      sleep(2)
  //
  //      // verify added
  //      if radio!.netCwStream.isActive {
  //
  //        if showInfoMessages { Swift.print("***** \(type) added\n") }
  //
  //        if radio!.netCwStream.id != 0 {
  //
  //          if showInfoMessages { Swift.print("***** \(type) removed") }
  //
  //          radio!.netCwStream.remove()
  //          sleep(2)
  //
  //          if radio!.netCwStream.isActive == false {
  //
  //            if showInfoMessages { Swift.print("***** \(type) removal confirmed\n") }
  //
  //          } else {
  //            XCTFail("----->>>>> \(type) removal FAILED <<<<<-----", file: #function)
  //          }
  //        } else {
  //          XCTFail("----->>>>> \(type) StreamId invalid <<<<<-----", file: #function)
  //        }
  //      } else {
  //        XCTFail("----->>>>> \(type) NOT added <<<<<-----", file: #function)
  //      }
  //    } else {
  //      XCTFail("----->>>>> Existing \(type) removal FAILED <<<<<-----", file: #function)
  //    }
  //    disconnect()
  //  }
  //
    // ------------------------------------------------------------------------------
    // MARK: - Panadapter
    
  func testPanadapterParse() {
    let status = "pan 0x40000001 wnb=0 wnb_level=92 wnb_updating=0 band_zoom=0 segment_zoom=0 x_pixels=50 y_pixels=100 center=14.100000 bandwidth=0.200000 min_dbm=-125.00 max_dbm=-40.00 fps=25 average=23 weighted_average=0 rfgain=50 rxant=ANT1 wide=0 loopa=0 loopb=1 band=20 daxiq=0 daxiq_rate=0 capacity=16 available=16 waterfall=42000000 min_bw=0.004920 max_bw=14.745601 xvtr= pre= ant_list=ANT1,ANT2,RX_A,XVTR"
    
    let id = status.components(separatedBy: " ")[1].streamId!
    
    Panadapter.parseStatus(status.keyValuesArray(), true)
    
    if let panadapter = Model.shared.panadapters[id: id] {
      
      XCTAssertEqual(panadapter.wnbLevel, 92, file: #function)
      XCTAssertEqual(panadapter.wnbUpdating, false, file: #function)
      XCTAssertEqual(panadapter.bandZoomEnabled, false, file: #function)
      XCTAssertEqual(panadapter.segmentZoomEnabled, false, file: #function)
      XCTAssertEqual(panadapter.xPixels, 0, file: #function)
      XCTAssertEqual(panadapter.yPixels, 0, file: #function)
      XCTAssertEqual(panadapter.center, 14_100_000, file: #function)
      XCTAssertEqual(panadapter.bandwidth, 200_000, file: #function)
      XCTAssertEqual(panadapter.minDbm, -125.00, file: #function)
      XCTAssertEqual(panadapter.maxDbm, -40.00, file: #function)
      XCTAssertEqual(panadapter.fps, 25, file: #function)
      XCTAssertEqual(panadapter.average, 23, file: #function)
      XCTAssertEqual(panadapter.weightedAverageEnabled, false, file: #function)
      XCTAssertEqual(panadapter.rfGain, 50, file: #function)
      XCTAssertEqual(panadapter.rxAnt, "ANT1", file: #function)
      XCTAssertEqual(panadapter.wide, false, file: #function)
      XCTAssertEqual(panadapter.loopAEnabled, false, file: #function)
      XCTAssertEqual(panadapter.loopBEnabled, true, file: #function)
      XCTAssertEqual(panadapter.band, "20", file: #function)
      XCTAssertEqual(panadapter.daxIqChannel, 0, file: #function)
      XCTAssertEqual(panadapter.waterfallId, "0x42000000".streamId!, file: #function)
      XCTAssertEqual(panadapter.minBw, 4_920, file: #function)
      XCTAssertEqual(panadapter.maxBw, 14_745_601, file: #function)
      XCTAssertEqual(panadapter.antList, ["ANT1","ANT2","RX_A","XVTR"], file: #function)
      
      Model.shared.panadapters[id: id]?.wnbLevel = 50
      Model.shared.panadapters[id: id]?.bandZoomEnabled = true
      Model.shared.panadapters[id: id]?.segmentZoomEnabled = true
      Model.shared.panadapters[id: id]?.xPixels = 250
      Model.shared.panadapters[id: id]?.yPixels = 125
      Model.shared.panadapters[id: id]?.center = 15_250_000
      Model.shared.panadapters[id: id]?.bandwidth = 300_000
      Model.shared.panadapters[id: id]?.minDbm = -150
      Model.shared.panadapters[id: id]?.maxDbm = 20
      Model.shared.panadapters[id: id]?.fps = 10
      Model.shared.panadapters[id: id]?.average = 30
      Model.shared.panadapters[id: id]?.weightedAverageEnabled = true
      Model.shared.panadapters[id: id]?.rfGain = 10
      Model.shared.panadapters[id: id]?.rxAnt = "ANT2"
      Model.shared.panadapters[id: id]?.loopAEnabled = true
      Model.shared.panadapters[id: id]?.loopBEnabled = false
      Model.shared.panadapters[id: id]?.band = "WWV2"
      Model.shared.panadapters[id: id]?.daxIqChannel = 1
      Model.shared.panadapters[id: id]?.waterfallId = "0x42000001".streamId!
      Model.shared.panadapters[id: id]?.minBw = 10_000
      Model.shared.panadapters[id: id]?.maxBw = 10_000_000
      Model.shared.panadapters[id: id]?.antList = ["ANT2","RX_A","XVTR"]
      
      if let updatedPanadapter = Model.shared.panadapters[id: id] {
        XCTAssertEqual(updatedPanadapter.wnbLevel, 50, file: #function)
        XCTAssertEqual(updatedPanadapter.wnbUpdating, false, file: #function)
        XCTAssertEqual(updatedPanadapter.bandZoomEnabled, true, file: #function)
        XCTAssertEqual(updatedPanadapter.segmentZoomEnabled, true, file: #function)
        XCTAssertEqual(updatedPanadapter.xPixels, 250, file: #function)
        XCTAssertEqual(updatedPanadapter.yPixels, 125, file: #function)
        XCTAssertEqual(updatedPanadapter.center, 15_250_000, file: #function)
        XCTAssertEqual(updatedPanadapter.bandwidth, 300_000, file: #function)
        XCTAssertEqual(updatedPanadapter.minDbm, -150, file: #function)
        XCTAssertEqual(updatedPanadapter.maxDbm, 20, file: #function)
        XCTAssertEqual(updatedPanadapter.fps, 10, file: #function)
        XCTAssertEqual(updatedPanadapter.average, 30, file: #function)
        XCTAssertEqual(updatedPanadapter.weightedAverageEnabled, true, file: #function)
        XCTAssertEqual(updatedPanadapter.rfGain, 10, file: #function)
        XCTAssertEqual(updatedPanadapter.rxAnt, "ANT2", file: #function)
        XCTAssertEqual(updatedPanadapter.wide, false, file: #function)
        XCTAssertEqual(updatedPanadapter.loopAEnabled, true, file: #function)
        XCTAssertEqual(updatedPanadapter.loopBEnabled, false, file: #function)
        XCTAssertEqual(updatedPanadapter.band, "WWV2", file: #function)
        XCTAssertEqual(updatedPanadapter.daxIqChannel, 1, file: #function)
        XCTAssertEqual(updatedPanadapter.waterfallId, "0x42000001".streamId!, file: #function)
        XCTAssertEqual(updatedPanadapter.minBw, 10_000, file: #function)
        XCTAssertEqual(updatedPanadapter.maxBw, 10_000_000, file: #function)
        XCTAssertEqual(updatedPanadapter.antList, ["ANT2","RX_A","XVTR"], file: #function)
         
        Panadapter.remove(id)
        
        if Model.shared.panadapters[id: id] != nil {
          XCTFail("----->>>>> Panadapter removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated Panadapter <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Panadapter NOT added <<<<<-----", file: #function)
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Profile
  
  // FIXME:
  
  // ------------------------------------------------------------------------------
  // MARK: - RemoteRxAudioStream
  
  // FIXME:

  // ------------------------------------------------------------------------------
  // MARK: - RemoteTxAudioStream
  
  // FIXME:

  // ------------------------------------------------------------------------------
  // MARK: - Slice
  
  func testSliceParse() {
    let status = "1 mode=USB filter_lo=100 filter_hi=2800 agc_mode=med agc_threshold=65 agc_off_level=10 qsk=1 step=100 step_list=1,10,50,100,500,1000,2000,3000 anf=1 anf_level=33 nr=0 nr_level=25 nb=1 nb_level=50 wnb=0 wnb_level=42 apf=1 apf_level=76 squelch=1 squelch_level=22 in_use=1 rf_frequency=15.000"
    
    let id = status.keyValuesArray()[0].key.objectId!
    
    Slice.parseStatus(status.keyValuesArray(), true)
    
    if let slice = Model.shared.slices[id: id] {
      
      XCTAssertEqual(slice.mode, "USB", "mode", file: #function)
      XCTAssertEqual(slice.filterLow, 100, "filterLow", file: #function)
      XCTAssertEqual(slice.filterHigh, 2_800, "filterHigh", file: #function)
      XCTAssertEqual(slice.agcMode, "med", "agcMode", file: #function)
      XCTAssertEqual(slice.agcThreshold, 65, "agcThreshold", file: #function)
      XCTAssertEqual(slice.agcOffLevel, 10, "agcOffLevel", file: #function)
      XCTAssertEqual(slice.qskEnabled, true, "qskEnabled", file: #function)
      XCTAssertEqual(slice.step, 100, "step", file: #function)
      XCTAssertEqual(slice.stepList, "1,10,50,100,500,1000,2000,3000", "stepList", file: #function)
      XCTAssertEqual(slice.anfEnabled, true, "anfEnabled", file: #function)
      XCTAssertEqual(slice.anfLevel, 33, "anfLevel", file: #function)
      XCTAssertEqual(slice.nrEnabled, false, "nrEnabled", file: #function)
      XCTAssertEqual(slice.nrLevel, 25, "nrLevel", file: #function)
      XCTAssertEqual(slice.nbEnabled, true, "nbEnabled", file: #function)
      XCTAssertEqual(slice.nbLevel, 50, "nbLevel", file: #function)
      XCTAssertEqual(slice.wnbEnabled, false, "wnbEnabled", file: #function)
      XCTAssertEqual(slice.wnbLevel, 42, "wnbLevel", file: #function)
      XCTAssertEqual(slice.apfEnabled, true, "apfEnabled", file: #function)
      XCTAssertEqual(slice.apfLevel, 76, "apfLevel", file: #function)
      XCTAssertEqual(slice.squelchEnabled, true, "squelchEnabled", file: #function)
      XCTAssertEqual(slice.squelchLevel, 22, "squelchLevel", file: #function)
      
      Model.shared.slices[id: id]?.mode = "LSB"
      Model.shared.slices[id: id]?.filterLow = 300
      Model.shared.slices[id: id]?.filterHigh = 4_000
      Model.shared.slices[id: id]?.agcMode = "low"
      Model.shared.slices[id: id]?.agcThreshold = 40
      Model.shared.slices[id: id]?.agcOffLevel = 20
      Model.shared.slices[id: id]?.qskEnabled = false
      Model.shared.slices[id: id]?.step = 150
      Model.shared.slices[id: id]?.stepList = "10,20,50"
      Model.shared.slices[id: id]?.anfEnabled = false
      Model.shared.slices[id: id]?.anfLevel = 50
      Model.shared.slices[id: id]?.nrEnabled = false
      Model.shared.slices[id: id]?.nrLevel = 70
      Model.shared.slices[id: id]?.nbEnabled = false
      Model.shared.slices[id: id]?.nbLevel = 25
      Model.shared.slices[id: id]?.wnbEnabled = true
      Model.shared.slices[id: id]?.wnbLevel = 72
      Model.shared.slices[id: id]?.apfEnabled = false
      Model.shared.slices[id: id]?.apfLevel = 30
      Model.shared.slices[id: id]?.squelchEnabled = false
      Model.shared.slices[id: id]?.squelchLevel = 18
      
      if let updatedSlice = Model.shared.slices[id: id] {
        XCTAssertEqual(updatedSlice.mode, "LSB", "mode", file: #function)
        XCTAssertEqual(updatedSlice.filterLow, 300, "filterLow", file: #function)
        XCTAssertEqual(updatedSlice.filterHigh, 4_000, "filterHigh", file: #function)
        XCTAssertEqual(updatedSlice.agcMode, "low", "agcMode", file: #function)
        XCTAssertEqual(updatedSlice.agcThreshold, 40, "agcThreshold", file: #function)
        XCTAssertEqual(updatedSlice.agcOffLevel, 20, "agcOffLevel", file: #function)
        XCTAssertEqual(updatedSlice.qskEnabled, false, "qskEnabled", file: #function)
        XCTAssertEqual(updatedSlice.step, 150, "step", file: #function)
        XCTAssertEqual(updatedSlice.stepList, "10,20,50", "stepList", file: #function)
        XCTAssertEqual(updatedSlice.anfEnabled, false, "anfEnabled", file: #function)
        XCTAssertEqual(updatedSlice.anfLevel, 50, "anfLevel", file: #function)
        XCTAssertEqual(updatedSlice.nrEnabled, false, "nrEnabled", file: #function)
        XCTAssertEqual(updatedSlice.nrLevel, 70, "nrLevel", file: #function)
        XCTAssertEqual(updatedSlice.nbEnabled, false, "nbEnabled", file: #function)
        XCTAssertEqual(updatedSlice.nbLevel, 25, "nbLevel", file: #function)
        XCTAssertEqual(updatedSlice.wnbEnabled, true, "wnbEnabled", file: #function)
        XCTAssertEqual(updatedSlice.wnbLevel, 72, "wnbLevel", file: #function)
        XCTAssertEqual(updatedSlice.apfEnabled, false, "apfEnabled", file: #function)
        XCTAssertEqual(updatedSlice.apfLevel, 30, "apfLevel", file: #function)
        XCTAssertEqual(updatedSlice.squelchEnabled, false, "squelchEnabled", file: #function)
        XCTAssertEqual(updatedSlice.squelchLevel, 18, "squelchLevel", file: #function)
        
        Slice.remove(id)
        
        if Model.shared.slices[id: id] != nil {
          XCTFail("----->>>>> Slice removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated Slice <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Slice NOT added <<<<<-----\n", file: #function)
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Tnf
  
  func testTnfParse() async {
    let status = "1 freq=14.16 depth=2 width=0.000100 permanent=1"
    
    let id = status.keyValuesArray()[0].key.objectId!
    
    Tnf.parseStatus(status.keyValuesArray(), true)
    
    if let tnf = Model.shared.tnfs[id: id] {
      
      XCTAssertEqual(tnf.depth, 2, "Depth", file: #function)
      XCTAssertEqual(tnf.frequency, 14_160_000, "Frequency", file: #function)
      XCTAssertEqual(tnf.permanent, true, "Permanent", file: #function)
      XCTAssertEqual(tnf.width, 100, "Width", file: #function)
      
      Model.shared.tnfs[id: id]?.depth = Tnf.Depth.veryDeep.rawValue
      Model.shared.tnfs[id: id]?.frequency = 14_250_000
      Model.shared.tnfs[id: id]?.permanent = false
      Model.shared.tnfs[id: id]?.width = 6_000
      
      if let updatedTnf = Model.shared.tnfs[id: id] {
        XCTAssertEqual(updatedTnf.depth, Tnf.Depth.veryDeep.rawValue, "Depth", file: #function)
        XCTAssertEqual(updatedTnf.frequency, 14_250_000, "Frequency", file: #function)
        XCTAssertEqual(updatedTnf.permanent, false, "Permanent", file: #function)
        XCTAssertEqual(updatedTnf.width, 6_000, "Width", file: #function)
        
        Tnf.remove(id)
        
        if Model.shared.tnfs[id: id] != nil {
          XCTFail("----->>>>> Tnf removal FAILED <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated Tnf <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Tnf NOT added <<<<<-----", file: #function)
    }
  }
    
  // ------------------------------------------------------------------------------
  // MARK: - Transmit
  
  func testTransmit_1() {
    let status = "tx_rf_power_changes_allowed=1 tune=0 show_tx_in_waterfall=0 mon_available=1 max_power_level=100"
    
    Transmit.parseProperties(status.keyValuesArray())
    
    XCTAssertEqual(Model.shared.transmit.txRfPowerChanges, true, "txRfPowerChanges", file: #function)
    XCTAssertEqual(Model.shared.transmit.tune, false, "tune", file: #function)
    XCTAssertEqual(Model.shared.transmit.txInWaterfallEnabled, false, "txInWaterfallEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorAvailable, true, "txMonitorAvailable", file: #function)
    XCTAssertEqual(Model.shared.transmit.maxPowerLevel, 100, "maxPowerLevel", file: #function)
    
    Model.shared.transmit.txRfPowerChanges = false
    Model.shared.transmit.tune = true
    Model.shared.transmit.txInWaterfallEnabled = true
    Model.shared.transmit.txMonitorAvailable = false
    Model.shared.transmit.maxPowerLevel = 50
    
    XCTAssertEqual(Model.shared.transmit.txRfPowerChanges, false, "txRfPowerChanges", file: #function)
    XCTAssertEqual(Model.shared.transmit.tune, true, "tune", file: #function)
    XCTAssertEqual(Model.shared.transmit.txInWaterfallEnabled, true, "txInWaterfallEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorAvailable, false, "txMonitorAvailable", file: #function)
    XCTAssertEqual(Model.shared.transmit.maxPowerLevel, 50, "maxPowerLevel", file: #function)
  }
  
    func testTransmit_2() {
      let status = "am_carrier_level=35 compander=1 compander_level=50 break_in_delay=10 break_in=0"
    
      Transmit.parseProperties(status.keyValuesArray())
            
      XCTAssertEqual(Model.shared.transmit.carrierLevel, 35, "carrierLevel", file: #function)
      XCTAssertEqual(Model.shared.transmit.companderEnabled, true, "companderEnabled", file: #function)
      XCTAssertEqual(Model.shared.transmit.companderLevel, 50, "companderLevel", file: #function)
      XCTAssertEqual(Model.shared.transmit.cwBreakInDelay, 10, "cwBreakInDelay", file: #function)
      XCTAssertEqual(Model.shared.transmit.cwBreakInEnabled, false, "cwBreakInEnabled", file: #function)

      Model.shared.transmit.carrierLevel = 50
      Model.shared.transmit.companderEnabled = false
      Model.shared.transmit.companderLevel = 75
      Model.shared.transmit.cwBreakInDelay = 20
      Model.shared.transmit.cwBreakInEnabled = true

      XCTAssertEqual(Model.shared.transmit.carrierLevel, 50, "carrierLevel", file: #function)
      XCTAssertEqual(Model.shared.transmit.companderEnabled, false, "companderEnabled", file: #function)
      XCTAssertEqual(Model.shared.transmit.companderLevel, 75, "companderLevel", file: #function)
      XCTAssertEqual(Model.shared.transmit.cwBreakInDelay, 20, "cwBreakInDelay", file: #function)
      XCTAssertEqual(Model.shared.transmit.cwBreakInEnabled, true, "cwBreakInEnabled", file: #function)
    }
  
  
  func testTransmit_3() {
    let status = "freq=14.100000 rfpower=100 tunepower=10 tx_slice_mode=USB hwalc_enabled=0 inhibit=0 dax=0 sb_monitor=0 mon_gain_sb=75 mon_pan_sb=50 met_in_rx=0 am_carrier_level=100 mic_selection=MIC mic_level=40 mic_boost=1 mic_bias=0 mic_acc=0 compander=1 compander_level=70 vox_enable=0 vox_level=50 vox_delay=72 speech_processor_enable=1 speech_processor_level=0 lo=100 hi=2900 tx_filter_changes_allowed=1 tx_antenna=ANT1 pitch=600 speed=30 iambic=1 iambic_mode=1 swap_paddles=0 break_in=1 break_in_delay=41 cwl_enabled=0 sidetone=1 mon_gain_cw=80 mon_pan_cw=50 synccwx=1"
    
    Transmit.parseProperties(status.keyValuesArray())
    
    XCTAssertEqual(Model.shared.transmit.carrierLevel, 100, "carrierLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.companderEnabled, true, "companderEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.companderLevel, 70, "companderLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwIambicEnabled, true, "cwIambicEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwIambicMode, 1, "cwIambicMode", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwPitch, 600, "cwPitch", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSpeed, 30, "cwSpeed", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSwapPaddles, false, "cwSwapPaddles", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwBreakInDelay, 41, "cwBreakInDelay", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwBreakInEnabled, true, "cwBreakInEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwlEnabled, false, "cwlEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSidetoneEnabled, true, "cwSidetoneEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSyncCwxEnabled, true, "cwSyncCwxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.daxEnabled, false, "daxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.frequency, 14_100_000, "frequency", file: #function)
    XCTAssertEqual(Model.shared.transmit.hwAlcEnabled, false, "hwAlcEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.inhibit, false, "inhibit", file: #function)
    XCTAssertEqual(Model.shared.transmit.metInRxEnabled, false, "metInRxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micAccEnabled, false, "micAccEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micBiasEnabled, false, "micBiasEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micBoostEnabled, true, "micBoostEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micLevel, 40, "micLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.micSelection, "MIC", "micSelection", file: #function)
    XCTAssertEqual(Model.shared.transmit.rfPower, 100, "rfPower", file: #function)
    XCTAssertEqual(Model.shared.transmit.speechProcessorEnabled, true, "speechProcessorEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.speechProcessorLevel, 0, "speechProcessorLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.tunePower, 10, "tunePower", file: #function)
    XCTAssertEqual(Model.shared.transmit.txAntenna, "ANT1", "txAntenna", file: #function)
    XCTAssertEqual(Model.shared.transmit.txFilterChanges, true, "txFilterChanges", file: #function)
    XCTAssertEqual(Model.shared.transmit.txFilterHigh, 2_900, "txFilterHigh", file: #function)
    XCTAssertEqual(Model.shared.transmit.txFilterLow, 100, "txFilterLow", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorEnabled, false, "txMonitorEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorGainCw, 80, "txMonitorGainCw", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorGainSb, 75, "txMonitorGainSb", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorPanCw, 50, "txMonitorPanCw", file: #function)
    XCTAssertEqual(Model.shared.transmit.txSliceMode, "USB", "txSliceMode", file: #function)
    XCTAssertEqual(Model.shared.transmit.voxDelay, 72, "voxDelay", file: #function)
    XCTAssertEqual(Model.shared.transmit.voxEnabled, false, "voxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.voxLevel, 50, "voxLevel", file: #function)
    
    Model.shared.transmit.carrierLevel = 50
    Model.shared.transmit.companderEnabled = false
    Model.shared.transmit.companderLevel = 35
    Model.shared.transmit.cwIambicEnabled = false
    Model.shared.transmit.cwIambicMode = 0
    Model.shared.transmit.cwPitch = 900
    Model.shared.transmit.cwSpeed = 15
    Model.shared.transmit.cwSwapPaddles = true
    Model.shared.transmit.cwBreakInDelay = 20
    Model.shared.transmit.cwBreakInEnabled = false
    Model.shared.transmit.cwlEnabled = true
    Model.shared.transmit.cwSidetoneEnabled = false
    Model.shared.transmit.cwSyncCwxEnabled = false
    Model.shared.transmit.daxEnabled = true
    Model.shared.transmit.frequency = 21_100_000
    Model.shared.transmit.hwAlcEnabled = true
    Model.shared.transmit.inhibit = true
    Model.shared.transmit.metInRxEnabled = true
    Model.shared.transmit.micAccEnabled = true
    Model.shared.transmit.micBiasEnabled = true
    Model.shared.transmit.micBoostEnabled = false
    Model.shared.transmit.micLevel = 80
    Model.shared.transmit.micSelection = "MAC"
    Model.shared.transmit.rfPower = 50
    Model.shared.transmit.speechProcessorEnabled = false
    Model.shared.transmit.speechProcessorLevel = 20
    Model.shared.transmit.tunePower = 5
    Model.shared.transmit.txAntenna = "ANT2"
    Model.shared.transmit.txFilterChanges = false
    Model.shared.transmit.txFilterHigh = 3_500
    Model.shared.transmit.txFilterLow = 200
    Model.shared.transmit.txMonitorEnabled = true
    Model.shared.transmit.txMonitorGainCw = 40
    Model.shared.transmit.txMonitorGainSb = 50
    Model.shared.transmit.txMonitorPanCw = 25
    Model.shared.transmit.txSliceMode = "LSB"
    Model.shared.transmit.voxDelay = 30
    Model.shared.transmit.voxEnabled = true
    Model.shared.transmit.voxLevel = 33
    
    XCTAssertEqual(Model.shared.transmit.carrierLevel, 50, "carrierLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.companderEnabled, false, "companderEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.companderLevel, 35, "companderLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwIambicEnabled, false, "cwIambicEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwIambicMode, 0, "cwIambicMode", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwPitch, 900, "cwPitch", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSpeed, 15, "cwSpeed", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSwapPaddles, true, "cwSwapPaddles", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwBreakInDelay, 20, "cwBreakInDelay", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwBreakInEnabled, false, "cwBreakInEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwlEnabled, true, "cwlEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSidetoneEnabled, false, "cwSidetoneEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.cwSyncCwxEnabled, false, "cwSyncCwxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.daxEnabled, true, "daxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.frequency, 21_100_000, "frequency", file: #function)
    XCTAssertEqual(Model.shared.transmit.hwAlcEnabled, true, "hwAlcEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.inhibit, true, "inhibit", file: #function)
    XCTAssertEqual(Model.shared.transmit.metInRxEnabled, true, "metInRxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micAccEnabled, true, "micAccEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micBiasEnabled, true, "micBiasEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micBoostEnabled, false, "micBoostEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.micLevel, 80, "micLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.micSelection, "MAC", "micSelection", file: #function)
    XCTAssertEqual(Model.shared.transmit.rfPower, 50, "rfPower", file: #function)
    XCTAssertEqual(Model.shared.transmit.speechProcessorEnabled, false, "speechProcessorEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.speechProcessorLevel, 20, "speechProcessorLevel", file: #function)
    XCTAssertEqual(Model.shared.transmit.tunePower, 5, "tunePower", file: #function)
    XCTAssertEqual(Model.shared.transmit.txAntenna, "ANT2", "txAntenna", file: #function)
    XCTAssertEqual(Model.shared.transmit.txFilterChanges, false, "txFilterChanges", file: #function)
    XCTAssertEqual(Model.shared.transmit.txFilterHigh, 3_500, "txFilterHigh", file: #function)
    XCTAssertEqual(Model.shared.transmit.txFilterLow, 200, "txFilterLow", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorEnabled, true, "txMonitorEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorGainCw, 40, "txMonitorGainCw", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorGainSb, 50, "txMonitorGainSb", file: #function)
    XCTAssertEqual(Model.shared.transmit.txMonitorPanCw, 25, "txMonitorPanCw", file: #function)
    XCTAssertEqual(Model.shared.transmit.txSliceMode, "LSB", "txSliceMode", file: #function)
    XCTAssertEqual(Model.shared.transmit.voxDelay, 30, "voxDelay", file: #function)
    XCTAssertEqual(Model.shared.transmit.voxEnabled, true, "voxEnabled", file: #function)
    XCTAssertEqual(Model.shared.transmit.voxLevel, 33, "voxLevel", file: #function)
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - UsbCable
  
  // FIXME:

  //  func testUsbCableParse() {
  //    let type = "UsbCable"
  //
  //    Swift.print("\n-------------------- \(#function) --------------------\n")
  //
  //    let radio = discoverRadio(logState: .limited(to: [type + ".swift"]))
  //    guard radio != nil else { return }
  //
  //    XCTFail("----->>>>> \(type) test NOT implemented <<<<<-----", file: #function)
  //
  //    disconnect()
  //  }
  //
  //  func testUsbCable() {
  //    let type = "UsbCable"
  //
  //    Swift.print("\n-------------------- \(#function) --------------------\n")
  //
  //    let radio = discoverRadio(logState: .limited(to: [type + ".swift"]))
  //    guard radio != nil else { return }
  //
  //    XCTFail("----->>>>> \(type) test NOT implemented <<<<<-----", file: #function)
  //
  //    disconnect()
  //  }
  //
  
  // ------------------------------------------------------------------------------
  // MARK: - Wan
  
  func testWanParse() async {
    let status = "server_connected=1 radio_authenticated=1"
    
    Wan.parseProperties(status.keyValuesArray())
    
    XCTAssertEqual(Model.shared.wan.serverConnected, true, "Server Connected", file: #function)
    XCTAssertEqual(Model.shared.wan.radioAuthenticated, true, "Radio Authenticated", file: #function)
    
    Model.shared.wan.serverConnected = false
    Model.shared.wan.radioAuthenticated = false

    XCTAssertEqual(Model.shared.wan.serverConnected, false, "Server Connected", file: #function)
    XCTAssertEqual(Model.shared.wan.radioAuthenticated, false, "Radio Authenticated", file: #function)
  }

  // ------------------------------------------------------------------------------
  // MARK: - Waterfall
    
  func testWaterfallParse() {
    let status = "waterfall 0x42000004 x_pixels=50 center=14.100000 bandwidth=0.200000 band_zoom=0 segment_zoom=0 line_duration=100 rfgain=0 rxant=ANT1 wide=0 loopa=0 loopb=0 band=20 daxiq=0 daxiq_rate=0 capacity=16 available=16 panadapter=40000000 color_gain=50 auto_black=1 black_level=20 gradient_index=1 xvtr="
    
    let id = status.keyValuesArray()[1].key.streamId!
    
    Waterfall.parseStatus(status.keyValuesArray(), true)
    
    if let waterfall = Model.shared.waterfalls[id: id] {
      
      XCTAssertEqual(waterfall.autoBlackEnabled, true, "AutoBlackEnabled", file: #function)
      XCTAssertEqual(waterfall.blackLevel, 20, "BlackLevel", file: #function)
      XCTAssertEqual(waterfall.colorGain, 50, "ColorGain", file: #function)
      XCTAssertEqual(waterfall.gradientIndex, 1, "GradientIndex", file: #function)
      XCTAssertEqual(waterfall.lineDuration, 100, "LineDuration", file: #function)
      XCTAssertEqual(waterfall.panadapterId, "0x40000000".streamId, "Panadapter Id", file: #function)
      
      Model.shared.waterfalls[id: id]?.autoBlackEnabled = false
      Model.shared.waterfalls[id: id]?.blackLevel = 30
      Model.shared.waterfalls[id: id]?.colorGain = 70
      Model.shared.waterfalls[id: id]?.gradientIndex = 2
      Model.shared.waterfalls[id: id]?.lineDuration = 80
      
      
      if let updatedWaterfall = Model.shared.waterfalls[id: id] {
        XCTAssertEqual(updatedWaterfall.autoBlackEnabled, false, "AutoBlackEnabled", file: #function)
        XCTAssertEqual(updatedWaterfall.blackLevel, 30, "BlackLevel", file: #function)
        XCTAssertEqual(updatedWaterfall.colorGain, 70, "ColorGain", file: #function)
        XCTAssertEqual(updatedWaterfall.gradientIndex, 2, "GradientIndex", file: #function)
        XCTAssertEqual(updatedWaterfall.lineDuration, 80, "LineDuration", file: #function)
        
        Waterfall.remove(id)
        
        if Model.shared.waterfalls[id: id] != nil {
          XCTFail("----->>>>> Waterfall NOT removed <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated Waterfall <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Waterfall NOT added <<<<<-----", file: #function)
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Waveform
  
  func testWaveformParse() async {
    let status = "installed_list=Waveform1,Waveform2,Waveform3"
    
    Waveform.parseProperties(status.keyValuesArray())
    
    XCTAssertEqual(Model.shared.waveform.waveformList, "Waveform1,Waveform2,Waveform3", "List", file: #function)
    
    Model.shared.waveform.waveformList = "Waveform2,Waveform3"
    
    XCTAssertEqual(Model.shared.waveform.waveformList, "Waveform2,Waveform3", "List", file: #function)
  }

  // ------------------------------------------------------------------------------
  // MARK: - Xvtr
  
  func testXvtrParse() {
    let status = "0 name=12345678 rf_freq=220 if_freq=28 lo_error=0 max_power=10 rx_gain=0 order=0 rx_only=1 is_valid=1 preferred=1 two_meter_int=0"
    
    let id = status.keyValuesArray()[0].key.objectId!
    
    Xvtr.parseStatus(status.keyValuesArray(), true)
    
    if let xvtr = Model.shared.xvtrs[id: id] {
      
      XCTAssertEqual(xvtr.ifFrequency, 28_000_000, "IfFrequency", file: #function)
      XCTAssertEqual(xvtr.isValid, true, "IsValid", file: #function)
      XCTAssertEqual(xvtr.loError, 0, "LoError", file: #function)
      XCTAssertEqual(xvtr.name, "1234", "Name", file: #function)
      XCTAssertEqual(xvtr.maxPower, 10, "MaxPower", file: #function)
      XCTAssertEqual(xvtr.order, 0, "Order", file: #function)
      XCTAssertEqual(xvtr.preferred, true, "Preferred", file: #function)
      XCTAssertEqual(xvtr.rfFrequency, 220_000_000, "RfFrequency", file: #function)
      XCTAssertEqual(xvtr.rxGain, 0, "RxGain", file: #function)
      XCTAssertEqual(xvtr.rxOnly, true, "RxOnly", file: #function)
      
      Model.shared.xvtrs[id: id]?.ifFrequency = 29_000_000
      Model.shared.xvtrs[id: id]?.loError = 5
      Model.shared.xvtrs[id: id]?.name = "2345"
      Model.shared.xvtrs[id: id]?.maxPower = 20
      Model.shared.xvtrs[id: id]?.order = 1
      Model.shared.xvtrs[id: id]?.rfFrequency = 440_000_000
      Model.shared.xvtrs[id: id]?.rxGain = 2
      Model.shared.xvtrs[id: id]?.rxOnly = false
      
      if let updatedXvtr = Model.shared.xvtrs[id: id] {
        XCTAssertEqual(updatedXvtr.ifFrequency, 29_000_000, "IfFrequency", file: #function)
        XCTAssertEqual(updatedXvtr.isValid, true, "IsValid", file: #function)
        XCTAssertEqual(updatedXvtr.loError, 5, "LoError", file: #function)
        XCTAssertEqual(updatedXvtr.name, "2345", "Name", file: #function)
        XCTAssertEqual(updatedXvtr.maxPower, 20, "MaxPower", file: #function)
        XCTAssertEqual(updatedXvtr.order, 1, "Order", file: #function)
        XCTAssertEqual(updatedXvtr.preferred, true, "Preferred", file: #function)
        XCTAssertEqual(updatedXvtr.rfFrequency, 440_000_000, "RfFrequency", file: #function)
        XCTAssertEqual(updatedXvtr.rxGain, 2, "RxGain", file: #function)
        XCTAssertEqual(updatedXvtr.rxOnly, false, "RxOnly", file: #function)
        
        Xvtr.remove(id)
        
        if Model.shared.xvtrs[id: id] != nil {
          XCTFail("----->>>>> Xvtr NOT removed <<<<<-----", file: #function)
        }
      } else {
        XCTFail("----->>>>> Unable to access updated Xvtr <<<<<-----", file: #function)
      }
    } else {
      XCTFail("----->>>>> Xvtr NOT added <<<<<-----", file: #function)
    }
  }
}
 //
  //  func testInterlockExport() {
  //    let type = "Interlock"
  //
  //    Swift.print("\n-------------------- \(#function) --------------------\n")
  //
  //    let radio = discoverRadio(logState: .limited(to: [type + ".swift"]))
  //    guard radio != nil else { return }
  //
  //    do {
  //      let json = try radio?.interlock.export()
  //      Swift.print(json!)
  //
  //    } catch {
  //      print(error.localizedDescription)
  //      XCTFail("----->>>>> Interlock export FAILED <<<<<-----", file: #function)
  //    }
  //    disconnect()
  //  }
  //
  //  func testInterlockImport() {
  //    let type = "Interlock"
  //
  //    Swift.print("\n-------------------- \(#function) --------------------\n")
  //
  //    let radio = discoverRadio(logState: .limited(to: [type + ".swift"]))
  //    guard radio != nil else { return }
  //
  //    let json =
  //    """
  //    {
  //      "_accTxDelay" : 10,
  //      "_accTxEnabled" : true,
  //      "_accTxReqEnabled" : false,
  //      "_accTxReqPolarity" : true,
  //      "_rcaTxReqEnabled" : false,
  //      "_rcaTxReqPolarity" : true,
  //      "_timeout" : 20,
  //      "_txAllowed" : true,
  //      "_txDelay" : 30,
  //      "_tx1Delay" : 40,
  //      "_tx1Enabled" : false,
  //      "_tx2Delay" : 50,
  //      "_tx2Enabled" : true,
  //      "_tx3Delay" : 60,
  //      "_tx3Enabled" : false
  //    }
  //    """
  //    do {
  //      try radio!.interlock.restore(from: json)
  //
  //      XCTAssertEqual(radio!.interlock.accTxDelay, 10, "accTxDelay", file: #function)
  //      XCTAssertEqual(radio!.interlock.accTxEnabled, true, "accTxEnabled", file: #function)
  //      XCTAssertEqual(radio!.interlock.accTxReqEnabled, false, "accTxReqEnabled", file: #function)
  //      XCTAssertEqual(radio!.interlock.accTxReqPolarity, true, "accTxReqPolarity", file: #function)
  //      XCTAssertEqual(radio!.interlock.rcaTxReqEnabled, false, "rcaTxReqEnabled", file: #function)
  //      XCTAssertEqual(radio!.interlock.rcaTxReqPolarity, true, "rcaTxReqPolarity", file: #function)
  //      XCTAssertEqual(radio!.interlock.timeout, 20, "timeout", file: #function)
  //      XCTAssertEqual(radio!.interlock.txAllowed, true, "txAllowed", file: #function)
  //      XCTAssertEqual(radio!.interlock.txDelay, 30, "txDelay", file: #function)
  //      XCTAssertEqual(radio!.interlock.tx1Delay, 40, "tx1Delay", file: #function)
  //      XCTAssertEqual(radio!.interlock.tx1Enabled, false, "tx1Enabled", file: #function)
  //      XCTAssertEqual(radio!.interlock.tx2Delay, 50, "tx2Delay", file: #function)
  //      XCTAssertEqual(radio!.interlock.tx2Enabled, true, "tx2Enabled", file: #function)
  //      XCTAssertEqual(radio!.interlock.tx3Delay, 60, "tx3Delay", file: #function)
  //      XCTAssertEqual(radio!.interlock.tx3Enabled, false, "tx3Enabled", file: #function)
  //
  //    } catch {
  //      print(error.localizedDescription)
  //      XCTFail("----->>>>> Interlock import FAILED <<<<<-----", file: #function)
  //    }
  //    disconnect()
  //  }
  //
  ////  func testTransmitExport() {
  ////    let type = "Transmit"
  ////
  ////    Swift.print("\n-------------------- \(#function) --------------------\n")
  ////
  ////    let radio = discoverRadio(logState: .limited(to: [type + ".swift"]))
  ////    guard radio != nil else { return }
  ////
  ////    do {
  ////      let json = try radio?.transmit.export()
  ////      Swift.print(json!)
  ////
  ////    } catch {
  ////      print(error.localizedDescription)
  ////      XCTFail("----->>>>> Transmit export FAILED <<<<<-----", file: #function)
  ////    }
  ////    disconnect()
  ////  }
  //
  ////  func testTransmitImport() {
  ////    let type = "Transmit"
  ////
  ////    Swift.print("\n-------------------- \(#function) --------------------\n")
  ////
  ////    let radio = discoverRadio(logState: .limited(to: [type + ".swift"]))
  ////    guard radio != nil else { return }
  ////
  ////    let json =
  ////    """
  ////    {
  ////      "_hwAlcEnabled" : true,
  ////      "_tunePower" : 6,
  ////      "_rfPower" : 87
  ////    }
  ////    """
  ////    do {
  ////      try radio!.transmit.restore(from: json)
  ////
  ////      XCTAssertEqual(radio!.transmit.hwAlcEnabled, true, "hwAlcEnabled", file: #function)
  ////      XCTAssertEqual(radio!.transmit.tunePower, 6, "tunePower", file: #function)
  ////      XCTAssertEqual(radio!.transmit.rfPower, 87, "rfPower", file: #function)
  ////
  ////    } catch {
  ////      print(error.localizedDescription)
  ////      XCTFail("----->>>>> Transmit import FAILED <<<<<-----", file: #function)
  ////    }
  ////    disconnect()
  ////  }
