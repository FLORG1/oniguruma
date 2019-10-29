// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Oniguruma",
    products: [
        .library(name: "Oniguruma", targets: ["Oniguruma"]),        
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
      .target(name: "Samples", dependencies: ["Oniguruma"]),
      .target(name: "Oniguruma", dependencies: ["COniguruma"]),
      .target(name: "COniguruma",  path: "src", sources: [
            "regerror.c", "regparse.c", "regext.c", "regcomp.c", "regexec.c", "reggnu.c", "regenc.c", "regsyntax.c", "regtrav.c", "regversion.c", 
            "st.c", "onig_init.c", 
            "unicode.c", "ascii.c", 
            "utf8.c", "utf16_be.c", "utf16_le.c", "utf32_be.c", "utf32_le.c", 
            "euc_jp.c", "sjis.c", "euc_jp_prop.c", "sjis_prop.c",
            "iso8859_1.c", "iso8859_2.c", "iso8859_3.c", "iso8859_4.c", "iso8859_5.c", "iso8859_6.c", "iso8859_7.c", "iso8859_8.c", "iso8859_9.c", 
            "iso8859_10.c", "iso8859_11.c", "iso8859_13.c", "iso8859_14.c", "iso8859_15.c", "iso8859_16.c", 
            "euc_tw.c", "euc_kr.c", "big5.c", "gb18030.c", "koi8_r.c", "cp1251.c", 
            "unicode_unfold_key.c", "unicode_fold1_key.c", "unicode_fold2_key.c", "unicode_fold3_key.c"
            ])        
    ]
)
