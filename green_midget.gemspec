# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "green_midget/version"

Gem::Specification.new do |s|
  s.name        = "green_midget"
  s.version     = GreenMidget::VERSION
  s.authors     = ["nikola chochkov"]
  s.email       = ["nikola@howkul.info"]
  s.homepage    = "http://github.com/chochkov/GreenMidget"
  s.licenses    = ["MIT"]
  s.require_paths    = ["lib"]
  s.rubygems_version = %q{1.7.2}
  s.summary     = %q{Bayesian Text Classifier}
  s.description = %q{Naive Bayesian Classifier with customizable features}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activerecord"
end
