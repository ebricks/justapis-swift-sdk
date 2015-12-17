#JustAPIs Swift SDK

##Overview

Lightweight Swift SDK to connect to a JustAPIs gateway through an iOS client.

##Dependencies

### Development/Production
There are no external dependencies when using this framework in your own project. 

However, this SDK is a Swift dynamic framework, and is written in Swift 2.1 and needs a minimum deployment target of iOS 8.0. 

Some features used in the SDK (i.e. tuples, structs) are not currently available in Objective-C code. If you want to use this framework in an Objective-C app, you'll need to marshall these features through Swift code of your own. 

### Unit Testing
If you want to perform unit tests on this framework, it requires [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs/) in order to mock requests. It's already included as a submodule in this repository, so you can run:

```git submodule update --init``` 

to make it available.

## Introduction

The core features of the SDK are exposed through three simple protocols: `Gateway`, `Request`, and `Response`. 

These basic protocols are defined in `CoreTypes.swift`

A `Gateway` represents your connection to a single JustAPIs server. You can send `Request`s to this gateway, and you'll receive a `Response` through a simple callback closure.

The SDK includes two implementations of `Gateway`:

### CompositedGateway
The composited gateway is built from a few configurable and replacable components.

* A `NetworkAdapter` that accepts a `Request` and sends it out over the network before returning a `Response` or an error. The default NetworkAdapter is `FoundationNetworkAdapter`, which uses NSURLSession. 

If you prefer to use a different communications technique (AFNetworking, Alamofire, background sessions, caching, etc) you can write a simple NetworkAdapter and plug it into CompositedGateway's constructor.

* An optional `RequestPreparer`. A RequestPreparer can modify requests at the gateway level. You might use one to insert a token on certain requests, apply default headers, remap URL's, or serialize body data into a standard format like JSON or form-data.

Two sample `RequestPreparer`s are included in the SDK. `DefaultFieldsRequestPreparer` can apply missing query parameters or header fields to all requests. `RequestPreparerClosureAdapter` allows you to provide a simple closure that does whatever you'd like.

* An optional `ResponseProcessor`. A `ResponseProcessor` can modify a response at the gateway level, before the original response callback is invoked. This provides an opportunity to do logging, handle errors, or parse common response formats like JSON or XML.

Two sample `ResponseProcessor`s are included in the SDK. `JsonResponseProcessor` deserializes the body of all responses using NSJSONSerialization. `ResponsePreparerClosureAdapter` allows you to provide a simple closure that does whatever you'd like.

### JsonGateway

`JsonGateway` is Gateway implementation provided for convenience. It's just a `CompositedGateway` that includes a `JsonResponseProcessor` by default.

##Setup

### Framework Integration

#### Cocoapods

The preferred way to include the SDK in your project is by using [Cocoapods](https://cocoapods.org). 

For the bleeding edge version of this SDK, you can add the following directive to the target definition in your Podfile:

`pod 'JustApisSwiftSDK', :git => 'https://github.com/AnyPresence/justapis-swift-sdk.git'`

Since this SDK is a dynamic framework that uses Swift 2.1, you'll also need to make sure that your Podfile targets iOS 8.0 or higher and is set to use dynamic frameworks:

```ruby
platform :ios 8.0
use_frameworks!
```

The repository includes a basic Demo project that uses Cocoapods. You're encoraged to look at it and its Podfile for a better understanding.

#### Carthage

Coming soon.

#### Manual

Coming soon.

### Module Import

Once the framework is included in your project, simply import the module into your own code using:

`import JustApisSwiftSDK`

## Usage

### Making requests

To make requests to your JustAPIs server, you'll just need to create a `Gateway` and submit a `Request`. 

A simple example is shown here: 

```swift

var gateway = CompositedGateway(baseUrl: NSURL("http://my-justapi-server.local:5000/"))

gateway.get('/foo', params:["id":123], callback:
{ (result:RequestResult) in
  
  if let error = result.error
  {
     print("Received an error: \(error)")
     return
  }
  guard let response = result.response else
  {
     print("Received no response!")
     return
  }
  
  print("Received a response with HTTP status code: \(response.statusCode)")
})
```

In this example, you can see us use the `get` conveneince method on our gateway. 

This method prepares and submits a GET request using as few parameters as we likely need. There are a number of these convenience methods available for each of the common HTTP methods (GET, POST, PUT, DELETE). The full list of these convenience methods are available in `CoreTypes.swift`

### Receiving JSON Responses

If your JustAPI endpoints provide their responses in JSON, you can use the `JsonGateway` or apply a `JsonResponseProcessor` to the `CompositeGateway`.

```swift
var gateway = JsonGateway(baseUrl: NSURL("http://my-justapi-server.local:5000/"))

gateway.get('/foo', params:["id":123], callback:
{ (result:RequestResult) in
  
  if let error = result.error
  {
     print("Received an error: \(error)")
     return
  }
  guard let response = result.response else
  {
     print("Received no response!")
     return
  }
  guard let jsonData = response.body else
  {
  	  print:("No body data found!")
  	  return
  }
  print("Received a response with JSON content: \(jsonBody)")
})

```

##Development

The SDK is designed to be lightweight and modular so that you can enhance and modify its functionality without modifying its code directly. 

However, if you would like to make changes to the SDK, you are welcome to  clone or fork this repository. You will also need to modify your apps to make sure they integrate your code rather than what's hosted in this repository.

Unit Testing does require that you OHHTTPStubs is available in order to mock requests, but this is bundled in as a git submodule. See **Dependencies** for more information.