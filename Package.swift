import PackageDescription

let package = Package(
    name: "plaster",
    dependencies: [
	.Package(url: "https://github.com/qmchenry/FileKit.git", Version(4, 0, 2, prereleaseIdentifiers: ["pre"], buildMetadataIdentifier: "1")),
        .Package(url: "https://github.com/jatoben/CommandLine.git", Version(3, 0, 0, prereleaseIdentifiers: ["pre"], buildMetadataIdentifier: "1")),
    ]
)
