//
//  MessageType.swift
//  SocketClient
//
//  Created by David Thorn on 01.08.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public enum MessageType: Int, Codable {
    case ping = 0
    case pong = 1
    case message = 10
    case messageReceived = 11
    case broadcast = 100
    
}
