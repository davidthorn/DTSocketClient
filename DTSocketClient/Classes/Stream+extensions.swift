//
//  Stream+extensions.swift
//  SocketClient
//
//  Created by David Thorn on 01.08.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

extension Stream {
    
    public var type: StreamType {
        switch self {
        case is InputStream: return .input
        case is OutputStream: return .output
        default: fatalError("No other types of streams")
        }
    }
    
    public var reader: InputStreamReader {
        guard let inputStream = self as? InputStream else {
            fatalError("Reader should only be called on an input stream")
        }
        return InputStreamReader.init(stream: inputStream)
    }
    
    public func onError(completion: (_ error: Error , _ type: StreamType) -> Void) {
        guard let error = self.streamError else { return }
        completion(error , self.type)
    }
    
    public func onData(completion: (_ data: Data) -> Void) {
        switch self.type {
        case .input:
            guard let inputStream = self as? InputStream else { return }
            switch inputStream.hasBytesAvailable {
            case true:
                completion(inputStream.reader.read())
            case false: break
            }
            
        default: break
        }
    }
    
    public func write(data: Data , completion: (_ bytesWritten: Int) -> Void) {
        
        guard let output = self as? OutputStream else {
            fatalError("This method should only be called on an output stream")
        }
        
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return
            }
            
            var bytesSent = 0
            repeat {
                let result = output.write(pointer + bytesSent, maxLength: data.count - bytesSent)
                print("bytes written: \(result)")
                bytesSent += result
            } while bytesSent < data.count
            
            completion(bytesSent)
        }
        
        
        
        
    }
    
}
