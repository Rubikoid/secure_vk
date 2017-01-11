//
//  AppStoradge.swift
//  SecureVK
//
//  Created by Rubikoid on 07.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyVK

class AppStoradge {
	fileprivate var loaded: Bool
	fileprivate var vkToken: Bool
	internal var appDeleg: AppDelegate?
	internal var window: WinCont?
	internal var storyboard: NSStoryboard?
	internal var IMTableView: NSTableView?
	internal var messagesTableView: NSTableView?
	internal var IMs: [IM]
	internal var selectedIM: Int = -1
	internal var currentUserID: Int = -1
	internal var secure: Crypto = Crypto()
 
	init() {
		self.loaded = false
		self.vkToken = false
		
		self.appDeleg = nil
		self.window = nil
		self.storyboard = nil
		self.IMTableView = nil
		
		self.IMs = [IM]()
	}
	
	func setAppDelegate(_ AppDeleg_: AppDelegate) {
		self.loaded = true
		self.appDeleg = AppDeleg_
	}
	
	func setWindowController(_ window_: WinCont) { self.window = window_ }
	
	func setStoryBoard(_ storyboard_: NSStoryboard) { self.storyboard = storyboard_ }
	
	func setTableView(_ table_: NSTableView) { self.IMTableView = table_ }
	
	func setMessagesTableView(_ table_: NSTableView) { self.messagesTableView = table_ }
	
	func isToken() -> Bool { return self.vkToken }
	
	func isLoaded() -> Bool { return self.loaded }
	
	func loadChange(_ state: Bool) { self.loaded = state }
	
	func tokChange(_ state: Bool) {
		self.vkToken = state
		worker.TokenChanged(state)
	}
	
	func IMsSet(_ IMs_: [IM]) {
		self.IMs = IMs_
		self.IMTableUpdate()
	}
	
	func IMsUpdate(_ IMa: IM) {
		self.IMs.append(IMa)
		self.IMTableUpdate()
	}
	
	func IMTableUpdate() {
		DispatchQueue.main.async { self.IMTableView?.reloadData() }
	}
	
	func messageTableUpdate() {
		DispatchQueue.main.async {
			storadge.messagesTableView?.reloadData()
			(storadge.messagesTableView?.delegate as! MessVeiwContoller).scrollToEnd()
		}
	}
}
