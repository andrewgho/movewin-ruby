#!/usr/bin/env ruby

require 'mkmf'
require 'rubygems'

def main(argv = [])
  $CFLAGS = '-Wall'
  $LDFLAGS = '-Wall -framework Carbon'

  # No have_framework() in mkmf that ships with Ruby versions earlier than 1.9
  if ruby_older_than?('1.9')
    have_header('Carbon/Carbon.h')
  else
    have_framework('Carbon')
  end

  # On Yosemite or newer, fix bug in Carbon header that breaks under gcc
  if yosemite_or_newer? && using_gcc?
    fix_dispatch_object_header!
  end

  create_makefile('movewin/movewin_ext')
end

# Return true if current Ruby version is older than given version
def ruby_older_than?(version)
  Gem::Version.new(RUBY_VERSION) < Gem::Version.new(version)
end

# Return true if this is OS X 10.10 (Yosemite) or newer
def yosemite_or_newer?
  Gem::Version.new(`sw_vers -productVersion`) >= Gem::Version.new('10.10')
end

# Return true if our compiler is GCC (not clang), as for RVM installed Ruby
def using_gcc?
  true  # TODO: make this really work
end

# Building with GCC on Yosemite (OS X 10.10) results in an error
# (https://github.com/andrewgho/movewin-ruby/issues/1).
# Patch header file to work around this issue.
def fix_dispatch_object_header!
  srcfile = find_header_file('dispatch/object.h')
  tmpfile = "#{File.dirname(__FILE__)}/dispatch/object.h.tmp.#{$$}"
  begin
    patched = false
    File.open(tmpfile, 'w') do |tmpfh|
      File.open(srcfile, 'r').each do |srcline|
        patched ||= srcline.sub!(
          /\Atypedef void \(\^dispatch_block_t\)\(void\);/,
          'typedef void* dispatch_block_t;'
        )
        tmpfh.print(srcline)
      end
    end
    if patched
      destfile = "#{File.dirname(__FILE__)}/dispatch/object.h"
      File.rename(tmpfile, destfile)
      if $CFLAGS.nil? || $CFLAGS.empty?
        $CFLAGS = "-I#{File.dirname(__FILE__)}"
      else
        $CFLAGS += " -I#{File.dirname(__FILE__)}"
      end
      set_constant!(:CLEANINGS, "CLEANFILES += dispatch/object.h\n" + CLEANINGS)
    end
  ensure
    File.unlink(tmpfile) if File.exists?(tmpfile)
  end
end

# Given an #include <foo/bar.h>, return actual filename /path/to/foo/bar.h
def find_header_file(header)
  # TODO: really crawl through cpp include path to find this
  "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/#{header}"
end

# Redefine constant without warning (http://stackoverflow.com/q/3375360)
class Object
  def set_constant!(const, value)
    mod = self.is_a?(Module) ? self : self.class
    mod.send(:remove_const, const) if mod.const_defined?(const)
    mod.const_set(const, value)
  end
end

# Run main loop and exit
exit(main(ARGV))
