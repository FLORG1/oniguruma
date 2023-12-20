//
//  Regex.swift
//  Oniguruma
//
//  Created by Grigory Markin on 09.07.19.
//
import Foundation
import COniguruma

public struct Regex {
  private var regex: OnigRegex?
  private var error_info: OnigErrorInfo

  private let codeUnitLength: Int

  public init?(_ pattern: String, encoding: String.Encoding) {
    self.regex = nil
    self.error_info = OnigErrorInfo()
    self.codeUnitLength = encoding.codeUnitLength

    let status: Int32? = pattern.data(using: encoding)?.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
      let buf = ptr.bindMemory(to: UInt8.self)
      let uint8p = buf.baseAddress!

      let end = uint8p.advanced(by: buf.count)

      return encoding.withUnsafeMutableEncodingPtr {
        guard let ptr = $0 else { return nil }
        return onig_new(&regex, uint8p, end, ONIG_OPTION_CAPTURE_GROUP, ptr, OnigDefaultSyntax, &error_info)
      }
    }

    guard status == ONIG_NORMAL else { return nil }
  }

  public func search(_ data: Data, from: Int? = nil, to: Int? = nil) -> SearchResult? {
    let region = onig_region_new()
    defer {
      onig_region_free(region, Int32(1))
    }

    let pos = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
      let buf = ptr.bindMemory(to: UInt8.self)
      let uint8p = buf.baseAddress!

      let _from = (from == nil) ? 0 : from! * self.codeUnitLength
      let _to = (to == nil) ? buf.count : to! * self.codeUnitLength

      let end = uint8p.advanced(by: buf.count)

      let start = uint8p.advanced(by: _from)
      let range = uint8p.advanced(by: _to)

      return onig_search(self.regex, uint8p, end, start, range, region, ONIG_OPTION_NONE)
    }

    if pos >= 0 {
      let result = SearchResult(at: Int(pos), regex: regex, region: region, codeUnitLength: self.codeUnitLength)
      return result
    }

    return nil
  }

  public func search(_ data: Data, in range: Range<Int>) -> SearchResult? {
    return search(data, from: range.lowerBound, to: range.upperBound)
  }
  
  public func search(_ data: Data, in range: NSRange) -> SearchResult? {
    return search(data, from: range.lowerBound, to: range.upperBound)
  }
  
  public func search(_ data: Data, in range: PartialRangeFrom<Int>) -> SearchResult? {
    return search(data, from: range.lowerBound)
  }
  
  public func search(_ data: Data, in range: PartialRangeUpTo<Int>) -> SearchResult? {
    return search(data, to: range.upperBound)
  }
  
  // MARK: -
  
  public struct SearchResult {
    public let at: Int
    
    public private(set) var regs: [Range<Int>] = []
    public private(set) var names: [String:[Int]] = [:]
    
    public var range: Range<Int> { return regs[0] }
    
    fileprivate init(at pos: Int, regex: OnigRegex?, region: UnsafeMutablePointer<OnigRegion>?, codeUnitLength: Int) {
      self.at = (pos - 1 + codeUnitLength) / codeUnitLength
      
      if let region = region {
        let reg = region.pointee
        for i in 0..<Int(reg.num_regs) {
          let a = Int(reg.beg.advanced(by: i).pointee)
          let b = Int(reg.end.advanced(by: i).pointee)

          guard a != ONIG_REGION_NOTPOS,
                b != ONIG_REGION_NOTPOS else { continue }

          let beg =  (a - 1 + codeUnitLength) / codeUnitLength
          let end =  (b - 1 + codeUnitLength) / codeUnitLength

          self.regs.append(beg..<end)
        }
        
        var arg = names_visitor_arg()
        let _ = onig_foreach_name(regex, names_visitor, &arg)
        
        self.names = arg.names
      }
    }
  }
}

// MARK -

fileprivate struct names_visitor_arg {
  var names: [String: [Int]] = [:]

  mutating func add_named_group(_ name: String, _ group_num: Int) {
    var groups = self.names[name] ?? []
    groups.append(group_num)
    self.names.updateValue(groups, forKey: name)
  }
}

// MARK -

fileprivate func names_visitor(_ name: UnsafePointer<UInt8>?,
                               _ name_end: UnsafePointer<UInt8>?,
                               _ ngroup_num: Int32,
                               _ group_nums: UnsafeMutablePointer<Int32>?,
                               _ regex: OnigRegex?,
                               _ arg: UnsafeMutableRawPointer?) -> Int32 {
  
  // If no arg is present stop walking by returning 1
  guard let _arg = arg?.bindMemory(to: names_visitor_arg.self, capacity: 1) else { return 1 }
  
  // In all other cases just skip to the next name by returning 0
  guard let _name_ptr = name else { return 0 }
  
  let name = String(cString: _name_ptr)
  
  for i in 0..<Int(ngroup_num) {
    guard let group_num = group_nums?.advanced(by: i).pointee else { return 0 }
    _arg.pointee.add_named_group(name, Int(group_num))
  }
  
  return 0
}
