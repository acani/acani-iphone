require 'frank-cucumber'

ENV['APP_BUNDLE_PATH'] = File.expand_path(File.join(File.dirname(__FILE__),
    "..", "..", "build", "Release-iphonesimulator", "Features.app"))
