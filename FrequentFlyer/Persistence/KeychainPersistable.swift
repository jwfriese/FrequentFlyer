protocol KeychainPersistable {
    static var serviceName: String { get }
    var data: [String : AnyObject] { get }
}
