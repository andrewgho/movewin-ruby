require 'mkmf'

# No have_framework() in mkmf that ships with Ruby versions earlier than 1.9
RUBY_VERSIONS = RUBY_VERSION.split('.').collect { |s| s.to_i }
unless RUBY_VERSIONS[0] < 1 || (RUBY_VERSIONS[0] == 1 && RUBY_VERSIONS[1] < 9)
  have_framework('Carbon')
end
have_header('Carbon/Carbon.h')

$CFLAGS = '-Wall'
$LDFLAGS = '-Wall -framework Carbon'

create_makefile('movewin/movewin_ext')
