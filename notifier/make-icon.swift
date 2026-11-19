// Draws the notifier's app icon: the Lucide lightbulb (icons/lightbulb.svg) in white
// on a warm amber rounded tile, sized to the macOS icon grid.
//
// Usage: swift notifier/make-icon.swift <output.iconset>
// scripts/build-notifier.sh --icon runs this and turns the result into notifier/AppIcon.icns.

import AppKit

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
guard CommandLine.arguments.count == 2 else { print("usage: make-icon.swift <out.iconset>"); exit(1) }
let out = URL(fileURLWithPath: CommandLine.arguments[1])
guard let bulb = NSImage(contentsOf: root.appendingPathComponent("icons/lightbulb.svg")) else {
    print("couldn't load icons/lightbulb.svg"); exit(1)
}
try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext

    // Tile: 824/1024 of the canvas with a 185/1024 corner radius, as in Apple's icon template.
    let tile = NSRect(x: s * 100 / 1024, y: s * 100 / 1024, width: s * 824 / 1024, height: s * 824 / 1024)
    let shape = NSBezierPath(roundedRect: tile, xRadius: s * 185 / 1024, yRadius: s * 185 / 1024)

    ctx.saveGState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
    shadow.shadowOffset = NSSize(width: 0, height: -s * 10 / 1024)
    shadow.shadowBlurRadius = s * 20 / 1024
    shadow.set()
    NSColor.black.setFill()
    shape.fill()
    ctx.restoreGState()

    NSGradient(colors: [NSColor(srgbRed: 1.00, green: 0.80, blue: 0.33, alpha: 1),
                        NSColor(srgbRed: 0.98, green: 0.52, blue: 0.13, alpha: 1)])!
        .draw(in: shape, angle: -90)

    // Bulb: render the SVG, then recolor its black strokes white.
    let side = s * 560 / 1024
    let bulbRect = NSRect(x: (s - side) / 2, y: (s - side) / 2 + s * 8 / 1024, width: side, height: side)
    let white = NSImage(size: bulbRect.size, flipped: false) { r in
        bulb.draw(in: r)
        NSColor.white.set()
        r.fill(using: .sourceAtop)
        return true
    }
    ctx.saveGState()
    let glow = NSShadow()
    glow.shadowColor = NSColor(srgbRed: 0.55, green: 0.22, blue: 0.0, alpha: 0.35)
    glow.shadowOffset = NSSize(width: 0, height: -s * 6 / 1024)
    glow.shadowBlurRadius = s * 14 / 1024
    glow.set()
    white.draw(in: bulbRect)
    ctx.restoreGState()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

for pt in [16, 32, 128, 256, 512] {
    try render(pt).write(to: out.appendingPathComponent("icon_\(pt)x\(pt).png"))
    try render(pt * 2).write(to: out.appendingPathComponent("icon_\(pt)x\(pt)@2x.png"))
}
print("Wrote \(out.path)")
