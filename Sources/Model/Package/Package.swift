import Foundation

// MARK: - Package

/// A simplified Swift Package manifest
public struct Package {
  // MARK: Lifecycle

  public init(
    name: String,
    targets: [Target]
  ) {
    self.name = name
    self.targets = targets
  }

  // MARK: Public

  public var name: String
  public var targets: [Target]
}

// MARK: - Target

/// A simplified target definition
public struct Target {
  // MARK: Lifecycle

  public init(
    name: String,
    type: TargetType,
    path: String? = nil,
    exclude: [String]? = nil,
    dependencies: [TargetDependency]
  ) {
    self.name = name
    self.type = type
    self.path = path
    self.exclude = exclude
    self.dependencies = dependencies
  }

  // MARK: Public

  public var name: String
  public var type: TargetType
  public var path: String?
  public var exclude: [String]?
  public var dependencies: [TargetDependency]
}

// MARK: Target.TargetType

extension Target {
  /// The type of target
  public enum TargetType: String {
    case regular
    case test
    case executable
  }
}

// MARK: - TargetDependency

/// A simplified target dependency
public enum TargetDependency {
  case local(LocalDependency)
  case external(ExternalDependency)
}

// MARK: TargetDependency.LocalDependency

extension TargetDependency {
  /// A dependency to another target in the same manifest
  public struct LocalDependency {
    // MARK: Lifecycle

    public init(name: String) {
      self.name = name
    }

    // MARK: Public

    public var name: String
  }
}

// MARK: TargetDependency.ExternalDependency

extension TargetDependency {
  /// A dependency to a build product from another package
  public struct ExternalDependency {
    // MARK: Lifecycle

    public init(
      name: String,
      package: String
    ) {
      self.name = name
      self.package = package
    }

    // MARK: Public

    public var name: String
    public var package: String
  }
}

extension TargetDependency {
  /// A convenience accessor for a dependency name
  public var name: String {
    switch self {
    case .local(let dependency):
      dependency.name

    case .external(let dependency):
      dependency.name
    }
  }
}

// MARK: - Package + Hashable

extension Package: Hashable {}

// MARK: - Target + Hashable

extension Target: Hashable {}

// MARK: - Target.TargetType + Hashable

extension Target.TargetType: Hashable {}

// MARK: - TargetDependency + Hashable

extension TargetDependency: Hashable {}

// MARK: - TargetDependency.ExternalDependency + Hashable

extension TargetDependency.ExternalDependency: Hashable {}

// MARK: - TargetDependency.LocalDependency + Hashable

extension TargetDependency.LocalDependency: Hashable {}

// MARK: - Package + Codable

extension Package: Codable {}

// MARK: - Target + Codable

extension Target: Codable {}

// MARK: - Target.TargetType + Codable

extension Target.TargetType: Codable {}

// MARK: - TargetDependency + Decodable

extension TargetDependency: Decodable {
  public enum CodingKeys: String, CodingKey {
    case byName
    case product
  }

  public enum DecodingError: Error {
    case malformedJSON
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    switch container.allKeys.first {
    case .none:
      throw DecodingError.malformedJSON

    case .byName:
      // Encoded as: ``byName(name:condition:)``
      let value = try container.decode([String?].self, forKey: .byName)
      guard let name = value.first ?? nil else { throw DecodingError.malformedJSON }
      self = .local(.init(name: name))

    case .product:
      // Encoded as: ``product(name:package:moduleAliases:condition:)``
      let value = try container.decode([String?].self, forKey: .product)
      guard let name = value.first ?? nil else { throw DecodingError.malformedJSON }
      guard let package = value[1...].first ?? nil else { throw DecodingError.malformedJSON }
      self = .external(.init(name: name, package: package))
    }
  }
}

// MARK: - TargetDependency + Encodable

extension TargetDependency: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .local(let dependency):
      try container.encode(dependency, forKey: .byName)

    case .external(let dependency):
      try container.encode(dependency, forKey: .product)
    }
  }
}

// MARK: - TargetDependency.LocalDependency + Codable

extension TargetDependency.LocalDependency: Codable {}

// MARK: - TargetDependency.ExternalDependency + Codable

extension TargetDependency.ExternalDependency: Codable {}
