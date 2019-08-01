//
//  Message.swift
//  SocketClient
//
//  Created by David Thorn on 01.08.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public struct Message: Codable {
    public let code: MessageType
    public let message: Data
    public let packetLength: Int
    public init(code: MessageType , message: Data, packetLength: Int) {
        self.code = code
        self.message = message
        self.packetLength = packetLength
    }
    public var data: Data {
        return try! JSONEncoder.init().encode(self)
    }
}
