require_relative "lib/lzstring/version"

Gem::Specification.new do |spec|
  spec.name          = "lzstring"
  spec.version       = LZString::VERSION
  spec.authors       = ["kiwamizamurai"]
  spec.email         = [""]

  spec.summary       = "Ruby implementation of lz-string, a string compression algorithm"
  spec.description   = "A Ruby implementation of lz-string, designed to be compatible with the " \
                       "JavaScript library for string compression and decompression"
  spec.homepage      = "https://github.com/kiwamizamurai/lzstring-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  # 公開用のメタデータ
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true" # MFA保護を有効化

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Development dependencies
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "simplecov", "~> 0.21.2"
  spec.add_development_dependency "yard", "~> 0.9.28"
end
