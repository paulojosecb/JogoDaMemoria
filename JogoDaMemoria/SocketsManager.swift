import UIKit

typealias JSONDictionary = [String : Any]


class SocketManager: NSObject {
    //1
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    var delegate: SocketManagerDelegate?
    //2
    var username = ""
    
    //3
    let maxReadLength = 4096
    
    func setupNetworkCommunication() {
        // 1
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // 2
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "localhost" as CFString,
                                           4000,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
//    func asString(jsonDictionary: JSONDictionary) -> String {
//        do {
//            let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
//            return String(data: data, encoding: String.Encoding.utf8) ?? ""
//        } catch {
//            return ""
//        }
//    }
//
//    func joinChat(username: String) {
//        //1
//        let dict = [
//            "iam": username
//        ]
//
//        let data = asString(jsonDictionary: dict).data(using: .utf8)!
//
//        //2
//        self.username = username
//
//        //3
//        _ = data.withUnsafeBytes {
//            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
//                print("Error joining chat")
//                return
//            }
//            //4
//            outputStream.write(pointer, maxLength: data.count)
//        }
//    }
    
    func send(_ command: Command) {
        let message = "command:\(command.type.rawValue)?value:\(command.value)?player:\(command.player.rawValue)"
        
        let data = message.data(using: .utf8)!
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
//    func send(message: String) {
//        let dict = [
//            "message": username
//        ]
//        
//        let data = asString(jsonDictionary: dict).data(using: .utf8)!
//                
//        _ = data.withUnsafeBytes {
//            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
//                print("Error joining chat")
//                return
//            }
//            outputStream.write(pointer, maxLength: data.count)
//        }
//    }
    
//    func stopChatSession() {
//        inputStream.close()
//        outputStream.close()
//    }
    
}

extension SocketManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("new message received")
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            
            // Construct the message object
            if let command = processedCommandString(buffer: buffer, length: numberOfBytesRead) {
                print(command.type)
                delegate?.didReceived(command)
            }
        }
    }
    
    private func processedCommandString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> Command? {
        //1
        guard
            let stringArray = String(
                bytesNoCopy: buffer,
                length: length,
                encoding: .utf8,
                freeWhenDone: false)?.components(separatedBy: "?"),
            let commandString = stringArray.first,
            let command = CommandType(rawValue: commandString.components(separatedBy: ":").last ?? ""),
            let playerString = stringArray.last,
            let player = GameState.Player(rawValue: playerString.components(separatedBy: ":").last ?? "")
        else {
            print("Count not parse")
            return nil
        }
                
        return Command(type: command, value: stringArray[1], player: player)
    }
}

extension Data {
    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}
