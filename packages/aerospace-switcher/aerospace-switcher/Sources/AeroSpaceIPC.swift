import Foundation

private let socketProtocolVersion: UInt32 = 1

struct AeroSpaceResponse: Decodable {
    let exitCode: Int
    let stdout: String

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        exitCode = try c.decode(Int.self, forKey: .exitCode)
        stdout = (try? c.decode(String.self, forKey: .stdout)) ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case exitCode, stdout
    }
}

private struct ClientRequest: Encodable {
    let args: [String]
    let stdin: String = ""
    let windowId: UInt32?
    let workspace: String?
}

final class AeroSpaceConnection {
    private let handle: FileHandle

    private init(handle: FileHandle) {
        self.handle = handle
    }

    static func connect() -> AeroSpaceConnection? {
        guard let user = ProcessInfo.processInfo.environment["USER"] else { return nil }
        let path = "/tmp/bobko.aerospace-\(user).sock"

        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return nil }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathBytes = path.utf8CString
        guard pathBytes.count <= MemoryLayout.size(ofValue: addr.sun_path) else {
            close(fd)
            return nil
        }
        withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: pathBytes.count) { dest in
                pathBytes.withUnsafeBufferPointer { src in
                    _ = memcpy(dest, src.baseAddress!, src.count)
                }
            }
        }

        let result = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                Foundation.connect(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard result == 0 else {
            close(fd)
            return nil
        }

        let fh = FileHandle(fileDescriptor: fd, closeOnDealloc: true)

        guard writeU32(fh, socketProtocolVersion),
              let serverVersion = readU32(fh),
              serverVersion == socketProtocolVersion else {
            return nil
        }

        return AeroSpaceConnection(handle: fh)
    }

    func send(_ args: [String]) -> AeroSpaceResponse? {
        let windowId = ProcessInfo.processInfo.environment["AEROSPACE_WINDOW_ID"]
            .flatMap { UInt32($0) }
        let workspace = ProcessInfo.processInfo.environment["AEROSPACE_WORKSPACE"]

        let req = ClientRequest(args: args, windowId: windowId, workspace: workspace)
        guard let payload = try? JSONEncoder().encode(req) else { return nil }

        guard Self.writeU32(handle, UInt32(payload.count)) else { return nil }
        handle.write(payload)

        guard let respLen = Self.readU32(handle) else { return nil }
        let respData = handle.readData(ofLength: Int(respLen))
        guard respData.count == Int(respLen) else { return nil }

        return try? JSONDecoder().decode(AeroSpaceResponse.self, from: respData)
    }

    @discardableResult
    func run(_ args: [String]) -> Bool {
        send(args).map { $0.exitCode == 0 } ?? false
    }

    func query(_ args: [String]) -> String? {
        guard let r = send(args), r.exitCode == 0 else { return nil }
        return r.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func writeU32(_ fh: FileHandle, _ value: UInt32) -> Bool {
        var le = value.littleEndian
        let data = Data(bytes: &le, count: 4)
        fh.write(data)
        return true
    }

    private static func readU32(_ fh: FileHandle) -> UInt32? {
        let data = fh.readData(ofLength: 4)
        guard data.count == 4 else { return nil }
        return data.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
    }
}
