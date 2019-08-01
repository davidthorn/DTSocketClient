//
//  InputStreamReader.swift
//  SocketClient
//
//  Created by David Thorn on 01.08.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public struct InputStreamReader {
    
    internal var stream: InputStream
    
    public init(stream: InputStream ) {
        self.stream = stream
    }
    
    public func read(readLength: Int = 4096 ) -> Data {
        let readBytesLength = readLength
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: readBytesLength)
        var totalBytes = 0
        
        //2
        while stream.hasBytesAvailable {
            
            //3
            let numberOfBytesRead = stream.read(buffer, maxLength: readBytesLength)
            
            //4
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            
            totalBytes += numberOfBytesRead
            // Construct the Message object
        }
        
        let data = Data.init(bytes: buffer, count: totalBytes)
        
        return data
    }
    
}
