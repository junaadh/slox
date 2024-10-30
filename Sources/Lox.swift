import Foundation

/// slox main
class Slox {
    private var hadError: Bool = false
    private var hadRuntimeError: Bool = false
    private var interpreter: Interpreter = Interpreter()

    func main(_ args: [String]) {
        if args.count > 2 {
            print("Usage: \(args[0]) [script]")
            exit(64)
        } else if args.count == 2 {
            try! run_file(args[1])
        } else {
            try! run_repl()
        }
    }

    private func run_repl() throws {
        while true {
            print("🔥 > ", terminator: "")
            guard let line = readLine(strippingNewline: true) else { return }

            if line.isEmpty { break }
            run(line)
            hadError = false
        }
        print("Exiting...")
    }

    private func run_file(_ path: String) throws {
        let bytes = try Data(contentsOf: URL(fileURLWithPath: path))
        run(String(bytes: bytes, encoding: .utf8)!)
        if hadError { exit(65) }
        if hadRuntimeError { exit(70) }
    }

    private func run(_ value: String) {
        let scanner = Scanner(source: value, self)
        let tokens = scanner.scan_tokens()

        if hadError {
            return
        }

        let parser = Parser(tokens: tokens, slox: self)
        do {
            let expr = try parser.parse()

            if hadError {
                return
            }

            try interpreter.interpret(expr)

            // print(AstPrinter().print(expr))
        } catch let error as RuntimeError {
            self.runtime(error)
        } catch {
            return
        }

        // for token in tokens {
        //     print(token)
        // }
    }

    func error(_ line: Int, _ msg: String) {
        report(line, "", msg)
    }

    private func report(_ line: Int, _ where_: String, _ msg: String) {
        print("[line: \(line)]: Error \(where_): \(msg)")
        hadError = true
    }

    func error(_ token: Token, _ message: String) {
        if token.token_type == .eof {
            report(token.line, " at end", message)
        } else {
            report(token.line, " at '\(token.token_type)'", message)
        }
    }

    func runtime(_ error: RuntimeError) {
        print("\(error.msg)\n[line \(error.token.line)]")
        hadRuntimeError = true
    }
}
