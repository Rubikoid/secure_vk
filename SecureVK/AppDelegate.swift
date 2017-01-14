//
//  AppDelegate.swift
//  SecureVK
//
//  Created by Rubikoid on 03.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet weak var loginStatus: NSMenuItem!
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Log.put("Loading status","App loaded")
		storadge.vkDelegate = MessengDeleg()
		storadge.setAppDelegate(self)
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

