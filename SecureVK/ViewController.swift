//
//  ViewController.swift
//  SecureVK
//
//  Created by Rubikoid on 01.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Cocoa
import SwiftyVK

class WinCont: NSWindowController
{
	override func windowDidLoad() {
		storadge.setWindowController(self)
		storadge.setStoryBoard(self.storyboard!)
		Log.put("Loading status","Window loaded")
	}
}

class LoginViewController: NSViewController {
	
	@IBOutlet var loginView: NSView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		Log.put("Loading status","View login loaded")
		// Do any additional setup after loading the view.
	}
	
	override var representedObject: Any? {
		didSet {
			
		}
	}
	
	@IBAction func login(_ sender: AnyObject) {
		if !storadge.isToken() {
			VK.logIn()
			Log.put("VK","Login button")
		}
	}
}
