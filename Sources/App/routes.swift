/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Routing
import Vapor
import WebSocket
import Foundation

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyonnd a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
let sessionManager = TrackingSessionManager()

public func routes(_ router: Router) throws {
  
  // MARK: Status Checks
  
  router.get("status") { _ in "ok \(Date())" }
  router.get("word-test") { request in
        return wordKey(with: request)
    }
    router.post("create", use: sessionManager.createTrackingSession)
    router.post("close", TrackingSession.parameter) {
        req -> HTTPStatus in
        let session = try req.parameters.next(TrackingSession.self)
        sessionManager.close(session)
        return .ok
    }
    router.post("update", TrackingSession.parameter) {
        req -> Future<HTTPStatus> in
        // 2
        let session = try req.parameters.next(TrackingSession.self)
        // 3
        return try Location.decode(from: req)
            // 4
            .map(to: HTTPStatus.self) { location in
                sessionManager.update(location, for: session)
                return .ok }
    }
    
}
