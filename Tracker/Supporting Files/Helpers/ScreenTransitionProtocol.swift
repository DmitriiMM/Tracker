import Foundation

protocol ScreenTransitionProtocol: AnyObject {
    func onTransition<T>(value: T, for key: String)
}
