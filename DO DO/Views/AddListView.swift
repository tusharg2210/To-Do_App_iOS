import SwiftUI

@MainActor
final class AddListViewModel: ObservableObject {
    @Published private(set) var user: Users? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func addList(title: String, body: String, isPriority: Bool, isCompleted: Bool) async throws {
        guard let user else {
            return
        }
        let list = Item(title: title, bodyy: body, isCompleted: false, isPriority: isPriority)
        Task {
            try await UserManager.shared.addItem(userId: user.userId, item: list)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct AddListView: View {
    
    @Environment(\.dismiss) var dismissd
    @EnvironmentObject var todoViewModel: UserManager
    
    @StateObject private var addListViewModel = AddListViewModel()
    @State var addList: String = ""
    @State private var addBody: String = ""
    @State private var isPrior: Bool = false
    @State private var showAlert: Bool = false // State to control the alert
    
    var body: some View {
        ScrollView {
            VStack {
                // Add Title
                VStack(alignment: .leading) {
                    Text("Title*")
                        .font(.headline)
                        .padding(.horizontal, 10)
                    TextField("Title", text: $addList)
                        .padding(10)
                        .frame(height: 35)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical)
                
                // Add Body
                VStack(alignment: .leading) {
                    Text("Add Something")
                        .font(.headline)
                        .padding(.horizontal, 10)
                    TextEditor(text: $addBody)
                        .border(.gray)
                        .padding(10)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.vertical)
                
                // Add Priority
                Picker("Priority", selection: $isPrior) {
                    Text("Low").tag(false)
                    Text("High").tag(true)
                }
                .pickerStyle(.navigationLink)
                .padding(10)
                
                Spacer()
                
                // SAVE BUTTON
                if addList.count > 0 {
                    Button {
                        Task {
                            try await addListViewModel.addList(
                                title: addList,
                                body: addBody,
                                isPriority: isPrior,
                                isCompleted: false
                            )
                            showAlert = true // Show the alert after saving
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            addList.removeAll()
                            addBody.removeAll()
                            isPrior = false
                        }
                    } label: {
                        Text("Save")
                            .foregroundStyle(Color.white)
                            .font(.title2)
                            .padding(.horizontal, 40)
                            .padding()
                            .background(Color.indigo)
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(height: 600)
            .padding()
        }
        .navigationTitle("Add new Items ✏️")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Saved"),
                message: Text("Task saved successfully!"),
                dismissButton: .default(Text("OK"), action: {
                    dismissd() // Dismiss the view after pressing OK
                })
            )
        }
        .task {
            try? await addListViewModel.loadCurrentUser()
        }
    }
}

#Preview {
    NavigationStack {
        AddListView()
    }.environmentObject(UserManager())
}
