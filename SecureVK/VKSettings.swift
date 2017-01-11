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
	let scope: [VK.Scope] = [VK.Scope.messages,.offline,.friends,.wall,.audio,.email]
	let window: AnyObject
	
	init(window_: AnyObject) {
		self.window = window_
		VK.configure(appID: appID, delegate: self)
	}
	
	func vkWillAuthorize() -> [VK.Scope] { return self.scope }
	
	func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {
		storadge.tokChange(true)
		print("Token loaded")
		//print(parameters)
	}
	
	func vkDidUnauthorize() {
		print("Token deleted: user log out")
		storadge.tokChange(false)
	}
	
	func vkAutorizationFailedWith(error: VK.Error) { print("Autorization failed with error: \n\(error)") }
	
	func vkShouldUseTokenPath() -> String? {
		return nil
	}
	
	func vkWillPresentView() -> NSWindow? { print("asdasd"); return NSApplication.shared().mainWindow }
}
