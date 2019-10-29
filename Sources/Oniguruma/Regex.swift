//
//  Regex.swift
//  Oniguruma
//
//  Created by Grigory Markin on 09.07.19.
//
import Foundation
import COniguruma

public struct Regex {
  var regex: OnigRegex?
  var error_info: OnigErrorInfo
  
  public let pattern: String
  
  public init?(_ pattern: String) {
    self.regex = nil
    self.error_info = OnigErrorInfo()
    
    self.pattern = pattern
    
    let status: Int32 = pattern.withCString(encodedAs: Unicode.UTF8.self) {
      let end = $0.advanced(by: pattern.utf8.count)
      return onig_new(&regex, $0, end, ONIG_OPTION_CAPTURE_GROUP, &OnigEncodingUTF8, OnigDefaultSyntax, &error_info)
    }
    
    if status != ONIG_NORMAL {
      return nil
    }
  }
  
  public func search(_ str: String, from: Int? = nil, to: Int? = nil) -> SearchResult? {
    let region = onig_region_new()
    defer {
      onig_region_free(region, Int32(1))
    }
    
    let pos: Int32 = str.withCString(encodedAs: Unicode.UTF8.self) {
      let data = str.utf8
      let end = $0.advanced(by: data.count)
      
      let start = $0.advanced(by: from ?? 0)
      let range = $0.advanced(by: to ?? data.count)
      
      return onig_search(self.regex, $0, end, start, range, region, ONIG_OPTION_NONE)
    }
    
    if pos >= 0 {
      let result = SearchResult(at: Int(pos), regex: regex, region: region)
      return result
    }
    
    return nil
  }
  
  public func search(_ str: String, in range: Range<Int>) -> SearchResult? {
    return search(str, from: range.lowerBound, to: range.upperBound)
  }
  
  public func search(_ str: String, in range: NSRange) -> SearchResult? {
    return search(str, from: range.lowerBound, to: range.upperBound)
  }
  
  public func search(_ str: String, in range: PartialRangeFrom<Int>) -> SearchResult? {
    return search(str, from: range.lowerBound)
  }
  
  public func search(_ str: String, in range: PartialRangeUpTo<Int>) -> SearchResult? {
    return search(str, to: range.upperBound)
  }
  
  // MARK: -
  
  public struct SearchResult {
    public let at: Int
    
    public private(set) var regs: [Range<Int>] = []
    public private(set) var names: [String:[Int]] = [:]
    
    public var range: Range<Int> { return regs[0] }
    
    fileprivate init(at pos: Int, regex: OnigRegex?, region: UnsafeMutablePointer<OnigRegion>?) {
      self.at = pos
      
      if let _region = region {
        let reg = _region.pointee
        for i in 0..<Int(reg.num_regs) {
          let beg = Int(reg.beg.advanced(by: i).pointee)
          let end = Int(reg.end.advanced(by: i).pointee)
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
