//
//  iOSUtils.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

// The version of iOS
let iOSVersion = NSFoundationVersionNumber

// The iPhone version
let iPhoneVersion = UIDevice.current.model

// The current version number of the app
let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"

// The current build number of the app
let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"