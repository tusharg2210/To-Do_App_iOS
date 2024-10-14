//
//  SignInGoogle.swift
//  FirebaseLearning
//
//  Created by Tushar Gupta on 17/09/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel{
    let idToken : String
    let accessToken : String
}

final class SignInGoogleHelper{
    
//    
//    static let shared = Utilities()
//    
//    private init(){ }
    
    
    @MainActor
        func topViewController(controller: UIViewController? = nil) -> UIViewController? {
            
            let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
            
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
    
    
    
    
    @MainActor
    func SignIN() async throws -> GoogleSignInResultModel{
        guard let topVC = topViewController() else{
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard  let idToken = gidSignInResult.user.idToken?.tokenString else{
            throw URLError(.cannotFindHost)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel.init(idToken: idToken, accessToken: accessToken)
        
        return tokens
    }
}

