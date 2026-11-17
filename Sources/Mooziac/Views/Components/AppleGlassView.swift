import AppKit
import QuartzCore

/// Reusable Apple Liquid Glass surface that uses native `NSGlassEffectView` on macOS 26+
/// (loaded safely at runtime so Swift 5.9 / macOS 13+ SDKs compile cleanly) and falls back
/// to a multi-layered `NSVisualEffectView` + specular meniscus rim on earlier macOS versions.
final class AppleGlassView: NSView {
    enum Style {
        case dark
        case light
        case crystal
        case adaptive(accent: NSColor?)
    }

    var style: Style = .dark {
        didSet { applyStyle() }
    }

    var cornerRadius: CGFloat = 20.0 {
        didSet { updateCornerRadius() }
    }

    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow {
        didSet {
            visualEffectView.blendingMode = blendingMode
        }
    }

    var showsSpecularRim: Bool = true {
        didSet {
            meniscusLayer.isHidden = !showsSpecularRim
        }
    }

    private var nativeGlassView: NSView?
    private let visualEffectView = NSVisualEffectView()
    private let tintLayer = CALayer()
    private let meniscusLayer = CAGradientLayer()
    private let borderLayer = CALayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        wantsLayer = true
        layer?.masksToBounds = true

        // 1. Attempt native macOS 26+ NSGlassEffectView when available at runtime
        if let glassClass = NSClassFromString("NSGlassEffectView") as? NSView.Type {
            let glass = glassClass.init(frame: bounds)
            glass.translatesAutoresizingMaskIntoConstraints = false
            addSubview(glass)
            NSLayoutConstraint.activate([
                glass.topAnchor.constraint(equalTo: topAnchor),
                glass.bottomAnchor.constraint(equalTo: bottomAnchor),
                glass.leadingAnchor.constraint(equalTo: leadingAnchor),
                glass.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            nativeGlassView = glass
        }

        // 2. Fallback / optical NSVisualEffectView layer (hidden when nativeGlassView is active)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.isHidden = (nativeGlassView != nil)
        addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // 3. Subtle tint backing + specular meniscus + hairline rim
        layer?.addSublayer(tintLayer)

        meniscusLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        meniscusLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        meniscusLayer.locations = [0.0, 0.14, 0.86, 1.0]
        layer?.addSublayer(meniscusLayer)

        borderLayer.borderWidth = 1.0
        layer?.addSublayer(borderLayer)

        updateCornerRadius()
        applyStyle()
    }

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tintLayer.frame = bounds
        meniscusLayer.frame = bounds
        borderLayer.frame = bounds
        CATransaction.commit()
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        applyStyle()
    }

    private func updateCornerRadius() {
        layer?.cornerRadius = cornerRadius
        visualEffectView.layer?.cornerRadius = cornerRadius
        visualEffectView.layer?.masksToBounds = true
        tintLayer.cornerRadius = cornerRadius
        meniscusLayer.cornerRadius = cornerRadius
        borderLayer.cornerRadius = cornerRadius

        if let glass = nativeGlassView {
            let sel = NSSelectorFromString("setCornerRadius:")
            if glass.responds(to: sel) {
                glass.setValue(cornerRadius, forKey: "cornerRadius")
            }
            glass.layer?.cornerRadius = cornerRadius
            glass.layer?.masksToBounds = true
        }
    }

    func applyStyle() {
        let isDarkSystem = SystemAppearanceHelper.isDarkSystemAppearance
        let useDark: Bool
        let tintColor: NSColor
        let borderColor: NSColor
        let meniscusColors: [CGColor]

        switch style {
        case .dark:
            useDark = true
            visualEffectView.material = .hudWindow
            tintColor = NSColor(red: 0.07, green: 0.08, blue: 0.11, alpha: nativeGlassView != nil ? 0.28 : 0.62)
            borderColor = NSColor(white: 1.0, alpha: 0.22)
            meniscusColors = [
                NSColor(white: 1.0, alpha: 0.26).cgColor,
                NSColor(white: 1.0, alpha: 0.06).cgColor,
                NSColor(white: 1.0, alpha: 0.00).cgColor,
                NSColor(white: 1.0, alpha: 0.10).cgColor
            ]

        case .light:
            useDark = false
            visualEffectView.material = .popover
            tintColor = NSColor(white: 0.96, alpha: nativeGlassView != nil ? 0.24 : 0.68)
            borderColor = NSColor(white: 1.0, alpha: 0.65)
            meniscusColors = [
                NSColor(white: 1.0, alpha: 0.72).cgColor,
                NSColor(white: 1.0, alpha: 0.22).cgColor,
                NSColor(white: 0.0, alpha: 0.00).cgColor,
                NSColor(white: 0.0, alpha: 0.05).cgColor
            ]

        case .crystal:
            useDark = false
            visualEffectView.material = .popover
            tintColor = NSColor(red: 0.94, green: 0.96, blue: 0.97, alpha: nativeGlassView != nil ? 0.30 : 0.58)
            borderColor = NSColor(white: 1.0, alpha: 0.75)
            meniscusColors = [
                NSColor(white: 1.0, alpha: 0.85).cgColor,
                NSColor(white: 1.0, alpha: 0.30).cgColor,
                NSColor(white: 0.0, alpha: 0.00).cgColor,
                NSColor(white: 1.0, alpha: 0.18).cgColor
            ]

        case .adaptive(let accent):
            useDark = isDarkSystem
            visualEffectView.material = isDarkSystem ? .hudWindow : .popover
            if let accent = accent {
                let blended = accent.usingColorSpace(.sRGB) ?? accent
                tintColor = blended.withAlphaComponent(nativeGlassView != nil ? 0.18 : 0.34)
                borderColor = NSColor(white: isDarkSystem ? 1.0 : 0.0, alpha: isDarkSystem ? 0.26 : 0.16)
            } else {
                tintColor = isDarkSystem
                    ? NSColor(red: 0.08, green: 0.09, blue: 0.13, alpha: nativeGlassView != nil ? 0.22 : 0.60)
                    : NSColor(white: 0.95, alpha: nativeGlassView != nil ? 0.22 : 0.68)
                borderColor = isDarkSystem ? NSColor(white: 1.0, alpha: 0.26) : NSColor(white: 1.0, alpha: 0.65)
            }
            meniscusColors = isDarkSystem
                ? [
                    NSColor(white: 1.0, alpha: 0.34).cgColor,
                    NSColor(white: 1.0, alpha: 0.08).cgColor,
                    NSColor(white: 1.0, alpha: 0.00).cgColor,
                    NSColor(white: 1.0, alpha: 0.12).cgColor
                ]
                : [
                    NSColor(white: 1.0, alpha: 0.75).cgColor,
                    NSColor(white: 1.0, alpha: 0.24).cgColor,
                    NSColor(white: 0.0, alpha: 0.00).cgColor,
                    NSColor(white: 0.0, alpha: 0.06).cgColor
                ]
        }

        visualEffectView.appearance = NSAppearance(named: useDark ? .darkAqua : .aqua)

        if let glass = nativeGlassView {
            glass.appearance = NSAppearance(named: useDark ? .darkAqua : .aqua)
            let tintSel = NSSelectorFromString("setTintColor:")
            if glass.responds(to: tintSel) {
                glass.setValue(tintColor, forKey: "tintColor")
            }
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tintLayer.backgroundColor = (nativeGlassView != nil) ? NSColor.clear.cgColor : tintColor.cgColor
        borderLayer.borderColor = borderColor.cgColor
        meniscusLayer.colors = meniscusColors
        meniscusLayer.isHidden = !showsSpecularRim
        CATransaction.commit()
    }
}
