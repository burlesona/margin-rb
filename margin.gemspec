require_relative 'lib/margin/version'

Gem::Specification.new do |spec|
  spec.name          = "margin"
  spec.version       = Margin::VERSION
  spec.authors       = ["Andrew Burleson"]
  spec.email         = ["burlesona@gmail.com"]

  spec.summary       = "Ruby parser for the Margin language."
  spec.description   = "Converts margin-formatted text into Ruby data (or the inverse), and can also import and export compatible JSON."
  spec.homepage      = "https://aburleson.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/burlesona/margin-rb"
  spec.metadata["changelog_uri"] = "https://github.com/burlesona/margin-rb"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
