//
//  VKSettings.swift
//  SecureVK
//
//  Created by Rubikoid on 07.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyVK

class MessengDeleg: VKDelegate {

	let appID = "5803474"
	let scope: Set<VK.Scope> = [.messages,.offline,.friends,.wall,.audio,.email]
	
	init() {
		//VK.config.logToConsole = true
		VK.configure(withAppId: appID, delegate: self)
	}
	
	func vkWillAuthorize() -> Set<VK.Scope> { return self.scope }
	
	func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {
		storadge.tokChange(true)
		Log.put("Loading status","Token loaded")
	}
	
	func vkDidUnauthorize() {
		Log.put("Loading status","Token deleted: user log out")
		storadge.tokChange(false)
	}
	
	func vkAutorizationFailedWith(error: AuthError) { Log.put("Error","Autorization failed with error: \n\(error)") }
	
	func vkShouldUseTokenPath() -> String? {
		return nil
	}
	
	func vkWillPresentView() -> NSWindow? { return NSApplication.shared().mainWindow }
}
