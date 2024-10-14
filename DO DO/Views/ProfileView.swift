import SwiftUI

@MainActor
final class settingsViewModel: ObservableObject {
    
    @Published private(set) var user: Users? = nil
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct ProfileView: View {
    
    @StateObject private var settingsviewModel = settingsViewModel()
    @Binding var isSignIn: Bool
    @State private var showAlert = false 
    

    var body: some View {
        GeometryReader { geometry in
            let wid = geometry.size.width
            let len = geometry.size.height
            VStack(alignment: .center, spacing: 0) {
                if let user = settingsviewModel.user {
                    VStack(alignment: .center, spacing: 0) {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: CGFloat(len / 3))
                            .foregroundStyle(Color.color1)
                            .clipShape(RoundedRectangle(cornerRadius: 62))
                            .overlay(alignment: .bottomLeading) {
                                VStack {
                                    if let photourl = user.photoUrl {
                                        let url = URL(string: photourl)
                                        AsyncImage(url: url) { image in
                                            image
                                                .clipShape(Circle())
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    Text(user.userName ?? "USER NAME")
                                }
                                .frame(width: 200, height: 200)
                                .position(x: CGFloat(wid / 2), y: CGFloat(len / 3))
                            }
                    }
                    Spacer()
                    VStack {
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("LogOut")
                                .font(.title)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 50)
                                .padding()
                                .background {
                                    Color.indigo
                                }
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 30)
                } else {
                    VStack(alignment: .center, spacing: 0) {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: CGFloat(len / 3))
                            .foregroundStyle(Color.color1)
                            .clipShape(RoundedRectangle(cornerRadius: 62))
                            .overlay(alignment: .bottomLeading) {
                                VStack {
                                    Circle()
                                        .foregroundStyle(Color.gray.opacity(0.3))
                                    Text("USER NAME")
                                }
                                .frame(width: 100, height: 100)
                                .position(x: CGFloat(wid / 2), y: CGFloat(len / 3))
                            }
                    }
                    Spacer()
                    VStack {
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("LogOut")
                                .font(.title)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 50)
                                .padding()
                                .background {
                                    Color.indigo
                                }
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log Out"), action: {
                    Task {
                        do {
                            try settingsviewModel.logOut()
                            isSignIn = true
                        } catch {
                            print(error)
                        }
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .task {
            try? await settingsviewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
    }
    

}

#Preview {
    NavigationView {
        ProfileView(isSignIn: .constant(false))
    }
}
