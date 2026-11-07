// 本地构建用的 AboutKit 最小替身：原作者未公开该模块，这里提供同名 API 与系统关于窗口。
import AppKit

public struct OpenSourceCredit {
    public let name: String
    public let url: String
    public let author: String
    public let license: String
    public let usage: String

    public init(name: String, url: String, author: String, license: String, usage: String) {
        self.name = name
        self.url = url
        self.author = author
        self.license = license
        self.usage = usage
    }
}

public struct AboutApp {
    public let name: String
    public let summary: String
    public let repository: String
    public let credits: [OpenSourceCredit]
    public let disclaimer: String

    public init(name: String, summary: String, repository: String, credits: [OpenSourceCredit], disclaimer: String) {
        self.name = name
        self.summary = summary
        self.repository = repository
        self.credits = credits
        self.disclaimer = disclaimer
    }
}

public final class AboutWindowController {
    private let app: AboutApp
    private var window: NSWindow?

    public init(app: AboutApp) { self.app = app }

    public func show() {
        let window = window ?? makeWindow()
        self.window = window
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    public func render(to url: URL) {
        let window = makeWindow()
        guard let view = window.contentView else { return }
        view.layoutSubtreeIfNeeded()
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
        view.cacheDisplay(in: view.bounds, to: rep)
        guard let data = rep.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: url)
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 520),
            styleMask: [.titled, .closable], backing: .buffered, defer: false
        )
        window.title = "关于 \(app.name)"
        window.isReleasedWhenClosed = false
        window.contentView = makeContent()
        return window
    }

    private func makeContent() -> NSView {
        let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: 480, height: 520))
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.drawsBackground = false

        let textView = NSTextView(frame: scroll.bounds)
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 20, height: 20)
        textView.textContainer?.widthTracksTextView = true
        textView.autoresizingMask = [.width]
        textView.textStorage?.setAttributedString(content())
        scroll.documentView = textView
        return scroll
    }

    private func content() -> NSAttributedString {
        let result = NSMutableAttributedString()

        func append(_ text: String, size: CGFloat = 13, weight: NSFont.Weight = .regular, color: NSColor = .labelColor, link: String? = nil) {
            var attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: size, weight: weight),
                .foregroundColor: color,
            ]
            if let link, let url = URL(string: link) {
                attrs[.link] = url
                attrs[.foregroundColor] = NSColor.linkColor
            }
            result.append(NSAttributedString(string: text, attributes: attrs))
        }

        append(app.name + "\n", size: 22, weight: .bold)
        append("\n" + app.summary + "\n\n")
        append("项目主页：", weight: .semibold)
        append(app.repository + "\n\n", link: app.repository)

        append("开源组件\n", size: 15, weight: .semibold)
        for credit in app.credits {
            append("\(credit.name)（\(credit.license)）\n", weight: .medium)
            append("\(credit.author) · \(credit.usage)\n")
            append(credit.url + "\n\n", size: 12, color: .secondaryLabelColor, link: credit.url)
        }

        append(app.disclaimer, size: 11, color: .secondaryLabelColor)
        return result
    }
}

public enum DebugLabels {
    public static var fileURL: URL?
    public static var windowPrefix: ((NSWindow) -> String?)?

    public static func start() {}
    public static func decorate(_ menu: NSMenu) {}
}
