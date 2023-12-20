import Foundation
import COniguruma


extension String.Encoding {
  var codeUnitLength: Int {
    switch self {
    case .ascii:
      return 1
    case .utf8:
      return 1
    case .utf16BigEndian:
      return 2
    case .utf16LittleEndian:
      return 2
    case .utf32BigEndian:
      return 4
    case .utf32LittleEndian:
      return 4
    default:
      return 1
    }
  }

  func withUnsafeMutableEncodingPtr<T>(_ f: (UnsafeMutablePointer<OnigEncodingType>?) -> T) -> T {
    switch self {
    case .ascii:
      return f(&OnigEncodingASCII)
    case .utf8:
      return f(&OnigEncodingUTF8)
    case .utf16BigEndian:
      return f(&OnigEncodingUTF16_BE)
    case .utf16LittleEndian:
      return f(&OnigEncodingUTF16_LE)
    case .utf32BigEndian:
      return f(&OnigEncodingUTF32_BE)
    case .utf32LittleEndian:
      return f(&OnigEncodingUTF32_LE)
    default:
      return f(nil)
    }
  }

}

public func initialize(with encoding: String.Encoding) {
  encoding.withUnsafeMutableEncodingPtr {
    guard let enc = $0 else {
      fatalError("Encoding \(encoding) is not supported by Oniguruma")
    }
    var encs: [OnigEncoding?] = [$0]
    onig_initialize(&encs, Int32(1))
  }
}

