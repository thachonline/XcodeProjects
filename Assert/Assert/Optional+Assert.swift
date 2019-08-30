import Foundation

extension Optional {
    func assert(or defaultValue: Wrapped, file: String = #file, line: Int = #line) -> Wrapped {
        switch self {
        case .none:
            assertionFailure("\((file as NSString).lastPathComponent):\(line) is nil")
            return defaultValue
        case .some(let value):
            return value
        }
    }
    
    /**
     it is nonescaping, so there is no perfermance issue
     
     text.assertExecute { print($0) }
     
     vs
     
     if let text = text {
     print(text)
     } else {
     assertionFailure()
     }
     
     */
    // TODO: check with and without "rethrows"
    func assertExecute(file: String = #file, line: Int = #line, _ action: (Wrapped) throws -> Void) rethrows {
        switch self {
        case .none:
            assertionFailure("\((file as NSString).lastPathComponent):\(line) is nil")
        case .some(let value):
            try action(value)
        }
    }
}
