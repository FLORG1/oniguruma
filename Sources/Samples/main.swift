import Oniguruma

Oniguruma.initialize()


func simple() {
  let regex = Regex("a(.*)b|[e-f]+")
  
  if let result = regex?.search("zzzzaffffffffb", in: 5...) {
    print(result)
    for (i, reg) in result.regs.enumerated() {
      if reg.isEmpty {
        print("Empty region \(i)")
      }
    }
  }
}

func names() {
  let regex = Regex("(?<foo>a*)(?<bar>b*)(?<foo>c*)")
  if let result = regex?.search("aaabbbbcc") {
    print(result)
  }
}


func foo() {
  //let r1 = Regex("(^[ \\t]+)?(?=//)")
  //let str = "(?!\\\u{FFFF})"
  let str = "(?!\\G)"
  let r2 = Regex(str)
  
  print(str)
  
//  if let result = r1?.search("// comment\naaa") {
//    print(result)
//  }
  
  if let result = r2?.search("// comment\na", from: 11) {
    print(result)
  }
}

foo()
