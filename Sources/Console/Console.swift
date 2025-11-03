import Foundation

/// Beautiful console output with colors and symbols
enum Console {
    // MARK: - ANSI Color Codes
    private enum Color: String {
        case reset = "\u{001B}[0m"
        case bold = "\u{001B}[1m"
        case red = "\u{001B}[31m"
        case green = "\u{001B}[32m"
        case yellow = "\u{001B}[33m"
        case blue = "\u{001B}[34m"
        case magenta = "\u{001B}[35m"
        case cyan = "\u{001B}[36m"
        case white = "\u{001B}[37m"
        case brightRed = "\u{001B}[91m"
        case brightGreen = "\u{001B}[92m"
        case brightYellow = "\u{001B}[93m"
        case brightBlue = "\u{001B}[94m"
        case brightCyan = "\u{001B}[96m"
    }

    // MARK: - Symbols
    private enum Symbol: String {
        case success = "✓"
        case error = "✗"
        case info = "ℹ"
        case warning = "⚠"
        case arrow = "→"
        case download = "⬇"
        case folder = "📁"
        case file = "📄"
        case gear = "⚙"
        case rocket = "🚀"
        case checkmark = "✅"
    }

    /// Success message (green with ✓)
    static func success(_ message: String) {
        print("\(Color.brightGreen.rawValue)\(Symbol.success.rawValue) \(message)\(Color.reset.rawValue)")
    }

    /// Error message (red with ✗)
    static func error(_ message: String) {
        print("\(Color.brightRed.rawValue)\(Symbol.error.rawValue) \(message)\(Color.reset.rawValue)")
    }

    /// Info message (blue with ℹ)
    static func info(_ message: String) {
        print("\(Color.brightBlue.rawValue)\(Symbol.info.rawValue) \(message)\(Color.reset.rawValue)")
    }

    /// Warning message (yellow with ⚠)
    static func warning(_ message: String) {
        print("\(Color.brightYellow.rawValue)\(Symbol.warning.rawValue) \(message)\(Color.reset.rawValue)")
    }

    /// Progress message (cyan with →)
    static func progress(_ message: String) {
        print("\(Color.brightCyan.rawValue)\(Symbol.arrow.rawValue) \(message)\(Color.reset.rawValue)")
    }

    /// Download message (green with ⬇)
    static func download(_ message: String) {
        print("\(Color.green.rawValue)\(Symbol.download.rawValue) \(message)\(Color.reset.rawValue)")
    }

    /// Bold text
    static func bold(_ message: String) {
        print("\(Color.bold.rawValue)\(message)\(Color.reset.rawValue)")
    }

    /// Setting info line (used in settings display)
    static func setting(name: String, value: String?, width: Int = 20) {
        let formattedName = "\(name):".padding(toLength: width, withPad: " ", startingAt: 0)
        let formattedValue = if let value, !value.isEmpty {
            value
        } else {
            "\(Color.yellow.rawValue)Not setted\(Color.reset.rawValue)"
        }
        print("\(Color.cyan.rawValue)\(formattedName)\(Color.reset.rawValue) \(formattedValue)")
    }
}
