protocol AuthServiceConsumer: class {
    func onAuthenticationCompleted(withToken token: Token)
}
