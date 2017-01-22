//
//  MessVIewController.swift
//  SecureVK
//
//  Created by Rubikoid on 07.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Foundation
import SwiftyVK
import Cocoa

class MessVeiwContoller: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{
	@IBOutlet weak var textField: NSTextField!
	@IBOutlet weak var messageTableView: NSTableView!
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var isEncrypted: NSButton!
	var sizes: [Int: CGFloat] = [Int: CGFloat]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		storadge.setMessagesTableView(messageTableView!)
		// Do any additional setup after loading the view.
	}
	
	override var representedObject: Any? {
		didSet {
			
		}
	}
	
	@IBAction func enter(_ sender: AnyObject) {
		if storadge.selectedIM >= 0 && VK.LP.isActive {
			var message = self.textField.stringValue
			if self.isEncrypted.state == 1 {
				message = storadge.secure.encrypt(message) ?? "_encryption error_"
				message = "RUBIVK_"+message+"_VKRUBI"
				Log.put("Messages",message)
			}
			var req = VK.API.Messages.send([
				VK.Arg.peerId: String(storadge.IMs[storadge.selectedIM].id),
				VK.Arg.message: message
				])
			req.httpMethod = .POST
			req.send()
			self.textField.stringValue = ""
		}
		else
		{
			Log.put("Error","IM not selected or LongPoll not active")
		}
	}
	
	@IBAction func check(_ sender: NSButton) {

	}
	
	func tableViewColumnDidResize(_ notification: Notification) {
		let visibleRows: NSRange = self.messageTableView.rows(in: self.scrollView.contentView.bounds)
		messageTableView.noteHeightOfRows(withIndexesChanged: IndexSet(integersIn: visibleRows.toRange() ?? 0..<0))
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let result: MessageList = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! MessageList
		let next = storadge.IMs[storadge.selectedIM].messages[row]
		result.message.stringValue = next.body
		
		if next.out == 1 { result.senderName.stringValue = storadge.users[storadge.currentUserID]?.toString() ?? "_USR_NOT_FOUND_"}
		else { result.senderName.stringValue = storadge.users[next.user_id]?.toString() ?? "_USR_NOT_FOUND_" }
		//print("\(next.body): \(result.message.intrinsicContentSize):\(test(result.message)), \(result.myMessage.intrinsicContentSize):\(test(result.myMessage))")
		return result
	}
	
	//жутко говнокодная функция, ибо надо считать размеры и в appkit'e нету нормальных средств для автоматического выставления размера, тут это через жопу ;(
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		var ret: Double = 0.0
		/*	let oneSymbolSize = 15.0, oneLineSize = 23.0
			let currentWidth = self.scrollView.contentSize.width
			let message: String = storadge.IMs[storadge.selectedIM].messages[row].body
			if (Double(message.characters.count)*oneSymbolSize)/Double(currentWidth) < 1 {
				ret = oneLineSize
			}
			else {
				ret = Double(Int((Double(message.characters.count)*oneSymbolSize)/Double(currentWidth))) * oneLineSize
			}
		Из-за изменения способа отображения сообщений эта херня больше не будет работать по старому и плохому методу.
		*/
		let result: MessageList = tableView.make(withIdentifier: "collIdentify", owner: self) as! MessageList
		result.message.stringValue = storadge.IMs[storadge.selectedIM].messages[row].body
		ret = Double(test(result.message).height) + 6.0 + 17.0
		self.sizes.updateValue(CGFloat(ret), forKey: row)
		return CGFloat(ret)
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return storadge.selectedIM == -1 ? 0 : storadge.IMs[storadge.selectedIM].messages.count
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		return true
	}
	
	func scrollToEnd() {
		self.scrollView.contentView.scroll(to: NSPoint(x: 0.0, y: NSMaxY((self.scrollView.documentView?.frame)!)-self.scrollView.contentView.bounds.size.height))
		self.scrollView.verticalScroller?.floatValue = 1
	}
	
	func test(_ textField: NSTextField) -> NSSize
	{
		let width = self.messageTableView.bounds.width - 6.0//textField.bounds.width
		let cell = textField.cell! as NSCell
		let rect = cell.drawingRect(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), width, CGFloat(CGFloat.greatestFiniteMagnitude)))
		let size = cell.cellSize(forBounds: rect)
		return size
	}
	
	
}

class MessageList: NSTableCellView {
	@IBOutlet weak var senderName: NSTextField!
	@IBOutlet weak var message: NSTextField!
}
