//
//  MainView.swift
//  SecureVK
//
//  Created by Rubikoid on 03.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Cocoa
import SwiftyVK

class SplitView: NSSplitViewController {

	@IBOutlet weak var mainView: NSSplitView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.mainView.delegate = self
		//print(self)
		//print(self.splitViewItems)
        // Do view setup here.
    }
}

class IMList: NSTableCellView {
	@IBOutlet weak var name: NSTextField!
	@IBOutlet weak var message: NSTextField!
}

class IMViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
	
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var IMTableView: NSTableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		storadge.setTableView(IMTableView!)
		if storadge.isToken() {	worker.IMsLoad() }
		// Do any additional setup after loading the view.
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let result: IMList = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! IMList
		let next = storadge.IMs[row]
		result.name.stringValue = next.title
		result.message.stringValue = next.last
		return result
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		storadge.selectedIM = row
		(storadge.messagesTableView?.delegate as! MessVeiwContoller).sizes.removeAll()
		storadge.messageTableUpdate()
		return true
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return storadge.IMs.count
	}
}
