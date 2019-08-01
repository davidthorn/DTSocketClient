//
//  SocketClient.swift
//  SocketClient
//
//  Created by David Thorn on 01.08.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public class SocketClient: NSObject, StreamDelegate {
    
    public let host: String
    public let port: Int
    
    internal var inputStream: InputStream!
    internal var outputStream: OutputStream!
    
    internal var onErrorHandler: ((_ error: Error , _ type: StreamType) -> Void)?
    internal var onDataHandler: ((_ data: Data) -> Void)?
    internal var onPongHandler: ((_ data: Data) -> Void)?
    
    public init(host: String , port: Int) {
        self.host = host
        self.port = port
        
        super.init()
    }
    
    public func close() {
        self.outputStream.close()
        self.inputStream.close()
        
        self.inputStream = nil
        self.outputStream = nil
    }
    
    public func open(completion: @escaping (_ connected: Bool) -> Void) {
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           host as CFString,
                                           UInt32(port),
                                           &readStream,
                                           &writeStream)
        
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.open()
        outputStream.open()
        
        /// Wait until the connection is open before calling the completion
        /// handler otherwise the data will not be sent
        DispatchQueue.global(qos: .background).async {
            
            repeat {
                Thread.sleep(forTimeInterval: 0.1)
            } while self.outputStream.streamStatus != .open
            
            DispatchQueue.main.async {
                completion(true)
            }
            
        }
        
    }
    
    /// Stream Delegate Method
    ///
    /// - Parameters:
    ///   - aStream: Stream
    ///   - eventCode: Stream.Event
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch StreamEventData.init(rawValue: eventCode) {
        case .endEncountered:
            print("endEncountered \(aStream.type)")
        case .errorOccurred:
            print("errorOccurred \(aStream.type)")
        case .hasBytesAvailable:
            print("hasBytesAvailable \(aStream.type)")
        case .hasSpaceAvailable:
            print("hasSpaceAvailable \(aStream.type)")
            
        case .openCompleted:
            print("openCompleted \(aStream.type)")
            
        }
        
        aStream.onError { [weak self](error, type) in
            print("received error: \(error.localizedDescription) \(aStream.type)")
            self?.onErrorHandler?(error, type)
        }
        
        aStream.onData {[weak self] (data) in
            
            print("received data: \(data.count) \(aStream.type)")
            
            do {
                let m = try JSONDecoder.init().decode(Message.self, from: data)
                switch m.code {
                case .pong:
                    self?.onPongHandler?(data)
                default:
                    self?.onDataHandler?(data)
                }
            } catch {
                self?.onDataHandler?(data)
            }
        }
        
    }
    
    /// Registers a callback that will be called upon the stream delegate method being called
    /// and there being an error
    ///
    /// - Parameter completion: @escaping (_ error: Error , _ type: StreamType) -> Void
    public func onError(completion: @escaping (_ error: Error , _ type: StreamType) -> Void) {
        self.onErrorHandler = completion
    }
    
    /// Registers a callback that will be called upon the stream delegate method being called
    /// and there is data available
    ///
    /// - Parameter completion: @escaping (_ data: Data) -> Void
    public func onData(completion: @escaping (_ data: Data) -> Void) {
        self.onDataHandler = completion
    }
    
    public func onPong(completion: @escaping (_ data: Data) -> Void) {
        self.onPongHandler = completion
    }
    
    public func write(data: Data , completion: (_ error: Error? , _ bytesWritten: Int) -> Void) {
        
        switch self.outputStream.streamStatus {
        case .open:
            
           // let data1 = "This is my data".data(using: .utf8)!
            self.outputStream.write(data: data) { [weak self](bytes) in
                completion(self?.outputStream.streamError , bytes)
            }
        case .opening:
            print("opening still")
        default:
            completion(nil , -1)
        }
    }
}
