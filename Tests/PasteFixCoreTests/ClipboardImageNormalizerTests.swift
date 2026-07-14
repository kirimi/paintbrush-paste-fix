import AppKit
import XCTest
@testable import PasteFixCore

final class ClipboardImageNormalizerTests: XCTestCase {
    func testDownsamplesTwoTimesRetinaRepresentationToLogicalSize() throws {
        let image = try makeImage(
            pixelsWide: 200,
            pixelsHigh: 100,
            logicalWidth: 100,
            logicalHeight: 50
        )

        let normalized = try XCTUnwrap(ClipboardImageNormalizer.normalize(image))

        XCTAssertEqual(normalized.sourcePixelSize, NSSize(width: 200, height: 100))
        XCTAssertEqual(normalized.targetPixelSize, NSSize(width: 100, height: 50))
        XCTAssertTrue(normalized.wasDownsampled)

        let output = try XCTUnwrap(NSBitmapImageRep(data: normalized.pngData))
        XCTAssertEqual(output.pixelsWide, 100)
        XCTAssertEqual(output.pixelsHigh, 50)
    }

    func testKeepsOneTimesImagePixelSize() throws {
        let image = try makeImage(
            pixelsWide: 120,
            pixelsHigh: 80,
            logicalWidth: 120,
            logicalHeight: 80
        )

        let normalized = try XCTUnwrap(ClipboardImageNormalizer.normalize(image))

        XCTAssertEqual(normalized.targetPixelSize, NSSize(width: 120, height: 80))
        XCTAssertFalse(normalized.wasDownsampled)
    }

    private func makeImage(
        pixelsWide: Int,
        pixelsHigh: Int,
        logicalWidth: CGFloat,
        logicalHeight: CGFloat
    ) throws -> NSImage {
        let bitmap = try XCTUnwrap(NSBitmapImageRep(
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
        ))
        bitmap.size = NSSize(width: logicalWidth, height: logicalHeight)

        let image = NSImage(size: NSSize(width: logicalWidth, height: logicalHeight))
        image.addRepresentation(bitmap)
        return image
    }
}
