//
//  iOSUtils.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

// The version of iOS
let iOSNSFoundationVersion = NSFoundationVersionNumber
let iOSVersion = Version.fromString(UIDevice.current.systemVersion) ?? Version(major: 0, minor: 0, patch: 0)

// The device version
let deviceVersion = UIDevice.current.model

// The current version number of the app
let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"

// The current build number of the app
let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"

// Are we on an iPad?
let oniPad = UIDevice.current.userInterfaceIdiom == .pad
