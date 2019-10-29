import COniguruma

public func initialize() {
  initialize(with: .UTF8)
}

public func initialize(with encoding: Encoding) {
  var enc = encoding.onig_type
  withUnsafeMutablePointer(to: &enc) {
    var encs: [OnigEncoding?] = [$0]
    onig_initialize(&encs, Int32(1))
  }
}


