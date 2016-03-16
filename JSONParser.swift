//
//  JKJSONParser.swift
//  Stalkie
//
//  Created by Joseph Kalash on 8/16/14.
//  Copyright (c) 2014 Joseph Kalash. All rights reserved.
//

import Foundation
import UIKit

/*

Can use this class as a JSON parser for response messages sent from your server
with the following format:

{
    StatusID: Int,
    Message: String,
    Record : Dictionary
}

*/

class JKJSONParser
{

	var error : NSError? = nil
	var record: NSDictionary?
	var statusID : Int?
	var message : String?
	
	init() {}
	
	func decodeServerResponse(_data: NSData)
	{
        error = nil
        
        do {
            try record = NSJSONSerialization.JSONObjectWithData(_data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        }
        catch { print(error) }
        
        if error != nil
        {
            let errMsg = "error decoding server response from url \(buildUrl()), message: \(error?.localizedDescription)"
            print("\(errMsg)")
            // appDelegate.logEvent("E", _logInfo: errMsg)
            return
        }
		
		statusID = record!.valueForKey("StatusId") as? Int
		message = record!.valueForKey("Message") as? String
	}
	
	func callBack(_data: NSDictionary?, _errMsg : String?)
	{
		if _errMsg != nil
		{
			//let errMsg = "error during web server url posting: \(_errMsg!)"
			// appDelegate.logEvent("E", _logInfo: errMsg)
			return
		}
		
		//decodeServerResponse(_data!)
	}
	
	func JSONStringify(jsonObj: AnyObject) -> NSString
	{
        // println(jsonObj)
		let e: NSError? = nil
        let jsonData : NSData = try! NSJSONSerialization.dataWithJSONObject(jsonObj,options: NSJSONWritingOptions(rawValue: 0))
		if e != nil
		{
			return ""
		}
		else
		{
			return NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
		}
	}
	
	func HTTPsendRequest(request: NSMutableURLRequest, callback: (NSDictionary?, String?) -> Void) -> Bool
	{
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
			{
				(data, response, error) -> Void in
				if (error != nil)
				{
					callback(nil, error!.localizedDescription)
				}
				else
				{
                    self.decodeServerResponse(data!)
					callback(self.record, nil)
				}
		}
		
		task.resume()
		
		return error == nil
	}
	
	func prepareRequest() -> NSMutableURLRequest
	{
		let url = buildUrl()
		let request = NSMutableURLRequest(URL: NSURL(string: url)!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		return request
	}
	
	// asynchroneous call
	func HTTPPostJSON(jsonObj: AnyObject, callback: (NSDictionary?, String?) -> Void) -> Bool
	{
		let request = prepareRequest()
		
		let jsonString = JSONStringify(jsonObj)
		
		// println(jsonString)
		
		if jsonString == ""
		{
			return false
		}
		
		let data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
		request.HTTPBody = data
		return HTTPsendRequest(request, callback: callBack)
	}
	
	func asyncGet() -> Bool
	{
		return HTTPsendRequest(prepareRequest(), callback: callBack)
	}
	
	// synchroneous call
	func parseRequest() -> Bool
	{
		let url = NSURL(string:buildUrl())
		let data : NSData?
		do {
			data = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
		} catch let error1 as NSError {
			error = error1
			data = nil
		}

		
        if error == nil
		{
			decodeServerResponse(data!)
			return parseServerResponse()
		}
		else
		{
			return false
		}
	}
    
    //MARK: - To Override
    func buildUrl() -> String
    {
        fatalError("Must Override JKJSONParser:buildUrl")
    }
    
    func parseServerResponse() -> Bool
    {
        fatalError("Must Override parseServerResponse")
    }
}
