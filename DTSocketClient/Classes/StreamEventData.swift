//
//  StreamEventData.swift
//  SocketClient
//
//  Created by David Thorn on 01.08.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public enum StreamEventData {
    
    case endEncountered
    case errorOccurred
    case hasBytesAvailable
    case hasSpaceAvailable
    case openCompleted
    
    public init(rawValue: Stream.Event) {
        switch rawValue {
        case Stream.Event.endEncountered: self = .endEncountered
        case Stream.Event.errorOccurred: self = .errorOccurred
        case Stream.Event.hasBytesAvailable: self = .hasBytesAvailable
        case Stream.Event.hasSpaceAvailable: self = .hasSpaceAvailable
        case Stream.Event.openCompleted: self = .openCompleted
        default: fatalError("Incompatiable type")
        }
    }
    
}
