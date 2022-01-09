import Text "mo:base/Text";
import Nat "mo:base/Nat";

// Create a simple Counter actor.
actor Counter {
  stable var currentValue : Nat = 0;

  // Increment the counter with the increment function.
  public func increment() : async () {
    currentValue += 1;
  };

  // Read the counter value with a get function.
  public query func get() : async Nat {
    currentValue
  };

  // Write an arbitrary value with a set function.
  public func set(n: Nat) : async () {
    currentValue := n;
  };

  // public type Key = Text;
  // public type Path = Text;

  public type HeaderField = (Text, Text);

  public type StreamingCallbackHttpResponse = {
    token: ?StreamCallbackToken;
    body: Blob;
  };

  public type StreamCallbackToken = {
    key: Text;
    sha256: ?[Nat8];
    index: Nat;
    content_encoding: Text;
  };

  public type StreamStrategy = {
    #Callback: {
      token: StreamCallbackToken;
      callback: shared query StreamCallbackToken -> async StreamingCallbackHttpResponse;
    };
  };

  public type HttpRequest = {
    body: Blob;
    headers: [HeaderField];
    method: Text;
    url: Text;
  };

  public type HttpResponse = {
    body: Blob;
    headers: [HeaderField];
    status_code: Nat16;
    stream_strategy: ?StreamStrategy
  };

  public shared query func http_request(req: HttpRequest): async HttpResponse {
    let count = currentValue;
    let cnt = Nat.toText(count);
    
    let body = Text.encodeUtf8(
      Text.concat(
        Text.concat("<html><body><h1>Counter:", cnt),
        " </h1></body></html>",
      )
    );
    {
      body = body;
      headers = [];
      stream_strategy = null;
      status_code = 200;
    }
  }
}