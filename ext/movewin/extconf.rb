#!/usr/bin/env ruby

require 'mkmf'
require 'rubygems'

def main(argv = [])
  $CFLAGS = '-Wall'
  $LDFLAGS = '-Wall -framework Carbon'

  have_header('Carbon/Carbon.h')

  # On Yosemite or newer, fix bug in Carbon header that breaks under gcc
  if yosemite_or_newer? && using_gcc?
    fix_dispatch_object_header!
  end

  create_makefile('movewin/movewin_ext')
end

# Return true if this is OS X 10.10 (Yosemite) or newer
def yosemite_or_newer?
  Gem::Version.new(`sw_vers -productVersion`) >= Gem::Version.new('10.10')
end

# Return true if our compiler is GCC (not Clang), as for RVM installed Ruby
def using_gcc?
  # Match gcc, /usr/local/bin/gcc-4.2, etc. (Clang is "xcrun cc")
  File.basename(RbConfig::MAKEFILE_CONFIG["CC"]).match(/\Agcc\b/)
end

# Building with GCC on Yosemite (OS X 10.10) results in an error
# (https://github.com/andrewgho/movewin-ruby/issues/1).
# Patch header file to work around this issue.
def fix_dispatch_object_header!
  $stdout.print 'Creating patched copy of dispatch/object.h... '
  $stdout.flush
  status = 'failed'
  if (srcfile = find_header_file('dispatch/object.h'))
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
        set_constant! :CLEANINGS,
          "DISTCLEANFILES += dispatch/object.h\n" + CLEANINGS
        status = "patched: #{destfile}"
      else
        status = 'skipped'
      end
    ensure
      File.unlink(tmpfile) if File.exists?(tmpfile)
    end
  else
    status = 'header not found'
  end
  $stdout.puts status
  $stdout.flush
end

# Given an #include <dispatch/object.h>, return actual filename
# /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/dispatch/object.h
def find_header_file(header)
  filename = nil
  header_include_paths.each do |path|
    maybe_filename = "#{path}/#{header}"
    if File.exists?(maybe_filename)
      filename = maybe_filename
      break
    end
  end
  filename
end

# Return GCC header include path
# (http://stackoverflow.com/a/19839946, http://stackoverflow.com/a/19852298)
# gcc -Wp,-v -xc /dev/null -fsyntax-only 2>&1
def header_include_paths
  cmd = RbConfig::MAKEFILE_CONFIG["CC"]
  args = %w{-Wp -v -xc /dev/null -fsyntax-only}
  paths = []
  reading_paths = false
  run_command(cmd, *args) do |line|
    if reading_paths
      if line.chomp.match(/\A\QEnd of search list.\E\Z/)
        reading_paths = false
      elsif line.match(/\A \//)
        line.strip!
        line.sub!(/\s+\(framework directory\)\Z/, '')
        paths << line
      end
    elsif line.chomp.match(/\A\Q#include <...> search starts here:\E\Z/)
      reading_paths = true
    end
  end
  paths
end

# Safely run a command with no shell escapes, pass output lines to callback
def run_command(cmd, *args)
  raise ArgumentError.new('missing required cmd to run') if cmd.nil?
  rd, wr = IO.pipe
  if fork
    wr.close
    if block_given?
      rd.each { |line| yield(line) }
    else
      rd.read
    end
    rd.close
    Process.wait
  else
    rd.close
    $stdout.reopen(wr)
    $stderr.reopen(wr)
    exec cmd, *args
    raise "exec #{cmd} failed"
  end
  $? == 0 # return a bool indicating a successful exit
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
