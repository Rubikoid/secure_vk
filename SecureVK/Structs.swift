//
//  Structs.swift
//  SecureVK
//
//  Created by Rubikoid on 07.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyVK

struct IM
{
	var title: String
	var id: Int
	var img: NSImage
	var ignore: Bool
	var unread: Bool
	var last: String = ""
	var messages: [Message] {
		mutating get {
			if self.messages_.count > 0 {
				return self.messages_
			}
			else {
				var selfIndex = -1
				selfIndex = storadge.IMs.index(where: { $0.id == self.id })!
				worker.getMessagesHistory([VK.Arg.peerId: String(self.id), VK.Arg.count: "20"], IMID: selfIndex)
				return self.messages_
			}
		}
		
		set {
			self.messages_ = newValue
		}
	}
	fileprivate var messages_: [Message]
	
	init() {
		title = "Default title"
		img = NSImage()
		ignore = false
		unread = false
		messages_ = [Message]()
		id = -1
	}
	init(title_: String, id_: Int) {
		title = title_
		img = NSImage()
		ignore = false
		unread = false
		messages_ = [Message]()
		id = id_
	}
	init(title_: String, _: String, id_: Int) {
		title = title_
		img = NSImage()
		ignore = false
		unread = false
		messages_ = [Message]()
		id = id_
	}
}

struct Message
{
	var id: Int = -1
	var user_id: Int = -1
	var date: Int = -1
	var body: String = ""
	var read_state: Int = -1
	var out: Int = -1
	
	init(){ }
	
	init(_ res: JSON) {
		id = res["id"].int!
		user_id = res["user_id"].int!
		body = res["body"].string!
		date = res["date"].int!
		out = res["out"].int!
		read_state = res["read_state"].int!
		if body.contains("RUBIVK_") && body.contains("_VKRUBI") {
			body = body.replacingOccurrences(of: "RUBIVK_", with: "")
			body = body.replacingOccurrences(of: "_VKRUBI", with: "")
			body = storadge.secure.decrypt(body) ?? "_decryption error_"
		}
	}
}


//синхронные запросы
extension URLSession {
	func synchronousDataTaskWithURL(_ url: URL) -> (Data?, URLResponse?, NSError?) {
		var data: Data?, response: URLResponse?, error: NSError?
		
		let semaphore = DispatchSemaphore(value: 0)
		
		dataTask(with: url, completionHandler: {
			data = $0; response = $1; error = $2 as NSError?
			semaphore.signal()
			}) .resume()
		
		let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
		
		return (data, response, error)
	}
}
//*синхронные запросы
