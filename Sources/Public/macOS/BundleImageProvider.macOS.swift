//
//  LottieBundleImageProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

#if os(macOS)
import AppKit

/// Provides an image for a lottie animation from a provided Bundle.
public class BundleImageProvider: AnimationImageProvider {

  // MARK: Lifecycle

  /// Initializes an image provider with a bundle and an optional subpath.
  ///
  /// Provides images for an animation from a bundle. Additionally the provider can
  /// search a specific subpath for the images.
  ///
  /// - Parameter bundle: The bundle containing images for the provider.
  /// - Parameter searchPath: The subpath is a path within the bundle to search for image assets.
  ///
  public init(bundle: Bundle, searchPath: String?) {
    self.bundle = bundle
    self.searchPath = searchPath
  }

  // MARK: Public

  public func imageForAsset(asset: ImageAsset) -> CGImage? {

    if
      asset.name.hasPrefix("data:"),
      let url = URL(string: asset.name),
      let data = try? Data(contentsOf: url),
      let image = NSImage(data: data)
    {
      return image.CGImage
    }

    let imagePath: String?
    /// Try to find the image in the bundle.
    if let searchPath = searchPath {
      /// Search in the provided search path for the image
      var directoryPath = URL(fileURLWithPath: searchPath)
      directoryPath.appendPathComponent(asset.directory)

      if let path = bundle.path(forResource: asset.name, ofType: nil, inDirectory: directoryPath.path) {
        /// First search for the image in the asset provided sub directory.
        imagePath = path
      } else if let path = bundle.path(forResource: asset.name, ofType: nil, inDirectory: searchPath) {
        /// Try finding the image in the search path.
        imagePath = path
      } else {
        imagePath = bundle.path(forResource: asset.name, ofType: nil)
      }
    } else {
      if let path = bundle.path(forResource: asset.name, ofType: nil, inDirectory: asset.directory) {
        /// First search for the image in the asset provided sub directory.
        imagePath = path
      } else {
        /// First search for the image in bundle.
        imagePath = bundle.path(forResource: asset.name, ofType: nil)
      }
    }

    guard let foundPath = imagePath, let image = NSImage(contentsOfFile: foundPath) else {
      /// No image found.
      LottieLogger.shared.assertionFailure("Could not find image \"\(asset.name)\" in bundle")
      return nil
    }
    return image.CGImage
  }

  // MARK: Internal

  let bundle: Bundle
  let searchPath: String?
}

#endif
