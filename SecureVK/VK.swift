//
//  VK.swift
//  SecureVK
//
//  Created by Rubikoid on 03.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyVK

//*global vars
//Не очень красивое решение проблемы обмена данными между контролами, но...
var storadge: AppStoradge = AppStoradge()
var worker: VKWorker = VKWorker()
//*global vars

class VKWorker
{
	init() { }
	
	func getCurrentUserID() {
		let userIdGet = VK.API.Users.get()
		userIdGet.send(onSuccess: {resp in
			storadge.currentUserID = resp[0]["id"].int!
			storadge.users.updateValue(User(id_: resp[0]["id"].int!, fname_: resp[0]["first_name"].stringValue, lname_: resp[0]["last_name"].stringValue), forKey: resp[0]["id"].int!)
			Log.put("Loading status","User id loaded")
		},
		onError: {err in
			storadge.currentUserID = -1
			Log.put("Error","getCurrentUserID: \(err)")
		})
	}
	
	func TokenChanged(_ state: Bool) {
		storadge.appDeleg?.loginStatus.state = state ? 1 : 0
		let view = state ? storadge.storyboard?.instantiateController(withIdentifier: "MainWind") as? NSViewController : storadge.storyboard?.instantiateController(withIdentifier: "LoginWind") as? NSViewController
		DispatchQueue.main.async { storadge.window?.contentViewController = view }
		NotificationCenter.default.addObserver(self, selector: #selector(self.newMessage), name: VK.LP.notifications.type4, object: nil)
	}
	
	func IMsLoad()
	{
		self.getCurrentUserID()
		let req = VK.API.Messages.getDialogs()
		req.send(onSuccess: {resp in
			for i in 0..<resp["items"].count {
				self.IMPrepare(resp["items"][i]["message"], id: i, maxID: resp["items"].count)
			}
			Log.put("Loading status","Loading IMs end")
			storadge.messagesLoadCurrentRow = 0
			self.messagesGet()
			}, onError: {resp in Log.put("Error","getDialogs: \(resp)")}
		)
	}
	
	func IMPrepare(_ dialog: JSON, id: Int, maxID: Int) {
		var next = IM()
		if dialog["chat_id"].int != nil {
			next.title = dialog["title"].stringValue;
			next.id = dialog["chat_id"].int! + 2000000000
			let req = VK.API.Messages.getChatUsers([VK.Arg.chatId: String(dialog["chat_id"].int!), VK.Arg.fields: "online"])
			req.send(onSuccess: {resp in
				for i in 0..<resp.count {
					if !storadge.users.keys.contains(resp[i]["id"].int!) {
						storadge.users.updateValue(User(id_: resp[i]["id"].int!, fname_: resp[i]["first_name"].stringValue, lname_: resp[i]["last_name"].stringValue), forKey: resp[i]["id"].int!)
					}
				}
			}, onError: {err in Log.put("Error","getChatUsers: \(err)")})
		}
		else {
			let usr = User(id_: dialog["user_id"].int!)
			next.title = usr.toString()
			if !storadge.users.keys.contains(dialog["user_id"].int!) {
				storadge.users.updateValue(usr, forKey: dialog["user_id"].int!)
			}
			next.id = dialog["user_id"].int!
		}
		next.last = dialog["body"].string!
		if next.last.contains("RUBIVK_") && next.last.contains("_VKRUBI") {
			next.last = next.last.replacingOccurrences(of: "RUBIVK_", with: "")
			next.last = next.last.replacingOccurrences(of: "_VKRUBI", with: "")
			next.last = storadge.secure.decrypt(next.last) ?? "_decryption error_"
		}
		storadge.IMs.append(next)
		if maxID - 1 == id {
			storadge.IMTableUpdate()
		}
	}
	func userGet(_ id: String) -> JSON {
		let url: URL = URL(string: "https://api.vk.com/method/users.get?user_ids="+id+"&v=5.60")!
		let (data, _, _) = URLSession.shared.synchronousDataTaskWithURL(url)
		let jsonResult = JSON(data: data!)
		return jsonResult["response"]
	}
	
	func messagesGet() {
		var req = VK.API.Messages.getHistory([VK.Arg.peerId: String(storadge.IMs[storadge.messagesLoadCurrentRow].id), VK.Arg.count: "20"])
		req.next(self.messageWork)
		req.send(onSuccess: {succ in
			storadge.IMs[storadge.messagesLoadCurrentRow].messages = self.messagesParse(resp: succ)
			Log.put("Loading status","Loaind messages end")
			VK.LP.start()
			}, onError: { err in
			if err.localizedDescription.contains("Too many requests per second") {
				if storadge.messagesLoadCurrentRow == storadge.IMs.count - 1 {
					Log.put("Error","Too many requests per second error - to last")
					let req = VK.API.Messages.getHistory([VK.Arg.peerId: String(storadge.IMs[storadge.messagesLoadCurrentRow].id), VK.Arg.count: "20"])
					req.send(onSuccess: {succ in storadge.IMs[storadge.messagesLoadCurrentRow].messages = self.messagesParse(resp: succ); Log.put("Loading status","Loaind messages end"); }, onError: { err in Log.put("Error","restarted messagesGet: \(err)") })
				}
				else {
					Log.put("Error","Too many requests per second error - restart")
					self.messagesGet()
				}
			}
			else { Log.put("Error","messagesGet: \(err)") }
		})
	}
	
	func messageWork(resp: JSON) -> RequestConfig {
		var new_req = VK.API.Messages.getHistory([VK.Arg.peerId: String(storadge.IMs[storadge.messagesLoadCurrentRow+1].id), VK.Arg.count: "20"])
		if storadge.messagesLoadCurrentRow < storadge.IMs.count - 2 { new_req.next(self.messageWork) }
		storadge.IMs[storadge.messagesLoadCurrentRow].messages = self.messagesParse(resp: resp)
		storadge.messagesLoadCurrentRow += 1
		return new_req
	}
	
	func messagesParse(resp: JSON) -> [Message] {
		var ret: [Message] = [Message]()
		var i = resp["items"].array!.count - 1
		while i>=0 {
			let res = resp["items"][i]
			ret.append(Message(res))
			i -= 1
		}
		return ret

	}
	
	func getMessagesHistory(_ vkarg: [VK.Arg: String], IMID: Int, doUpdate: Bool = false) {
		let req = VK.API.Messages.getHistory(vkarg)
		req.send(
			onSuccess: {resp in
				storadge.IMs[IMID].messages = self.messagesParse(resp: resp)
				Log.put("Loading status","Messages for \(storadge.IMs[IMID].title) loaded")
			},
			onError: {err in Log.put("Error","getMessagesHistory: \(err)")}
		)
	}
	
	@objc func newMessage(_ notif: Notification) {
		Log.put("Messages","Recived new message")
		let json = (notif.object! as! JSONWrapper).unwrap
		let req = VK.API.Messages.getById([VK.Arg.messageIds: String(json[0][1].int!)])
		req.send(onSuccess: {resp in
			let res = resp["items"][0]
			let next: Message = Message(res)
			let uid = json[0][3].int!
			let id = storadge.IMs.index(where: {$0.id == uid})! // TODO: Сделать подгрузку диалога при новом сообщении в неподгруженном изначально диалоге
			storadge.IMs[id].last = next.body
			storadge.IMs[id].messages.append(next)
			storadge.IMTableUpdate()
			storadge.messageTableUpdate()
			Log.put("Messages","Processed new message")
		},
		         onError: {err in Log.put("Error","newMessage: \(err)")}
		)
	}
}
