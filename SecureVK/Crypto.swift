//
//  Secure.swift
//  SecureVK
//
//  Created by Rubikoid on 11.01.17.
//  Copyright © 2017 Rubikoid. All rights reserved.
//

import Foundation
import CryptoSwift
import SwiftyVK

class Crypto {
	var aes: AES? = nil
	
	init (key: String = "PasswordPassword", iv: String = "SecretStringIVIV") {
		do {
			try self.aes = AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7())
		}
		catch {
			self.aes = nil
			Log.put("Error","AES init error: \(error)")
		}
	}
	
	func encrypt(_ data: String) -> String? {
		do {
			let ret: String? = try self.aes?.encrypt(Array(data.utf8)).toBase64()?.toBase64()
			return ret
		}
		catch {
			Log.put("Error","encrypt error: \(error)")
		}
		return nil
	}
	
	func decrypt(_ data: String) -> String? {
		do {
			let dataArray0 = Data(base64Encoded: data)
			if let unDataArray0 = dataArray0, let dataArray1 = Data(base64Encoded: unDataArray0) {//TODO: сделать нормально этот говнокод
				let decrypted = try self.aes?.decrypt(dataArray1)
				if let decry = decrypted {
					let ret: String? = String(bytes: decry, encoding: String.Encoding.utf8)
					return ret
				}
			}
		}
		catch {
			Log.put("Error","decrypt error: \(error)") //О господи, эта херня походу работает
		}
		return nil
	}
}

extension String {
	
	func fromBase64() -> String? {
		guard let data = Data(base64Encoded: self) else {
			return nil
		}
		
		return String(data: data, encoding: .utf8)
	}
	
	func toBase64() -> String {
		return Data(self.utf8).base64EncodedString()
	}
}
