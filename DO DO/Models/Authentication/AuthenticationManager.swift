//
//  AuthenticationManager.swift
//  FirebaseLearning
//
//  Created by Tushar Gupta on 16/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore


struct AuthDataResultModel{
    let uid : String
    let email : String?
    let photoUrl : String?
    let userName : String?
    
    init(user: User){
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.userName = user.displayName
    }
}

enum AuthProviderOption : String {
    case email = "password"
    case google = "google.com"
}

final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    
    private init(){
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func getProvider()  throws -> [AuthProviderOption]{
        guard let providerData = Auth.auth().currentUser?.providerData else{
            throw URLError(.badServerResponse)
        }
        
        var providers : [AuthProviderOption] = [  ]
        
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            }
            else{
                assertionFailure()
            }
        }
        
        return providers
        
    }
    
        
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
    
    func deleteUser() async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badURL)
        }
       try await user.delete()
    }
    
    
}
//// MARK: SIGN IN WITH EMAIL
//extension AuthenticationManager{
//    
//    @discardableResult //we know the result we not gonna use it.
//    func createUser(email : String, password : String ) async throws -> AuthDataResultModel {
//        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
//        return AuthDataResultModel(user: authDataResult.user)
//    }
//    
//    @discardableResult
//    func signInUser(email : String, password : String ) async throws -> AuthDataResultModel{
//        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
//        return AuthDataResultModel(user: authDataResult.user)
//
//    }
//    
//    
//    func resetPassword(email : String) async throws{
//        try await Auth.auth().sendPasswordReset(withEmail: email)
//    }
//    
//    func updateEmail(email : String) async throws{
//        guard let user = Auth.auth().currentUser else{
//            throw URLError(.badServerResponse)
//        }
//        try await user.sendEmailVerification(beforeUpdatingEmail: email)
//    }
//    
//    func updatePassword(password : String) async throws{
//        guard let user = Auth.auth().currentUser else{
//            throw URLError(.badServerResponse)
//        }
//        try await user.updatePassword(to: password)
//    }
//
//}


// MARK: SIGN IN GOOGLE
extension AuthenticationManager{
    
    @discardableResult
    func signInWithGoogle(tokens : GoogleSignInResultModel) async throws -> AuthDataResultModel{
        let credential = GoogleAuthProvider.credential(
            withIDToken: tokens.idToken,
            accessToken: tokens.accessToken)
        return try await signInCredentials(credential: credential )
    }
   
    func signInCredentials(credential : AuthCredential) async throws -> AuthDataResultModel{
      let authDataResult =  try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}

////MARK: SIGN IN ANONYMOUS
//extension AuthenticationManager{
//    
//    @discardableResult
//    func signINAnonymous() async throws -> AuthDataResultModel{
//        let authDataResult = try await Auth.auth().signInAnonymously()
//        return AuthDataResultModel(user: authDataResult.user)
//    }
//    
//    @discardableResult
//    func linkEmail(email : String, password  :String) async throws -> AuthDataResultModel{
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        
//        return try await linkAcc(credential: credential)
//    }
//    @discardableResult
//    func linkGoogle(tokens : GoogleSignInResultModel) async throws -> AuthDataResultModel{
//        let credential = GoogleAuthProvider.credential(
//            withIDToken: tokens.idToken,
//            accessToken: tokens.accessToken)
//        
//       return try await linkAcc(credential: credential)
//    }
//    
//
//    private func linkAcc(credential : AuthCredential) async throws -> AuthDataResultModel{
//        
//        guard let user = Auth.auth().currentUser else{
//            throw URLError(.badURL)
//        }
//        
//        _ = try await user.link(with: credential)
//        return AuthDataResultModel(user: user)
//        
//    }
//    
//}
