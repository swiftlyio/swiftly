import Foundation
import Vapor
import HTTP

public protocol SwiftlyFunctionController {
    static func defineFunctions(context: Swiftly)
}

public final class Swiftly {
    
    private let drop: Droplet
    private var functions: [String: RequestResponseBlock] = [:]
    
    public typealias RequestResponseBlock = (Request) throws -> ResponseRepresentable
    
    public init() throws {
        self.drop = try Droplet()
    }
    
    public func define(_ name: String, block: @escaping RequestResponseBlock) {
        guard self.functions[name] == nil else {
            fatalError("Function already defined: \(name)")
        }
        
        self.functions[name] = block
    }
    
    public func performFunction(_ request: Request) throws -> ResponseRepresentable {
        let name = try request.parameters.next(String.self)
        
        guard let function = self.functions[name] else {
            throw Abort.badRequest
        }
        
        return try function(request)
    }
    
    public func register(controller: SwiftlyFunctionController.Type) {
        controller.defineFunctions(context: self)
    }
    
    public func request(uri: String, method: String, query: [String: Any]? = nil, json: JSON? = nil, headers: [String: String]? = nil) throws -> Response  {
        let request = Request(method: HTTP.Method(method), uri: uri)
        request.json = json
        
        if let _query = query {
            request.query = try Node(node: _query)
        }
        
        if let _headers = headers {
            var h: [HeaderKey: String] = [:]
            
            for (k, v) in _headers {
                h[HeaderKey(k)] = v
            }
            
            request.headers = h
        }
        
        return try self.drop.client.respond(to: request)
    }
    
    public func run() throws {
        self.drop.post("functions", String.parameter) { (req) -> ResponseRepresentable in
            return try self.performFunction(req)
        }
        
        self.drop.get("functions") { (req) -> ResponseRepresentable in
            var json = JSON()
            
            try json.set("functions", Array(self.functions.keys))
            
            return json
        }
        
        
        try self.drop.run()
    }
}
