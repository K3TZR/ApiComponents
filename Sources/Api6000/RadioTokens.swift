//
//  RadioTokens.swift
//  Api6000Components/Api6000
//
//  Created by Douglas Adams on 1/21/22.
//

import Foundation

extension Radio {
  // ----------------------------------------------------------------------------
  // MARK: - Parse tokens

  enum ConnectionToken: String {
      case clientId                 = "client_id"
      case localPttEnabled          = "local_ptt"
      case program
      case station
  }
  enum DisconnectionToken: String {
      case duplicateClientId        = "duplicate_client_id"
      case forced
      case wanValidationFailed      = "wan_validation_failed"
  }
  enum DisplayToken: String {
      case panadapter               = "pan"
      case waterfall
  }
  enum FilterSharpnessToken: String {
    case cw
    case digital
    case voice
    case autoLevel                = "auto_level"
    case level
  }
  enum InfoToken: String {
    case atuPresent               = "atu_present"
    case callsign
    case chassisSerial            = "chassis_serial"
    case gateway
    case gps
    case ipAddress                = "ip"
    case location
    case macAddress               = "mac"
    case model
    case netmask
    case name
    case numberOfScus             = "num_scu"
    case numberOfSlices           = "num_slice"
    case numberOfTx               = "num_tx"
    case options
    case region
    case screensaver
    case softwareVersion          = "software_ver"
  }
  enum StatusToken: String {
    case amplifier
    case atu
    case client
    case cwx
    case display
    case eq
    case file
    case gps
    case interlock
    case memory
    case meter
    case mixer
    case profile
    case radio
    case slice
    case stream
    case tnf
    case transmit
    case turf
    case usbCable                 = "usb_cable"
    case wan
    case waveform
    case xvtr
  }
  enum OscillatorToken: String {
    case extPresent               = "ext_present"
    case gpsdoPresent             = "gpsdo_present"
    case locked
    case setting
    case state
    case tcxoPresent              = "tcxo_present"
  }
  enum RadioSubToken: String {
    case filterSharpness          = "filter_sharpness"
    case staticNetParams          = "static_net_params"
    case oscillator
  }
  enum RadioToken: String {
    case backlight
    case bandPersistenceEnabled   = "band_persistence_enabled"
    case binauralRxEnabled        = "binaural_rx"
    case calFreq                  = "cal_freq"
    case callsign
    case daxIqAvailable           = "daxiq_available"
    case daxIqCapacity            = "daxiq_capacity"
    case enforcePrivateIpEnabled  = "enforce_private_ip_connections"
    case freqErrorPpb             = "freq_error_ppb"
    case frontSpeakerMute         = "front_speaker_mute"
    case fullDuplexEnabled        = "full_duplex_enabled"
    case headphoneGain            = "headphone_gain"
    case headphoneMute            = "headphone_mute"
    case lineoutGain              = "lineout_gain"
    case lineoutMute              = "lineout_mute"
    case muteLocalAudio           = "mute_local_audio_when_remote"
    case nickname
    case panadapters
    case pllDone                  = "pll_done"
    case radioAuthenticated       = "radio_authenticated"
    case remoteOnEnabled          = "remote_on_enabled"
    case rttyMark                 = "rtty_mark_default"
    case serverConnected          = "server_connected"
    case slices
    case snapTuneEnabled          = "snap_tune_enabled"
    case tnfsEnabled              = "tnf_enabled"
  }
  enum StaticNetToken: String {
    case gateway
    case ip
    case netmask
  }
  enum VersionToken: String {
    case fpgaMb                   = "fpga-mb"
    case psocMbPa100              = "psoc-mbpa100"
    case psocMbTrx                = "psoc-mbtrx"
    case smartSdrMB               = "smartsdr-mb"
    case picDecpu                 = "pic-decpu"
  }

}
