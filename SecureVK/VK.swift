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
	init() {
		
	}
	
	func IMsLoad()
	{
		self.getCurrentUserID()
		let req = VK.API.Messages.getDialogs()
		req.send(onSuccess: {resp in
					for i in 0..<resp["items"].count
					{
						self.IMPrepare(resp["items"][i]["message"], id: i, maxID: resp["items"].count)
					}
					print("load ims end")
				},
				onError: {resp in print(resp)}
		)
	}
	
	//Старая функция подгрузки диалогов+сообщений
	/*func IMsLoad() {
		let req = VK.API.Messages.getDialogs()
		req.successBlock = { resp in
			let items = resp["items"]
			for i in 0..<20 {
				let mess = items[i]["message"]
				let historyReq = VK.API.Messages.getHistory([VK.Arg.peerId: String(mess["chat_id"].int), VK.Arg.count: "20"])
				historyReq.successBlock = {resp in
					var next = IM()
					if mess["chat_id"].int != nil {
						next.title = mess["title"].stringValue;
						next.id = mess["chat_id"].int! + 2000000000
					}
					else {
						let usr = self.userGet(mess["user_id"].stringValue)[0] //синхронный http get запрос по users.get, ибо swiftyvk жестоко тормозит
						next.title = usr["first_name"].stringValue + " " + usr["last_name"].stringValue
						next.id = mess["user_id"].int!
					}
					var j = resp["items"].array!.count - 1
					while j>=0 {
						var nextMessage: Message = Message()
						let res = resp["items"][j]
						nextMessage.id = res["id"].int!
						nextMessage.user_id = res["user_id"].int!
						nextMessage.body = res["body"].string!
						nextMessage.date = res["date"].int!
						nextMessage.out = res["out"].int!
						nextMessage.read_state = res["read_state"].int!
						next.messages.append(nextMessage)
						j -= 1
					}
					print(i)
				}
				historyReq.errorBlock = {err in print(err)}
				historyReq.send()
			}
		}
		req.errorBlock = {resp in storadge.IMsSet([IM(title_: String(resp.code),id_: -1)])}
		req.send()
	}*/
	
	func getCurrentUserID() {
		let userIdGet = VK.API.Users.get()
		userIdGet.send(onSuccess: {resp in storadge.currentUserID = resp[0]["id"].int!},
		               onError: {err in storadge.currentUserID = -1; print(err)})
	}
	
	func TokenChanged(_ state: Bool) {
		storadge.appDeleg?.loginStatus.state = state ? 1 : 0
		let view = state ? storadge.storyboard?.instantiateController(withIdentifier: "MainWind") as? NSViewController : storadge.storyboard?.instantiateController(withIdentifier: "LoginWind") as? NSViewController
		DispatchQueue.main.async { storadge.window?.contentViewController = view }
		VK.LP.start()
		NotificationCenter.default.addObserver(self, selector: #selector(self.newMessage), name: NSNotification.Name(rawValue: VK.LP.notifications.type4), object: nil)
	}
	
	func IMPrepare(_ dialog: JSON, id: Int, maxID: Int) {
		var next = IM()
		if dialog["chat_id"].int != nil {
			next.title = dialog["title"].stringValue;
			next.id = dialog["chat_id"].int! + 2000000000
		}
		else {
			let usr = self.userGet(dialog["user_id"].stringValue)[0] //синхронный http get запрос по users.get, ибо swiftyvk жестоко тормозит
			next.title = usr["first_name"].stringValue + " " + usr["last_name"].stringValue
			next.id = dialog["user_id"].int!
		}
		next.last = dialog["body"].string!
		storadge.IMs.append(next)
		if maxID - 1 == id
		{
			storadge.IMTableUpdate()
		}
	}
	
	func userGet(_ id: String) -> JSON {
		let url: URL = URL(string: "https://api.vk.com/method/users.get?user_ids="+id+"&v=5.60")!
		let (data, _, _) = URLSession.shared.synchronousDataTaskWithURL(url)
		let jsonResult = JSON(data: data!)
		return jsonResult["response"]
	}
	
	func getMessagesHistory(_ vkarg: [VK.Arg: String], IMID: Int){
		let req = VK.API.Messages.getHistory(vkarg)
		req.asynchronous = false
		req.catchErrors = false
		req.send(
			onSuccess: {resp in
				var ret: [Message] = [Message]()
				var i = resp["items"].array!.count - 1
				while i>=0 {
					let res = resp["items"][i]
					ret.append(Message(res))
					i -= 1
				}
				storadge.IMs[IMID].messages = ret
			},
			onError: {err in print(err)}
		)
	}
	
	@objc func newMessage(_ notif: Notification) {
		print("geted new message")
		let json = (notif.object! as! JSONWrapper).unwrap
		let req = VK.API.Messages.getById([VK.Arg.messageIds: String(json[0][1].int!)])
		req.send(onSuccess: {resp in
			let res = resp["items"][0]
			let next: Message = Message(res)
			let uid = json[0][3].int!
			let id = storadge.IMs.index(where: {$0.id == uid})!
			storadge.IMs[id].last = next.body
			storadge.IMs[id].messages.append(next)
			storadge.IMTableUpdate()
			storadge.messageTableUpdate()
			print("loaded new message")
		},
		         onError: {err in print(err)}
		)
	}
}
