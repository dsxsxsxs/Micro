import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MicroMacros)
import MicroMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "WithStoreModel": WithStoreModelMacro.self
]
#endif

final class MicroTests: XCTestCase {

    func testWithStoreMacro() {

        #if canImport(MicroMacros)
        assertMacroExpansion(
            """
            @WithStoreModel
            struct User {
                let id: Int
                let name: String
            }
            """,
            expandedSource: """
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    func testMacro() throws {
        #if canImport(MicroMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(MicroMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
