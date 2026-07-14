import AppKit

public struct NormalizedClipboardImage {
    public let pngData: Data
    public let tiffData: Data
    public let sourcePixelSize: NSSize
    public let targetPixelSize: NSSize

    public var wasDownsampled: Bool {
        sourcePixelSize != targetPixelSize
    }
}

public enum ClipboardImageNormalizer {
    private static let scaleTolerance = 1.1

    public static func normalize(_ image: NSImage) -> NormalizedClipboardImage? {
        guard let sourceRep = bestBitmapRepresentation(in: image) else {
            return nil
        }

        let sourceWidth = sourceRep.pixelsWide
        let sourceHeight = sourceRep.pixelsHigh
        guard sourceWidth > 0, sourceHeight > 0 else {
            return nil
        }

        let logicalSize = validLogicalSize(image.size)
            ?? validLogicalSize(sourceRep.size)
            ?? NSSize(width: sourceWidth, height: sourceHeight)

        let scaleX = CGFloat(sourceWidth) / logicalSize.width
        let scaleY = CGFloat(sourceHeight) / logicalSize.height
        let hasRetinaScale = scaleX >= scaleTolerance || scaleY >= scaleTolerance

        let targetWidth = hasRetinaScale
            ? max(1, Int(logicalSize.width.rounded()))
            : sourceWidth
        let targetHeight = hasRetinaScale
            ? max(1, Int(logicalSize.height.rounded()))
            : sourceHeight

        guard let rendered = render(
            image,
            pixelsWide: targetWidth,
            pixelsHigh: targetHeight
        ) else {
            return nil
        }

        guard
            let pngData = rendered.representation(using: .png, properties: [:]),
            let tiffData = rendered.representation(using: .tiff, properties: [:])
        else {
            return nil
        }

        return NormalizedClipboardImage(
            pngData: pngData,
            tiffData: tiffData,
            sourcePixelSize: NSSize(width: sourceWidth, height: sourceHeight),
            targetPixelSize: NSSize(width: targetWidth, height: targetHeight)
        )
    }

    private static func bestBitmapRepresentation(in image: NSImage) -> NSBitmapImageRep? {
        if let bitmap = image.representations
            .compactMap({ $0 as? NSBitmapImageRep })
            .max(by: { lhs, rhs in
                lhs.pixelsWide * lhs.pixelsHigh < rhs.pixelsWide * rhs.pixelsHigh
            }) {
            return bitmap
        }

        guard let tiffData = image.tiffRepresentation else {
            return nil
        }

        return NSBitmapImageRep(data: tiffData)
    }

    private static func validLogicalSize(_ size: NSSize) -> NSSize? {
        guard
            size.width.isFinite,
            size.height.isFinite,
            size.width > 0,
            size.height > 0
        else {
            return nil
        }

        return size
    }

    private static func render(
        _ image: NSImage,
        pixelsWide: Int,
        pixelsHigh: Int
    ) -> NSBitmapImageRep? {
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelsWide,
            pixelsHigh: pixelsHigh,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bitmapFormat: [],
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return nil
        }

        bitmap.size = NSSize(width: pixelsWide, height: pixelsHigh)
        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            return nil
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.imageInterpolation = .high
        image.draw(
            in: NSRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh),
            from: NSRect(origin: .zero, size: image.size),
            operation: .copy,
            fraction: 1,
            respectFlipped: false,
            hints: [.interpolation: NSImageInterpolation.high]
        )
        context.flushGraphics()
        NSGraphicsContext.restoreGraphicsState()

        return bitmap
    }
}
