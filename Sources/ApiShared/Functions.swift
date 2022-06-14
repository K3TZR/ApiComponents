//
//  Functions.swift
//  UtilityComponents/Shared
//
//  Created by Douglas Adams on 5/16/22.
//

import Foundation

// ----------------------------------------------------------------------------
// MARK: - Functions

public func getBundleInfo() -> (domain: String, appName: String) {
  let bundleIdentifier = Bundle.main.bundleIdentifier ?? "net.k3tzr.XCGWrapper"
  let separator = bundleIdentifier.lastIndex(of: ".")!
  let appName = String(bundleIdentifier.suffix(from: bundleIdentifier.index(separator, offsetBy: 1)))
  let domain = String(bundleIdentifier.prefix(upTo: separator))
  return (domain, appName)
}

public func setupLogFolder(_ info: (domain: String, appName: String)) -> URL? {
  func createAsNeeded(_ folder: String) -> URL? {
    let fileManager = FileManager.default
    let folderUrl = URL.appSupport.appendingPathComponent( folder )
    // try to create it
    do {
      try fileManager.createDirectory( at: folderUrl, withIntermediateDirectories: true, attributes: nil)
    } catch {
      return nil
    }
    return folderUrl
  }

  return createAsNeeded(info.domain + "." + info.appName + "/Logs")
}

public func log(_ msg: String, _ level: LogLevel, _ function: StaticString, _ file: StaticString, _ line: Int) {
  NotificationCenter.default.post(name: logEntryNotification, object: LogEntry(msg, level, function, file, line))
  if level == .warning || level == .error {
    NotificationCenter.default.post(name: logAlertNotification, object: LogEntry(msg, level, function, file, line))
  }
}
