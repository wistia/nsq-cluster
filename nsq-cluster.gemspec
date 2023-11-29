Gem::Specification.new do |s|
  s.name = "nsq-cluster".freeze
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Wistia".freeze]
  s.date = "2017-04-08"
  s.description = "Setup nsqd, nsqlookupd, and nsqadmin in a jiffy. Great for testing!".freeze
  s.email = "dev@wistia.com".freeze
  s.executables = ["nsq-cluster".freeze]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = Dir.glob('lib/**/*.rb') + Dir.glob('bin/*') + ['LICENSE', 'README.md']
  s.homepage = "http://github.com/wistia/nsq-cluster".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Easily setup and manage a local NSQ cluster".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sys-proctable>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
    else
      s.add_dependency(%q<sys-proctable>.freeze, ["~> 1.2"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    end
  else
    s.add_dependency(%q<sys-proctable>.freeze, ["~> 1.2"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
  end
end
