//
//  tiny-networking.swift
//
//  Originally from: https://gist.github.com/chriseidhof/26bda788f13b3e8a279c
//
//  Slightly modified to have `apiRequest` return a NSURLSessionTask
//  Also; Failure handler is called if there's an error (even with status 200)
//

import Foundation

// See the accompanying blog post: http://chris.eidhof.nl/posts/tiny-networking-in-swift.html

public enum Method: String { // Bluntly stolen from Alamofire
  case OPTIONS = "OPTIONS"
  case GET = "GET"
  case HEAD = "HEAD"
  case POST = "POST"
  case PUT = "PUT"
  case PATCH = "PATCH"
  case DELETE = "DELETE"
  case TRACE = "TRACE"
  case CONNECT = "CONNECT"
}

public struct Resource<A> {
  let path: String
  let method : Method
  let requestBody: NSData?
  let headers : [String:String]
  let parse: NSData -> A?

  public init(path: String, method: Method, requestBody: NSData?, headers: [String:String], parse: NSData -> A?) {
    self.path = path
    self.method = method
    self.requestBody = requestBody
    self.headers = headers
    self.parse = parse
  }
}

public enum Reason {
  case CouldNotParseJSON
  case NoData
  case NoSuccessStatusCode(statusCode: Int)
  case Other(NSError)
}

public func apiRequest<A>(modifyRequest: NSMutableURLRequest -> (), baseURL: NSURL, resource: Resource<A>, failure: (Reason, NSData?) -> (), completion: A -> ()) -> NSURLSessionTask {
  let session = NSURLSession.sharedSession()
  let url = baseURL.URLByAppendingPathComponent(resource.path)
  let request = NSMutableURLRequest(URL: url)
  request.HTTPMethod = resource.method.rawValue
  request.HTTPBody = resource.requestBody
  modifyRequest(request)
  for (key,value) in resource.headers {
    request.setValue(value, forHTTPHeaderField: key)
  }
  let task = session.dataTaskWithRequest(request){ (data, response, error) -> Void in
    if error != nil {
      failure(Reason.Other(error), data)
      return
    }
    if let httpResponse = response as? NSHTTPURLResponse {
      if httpResponse.statusCode == 200 {
        if let responseData = data {
          if let result = resource.parse(responseData) {
            completion(result)
          } else {
            failure(Reason.CouldNotParseJSON, data)
          }
        } else {
          failure(Reason.NoData, data)
        }
      } else {
        failure(Reason.NoSuccessStatusCode(statusCode: httpResponse.statusCode), data)
      }
    } else {
      failure(Reason.Other(error), data)
    }
  }
  task.resume()

  return task
}

// Here are some convenience functions for dealing with JSON APIs

public typealias JSONDictionary = [String:AnyObject]

public func decodeJSON(data: NSData) -> JSONDictionary? {
  return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? [String:AnyObject]
}
