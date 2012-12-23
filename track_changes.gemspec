$:.push File.expand_path("../lib", __FILE__)
require "track_changes/version"

Gem::Specification.new do |s|
  s.name = "track_changes"
  s.version = TrackChanges::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["k1w1"]
  s.email = ["k1w1@k1w1.org"]
  s.homepage = "http://github.com/k1w1/track_changes"
  s.summary = %q{todo}
  s.description = %q{todo}

  s.files = Dir["lib/**/*" "README.md", "MIT-LICENSE"]
  s.require_paths = ["lib"]
  s.test_files = Dir.glob('spec/**/*')

  s.add_dependency 'diff_match_patch'
  
  s.add_development_dependency "rspec"
end