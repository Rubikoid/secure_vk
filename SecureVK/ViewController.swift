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
		print("Window loaded")
	}
}

class LoginViewController: NSViewController {
	
	@IBOutlet var loginView: NSView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("View login loaded")
		// Do any additional setup after loading the view.
	}
	
	override var representedObject: Any? {
		didSet {
			
		}
	}
	
	@IBAction func login(_ sender: AnyObject) {
		if !storadge.isToken() {
			VK.logIn()
			print("SwiftyVK: Login")
		}
	}
}
