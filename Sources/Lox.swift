import Foundation

class Slox {
    private var hadError: Bool = false
    
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
            
            if line.isEmpty {break}
            run(line)
            hadError = false
        }
        print("Exiting...")
    }
    
    private func run_file(_ path: String) throws {
        let bytes = try Data(contentsOf: URL(fileURLWithPath: path))
        run(String(bytes: bytes, encoding: .utf8)!)
        if hadError { exit(65) }
    }
    
    private func run(_ value: String) {
        let scanner = Scanner(source: value, self)
        let tokens = scanner.scan_tokens()
        
        for token in tokens {
            print(token)
        }
    }
    
    func error(_ line: Int,_ msg: String) {
        report(line, "", msg)
    }
    
    private func report(_ line: Int,_ where_: String,_ msg: String) {
        print("[line: \(line)]: Error \(where_): \(msg)")
        hadError = true
    }
}
