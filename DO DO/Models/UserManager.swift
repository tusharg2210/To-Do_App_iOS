import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseFirestoreCombineSwift


struct Item: Codable, Hashable, Identifiable {
    var id = UUID().uuidString
    let title: String
    let bodyy : String
   var isCompleted: Bool
    var isPriority : Bool
}

struct Users: Codable {
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let userName: String?
    var items: [Item]?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.userName = auth.userName
        self.items = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_Id"
        case email = "email"
        case photoUrl = "photo_Url"
        case dateCreated = "date_Created"
        case userName = "user_Name"
        case items = "items"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
        self.items = try container.decodeIfPresent([Item].self, forKey: .items)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.userName, forKey: .userName)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.items, forKey: .items)
    }
}

final class UserManager : ObservableObject {
    static var shared = UserManager()
     init() {}
    private let db = Firestore.firestore()
    
    private func userDocument(userId: String) -> DocumentReference {
        db.collection("users").document(userId)
    }
    
    func createUser(user: Users) async throws {
        return try userDocument(userId: user.userId).setData(from: user, merge: true)
    }
    
    func getUser(userId: String) async throws -> Users {
        try await userDocument(userId: userId).getDocument(as: Users.self)
    }
    
    func addItem(userId: String, item: Item) async throws {
        let data: [String: Any] = [
            Users.CodingKeys.items.stringValue: FieldValue.arrayUnion([[
                "title": item.title,
                "isCompleted": item.isCompleted,
                "isPriority":item.isPriority,
                "bodyy":item.bodyy,
                "id":item.id
            ]])
        ]
        
        return try await userDocument(userId: userId).updateData(data)
    }
    
    
    func updateCompletionStatus(userId: String, itemId: String, isCompleted: Bool) async throws {
        var user = try await getUser(userId: userId)
        
        // Find the index of the item to update
        guard let index = user.items?.firstIndex(where: {$0.id == itemId}) else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])
        }
        
        // Update the item locally
        user.items?[index].isCompleted = isCompleted
        
        // Update the entire array
        let updatedData: [String: Any] = [
            Users.CodingKeys.items.stringValue: user.items?.map { [
                "title": $0.title,
                "isCompleted": $0.isCompleted,
                "isPriority": $0.isPriority,
                "bodyy": $0.bodyy,
                "id": $0.id
            ] } ?? []
        ]
        
        return try await userDocument(userId: userId).setData(updatedData, merge: true)
    }
    
    func updatePriorityStatus(userId: String, itemId: String, isPriority : Bool) async throws {
        var user = try await getUser(userId: userId)
        
        // Find the index of the item to update
        guard let index = user.items?.firstIndex(where: { $0.id == itemId }) else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])
        }
        
        // Update the item locally
        user.items?[index].isPriority = isPriority
        
        // Update the entire array
        let updatedData: [String: Any] = [
            Users.CodingKeys.items.stringValue: user.items?.map { [
                "title": $0.title,
                "isCompleted": $0.isCompleted,
                "isPriority": $0.isPriority,
                "bodyy": $0.bodyy,
                "id": $0.id
            ] } ?? []
        ]
        
        return try await userDocument(userId: userId).setData(updatedData, merge: true)
    }

    
    func deleteList(userId : String, itemId : String) async throws{
        var user = try await getUser(userId: userId)
        
        guard let index = user.items?.firstIndex(where: { $0.id == itemId }) else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])
        }
        
        user.items?.remove(at: index)
        
        let updatedData: [String: Any] = [
            Users.CodingKeys.items.stringValue: user.items?.map { [
                "title": $0.title,
                "isCompleted": $0.isCompleted,
                "isPriority": $0.isPriority,
                "bodyy": $0.bodyy,
                "id": $0.id
            ] } ?? []
        ]
        
        return try await userDocument(userId: userId).setData(updatedData, merge: true)
    }
    
//    func changeUserStatus(userId: String,itemID : String, isCompleted : Bool) async throws {
//        let data : [String: Any] = [
//            Users.CodingKeys.items.rawValue: FieldValue.arrayUnion([[
//                "isCompleted": isCompleted
//            ]])
//        ]
//        return try await userDocument(userId: userId).updateData(data)
//    }
    
}
