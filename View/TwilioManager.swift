//
//  TwilioManager.swift
//  Alarmer Test
//
//  Created by user234695 on 4/17/23.
//

//functionality for using Twilio, WIP
import Foundation
import Alamofire

struct SMSManager {
    func sendSMS(accountSid: String, authToken: String, fromPhoneNumber: String, toPhoneNumber: String, message: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "https://api.twilio.com/2010-04-01/Accounts/\(accountSid)/Messages.json"

        let headers: HTTPHeaders = [
            "Authorization": "Basic " + "\(accountSid):\(authToken)".data(using: .utf8)!.base64EncodedString()
        ]

        let parameters: Parameters = [
            "From": fromPhoneNumber,
            "To": toPhoneNumber,
            "Body": message
        ]

        AF.request(urlString, method: .post, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}


