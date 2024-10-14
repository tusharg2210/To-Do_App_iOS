//
//  AuthenticationViewModel.swift
//  FirebaseLearning
//
//  Created by Tushar Gupta on 20/09/24.
//

import Foundation

@MainActor
final class AuthenticationViewModel : ObservableObject{
    
    func googleSignIN() async throws{
        
        let helper = SignInGoogleHelper()
        let tokens = try await helper.SignIN()
        
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = Users(auth: authDataResult)
        try await UserManager.shared.createUser(user: user)
    }
    
   
    
}
