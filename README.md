JKJSONParser
————————————

Userful class for parsing JSON for response messages sent from your server with the following format:

```
{
    StatusID: Int,
    Message: String,
    Record : Dictionary
}
```

Example:
————————

**Sending request without handling a server callback:**

```swift
let parser = JKJSONParser()
parser.HTTPsendRequest(NSMutableURLRequest(URL: NSURL(string: ”http://myserver.com/someDirectory/myscript.php”)!), callback: nil)
```

**Sending request with callback handling:**

```swift
parser.HTTPsendRequest(NSMutableURLRequest(URL: NSURL(string: ”http://myserver.com/someDirectory/myscript.php”)!), callback:{ (data, error) -> Void in
            if data!.valueForKey("StatusId") as? Int != 1 { 
		//Handle error
		return
            }

            var response = data!.valueForKey("Response") as? NSArray

	     //
            //Process response object
	     //
		
	     //Callback method
            callback()
        })
    }
```