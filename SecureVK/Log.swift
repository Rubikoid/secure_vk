//
//  Log.swift
//  SecureVK
//
//  Created by Rubikoid on 14.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Foundation

class Log
{
	static var hist: [String] = [String]()
	static var dict: [String: String] = [String: String]()
	static var logToConsole: Bool = true
	static var logList: [String] = ["Loading status", "Messages"]
	static let form: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = DateFormatter.dateFormat(fromTemplate: "d.M HH:mm:ss", options: 0, locale: Locale.current)
		return f
	}()
	
	static func put(_ key: String, _ message: String) {
		let time = form.string(from: Date())
		dict.updateValue("\(time): \(message)", forKey: key)
		hist.append("\(time): \(key) ~ \(message)")
		if (logToConsole && logList.contains(key)) || key=="Error" { print("\(time): \(key) ~ \(message)") }
	}
	
	static func put(_ message: String) {
		put("Other", message)
	}
}
