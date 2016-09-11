version = '0.1.0'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "nlu"
  s.version     = version
  s.summary     = ""
  s.description = ""

  s.required_ruby_version     = ">= 2.1.0"
  s.required_rubygems_version = ">= 1.8.11"

  s.license = "MIT"

  s.author   = "Alexandre de Oliveira"
  s.email    = "chavedomundo@gmail.com"
  s.homepage = "http://github.com/kurko/nlu"

  s.files = Dir.glob("{nlu_generalization,nlu_timeline,sentence_organization}/**/*") + %w(nlu.rb README.md)

  s.add_dependency "text", "~>1.3.1"

  s.add_development_dependency "rspec", ">= 3.1.0"
  s.add_development_dependency "pry", "~> 0.10.4"
  s.add_development_dependency "awesome_print", "~> 1.7.0"
end
