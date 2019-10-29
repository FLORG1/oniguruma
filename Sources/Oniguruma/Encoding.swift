//
//  Encoding.swift
//  Oniguruma
//
//  Created by Grigory Markin on 09.07.19.
//

import COniguruma

public enum Encoding {
  case ASCII, UTF8, UTF16_BE, UTF16_LE, UTF32_BE, UTF32_LE
}

extension Encoding {
  var onig_type: OnigEncodingType {
    switch self {
    case .ASCII:
      return OnigEncodingASCII
    case .UTF8:
      return OnigEncodingUTF8
    case .UTF16_BE:
      return OnigEncodingUTF16_BE
    case .UTF16_LE:
      return OnigEncodingUTF16_LE
    case .UTF32_BE:
      return OnigEncodingUTF32_BE
    case .UTF32_LE:
      return OnigEncodingUTF32_LE
    }
  }
}
