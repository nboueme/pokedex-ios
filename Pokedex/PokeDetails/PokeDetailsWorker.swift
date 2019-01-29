//
//  PokeDetailsWorker.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit
import Alamofire

typealias spriteResponseHandler = (_ response: PokeDetailsModel.FetchSprite.Response) -> ()

class PokeDetailsWorker {
    func fetchSprite(withURL: String, success: @escaping(spriteResponseHandler), fail: @escaping(spriteResponseHandler)) {
        Alamofire.request(withURL).responseData { response in
            if response.result.isSuccess {
                success(PokeDetailsModel.FetchSprite.Response(sprite: UIImage(data: response.data!, scale: 1), isError: false, message: nil))
            } else if response.result.isFailure {
                var message = String()
                if let error = response.error {
                    message = self.handleError(code: error._code)
                }
                fail(PokeDetailsModel.FetchSprite.Response(sprite: nil, isError: true, message: message))
            }
        }
    }
    
    private func handleError(code: NSInteger) -> String {
        var message = String()
        
        switch code {
        case NSURLErrorTimedOut:
            message = "Network Timeout!"
            break
        case NSURLErrorNotConnectedToInternet:
            message = "You're not connected to Internet!"
            break
        default:
            message = "\(code)"
        }
        
        return message
    }
}
