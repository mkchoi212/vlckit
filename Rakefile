# Rakefile
# Copyright (C) 2018 Mike JS Choi
# Copyright (C) 2018 VLC authors and VideoLAN
# $Id$
#
# Authors: Mike JS. Choi <mkchoi212 # icloud.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
#
# ------------------------------------------------------------- Constants ------

PROJECT_MOBILE = 'MobileVLCKit.xcodeproj'

SDK_SIM = 'iphonesimulator11.3'
SDK_SIM_DEST = "'platform=iOS Simulator,name=iPhone 7,OS=11.3'"

SCHEME_IOS = 'MobileVLCKitTests'

VLC_FLAGS_IOS = '-dva x86_64'

CODECOV_PATH = 'Tests/Coverage'
SLATHER_CMD = "bundle exec slather coverage --ignore 'Tests/*'"

# ----------------------------------------------------------------- Tasks ------

desc 'Build VLCKit (iOS)'
task 'build:vlckit:ios' do
  puts 'Building VLCKit (iOS)'

  plugin_file = 'Resources/MobileVLCKit/vlc-plugins-iPhone.h'
  required_dirs = ['./libvlc/vlc/install-iPhoneSimulator', './libvlc/vlc/build-iPhoneSimulator']

  if File.exist?(plugin_file) && dirs_exist?(required_dirs)
    puts 'Found pre-existing build directory. Skipping build'
  else
    sh "./compileAndBuildVLCKit.sh #{VLC_FLAGS_IOS}"
  end
end

desc 'Run MobileVLCKit tests'
task 'test:ios' do
  puts 'Running tests for MobileVLCKit'
  run "xcodebuild -project #{PROJECT_MOBILE} -scheme #{SCHEME_IOS} -sdk #{SDK_SIM} -destination #{SDK_SIM_DEST} test | xcpretty && exit ${PIPESTATUS[0]}"
end

desc 'Generate code coverage reports (iOS)'
task 'codecov:ios' do
  puts 'Generating code coverage reports (iOS)'
  generate_coverage(SCHEME_IOS, PROJECT_MOBILE)
end

# ------------------------------------------------------------- Functions ------

def generate_coverage(scheme, project)
  run "#{SLATHER_CMD} -s --scheme #{scheme} #{project} | grep -v 'Slather*'"
  run "#{SLATHER_CMD} --html --output-directory #{CODECOV_PATH}/#{scheme} --scheme #{scheme} #{project}", quiet: true
end

def dirs_exist?(directories)
  directories.each do |dir|
    return false unless Dir.exist?(dir)
  end
end

def run(command, options = {})
  system_options = {}
  system_options[:out] = File::NULL if options[:quiet]
  system(command.to_s, system_options) || exit!
end
