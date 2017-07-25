import PackageDescription

let package = Package(
    name: "plaster",
    dependencies: [
        .Package(url: "https://github.com/SmallPlanetSporks/FileKit", Version(4, 0, 2)),
        .Package(url: "https://github.com/jatoben/CommandLine", Version(3, 0, 0, prereleaseIdentifiers: ["pre"], buildMetadataIdentifier: "1")),
    ]
)
