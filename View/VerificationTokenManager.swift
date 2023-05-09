//
//  VerificationTokenManager.swift
//  Alarmer Test
//
//  Created by user234695 on 5/8/23.
//

import Foundation
import Alamofire

let accountSid = "ACcfae9a643457577632b828e0c493ac75"
let authToken = "79f444133772a97856863b1385d0a13b"

func sendVerificationToken(toPhoneNumber: String, completion: @escaping (Bool) -> Void) {
    let url = "https://verify.twilio.com/v2/Services/VA494981bf806934c5006b516e442fada2/Verifications"
    let parameters: [String: Any] = [
        "To": toPhoneNumber
    ]

    let headers: HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Basic " + "\(accountSid):\(authToken)".data(using: .utf8)!.base64EncodedString()
    ]

    AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
        switch response.result {
        case .success:
            completion(true)
        case .failure:
            completion(false)
        }
    }
}
