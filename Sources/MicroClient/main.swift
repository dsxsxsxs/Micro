import Micro

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

enum Store {
    static func save(_ value: Any) {}
}

// given
//@WithStoreModel
@WithStoreModelEmpty<User>(empty: { User(id: 0, name: "") })
struct User {
    let id: Int
    let name: String
}

// @WithStoreModel
// or
// #StaticStoreModel {
//    struct User {
//        let id: Int
//        let name: String
//    }
// }
struct User2Model: Codable {
    let id: Int
    let name: String

    func save() {
        Store.save(id)
        Store.save(name)
    }
}
// @StoreModel
extension User: Codable {
    func save() {
        Store.save(id)
        Store.save(name)
    }
}



// #emptyStoreModel {
//    UserModel(id: 0, name: "")
//}
