# ========================================================================
# movewin.gemspec - RubyGem specification for movewin gem
# Andrew Ho (andrew@zeuscat.com)
#
# Copyright (c) 2014-2020, Andrew Ho.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# Neither the name of the author nor the names of its contributors may
# be used to endorse or promote products derived from this software
# without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ========================================================================

Gem::Specification.new do |s|
  s.name        = 'movewin'
  s.version     = '1.11'
  s.summary     = 'List and move OS X windows from Ruby'
  s.description =
    'List and move OS X windows from Ruby via the OS X accessibility APIs.'
  s.authors     = ['Andrew Ho']
  s.email       = 'andrew@zeuscat.com'
  s.files       = Dir['lib/*.rb'] +
                  Dir['ext/movewin/*.[ch]'] +
                  ['ext/movewin/dispatch/empty.rb']
  s.extensions  = %w{ext/movewin/extconf.rb}
  s.homepage    = 'https://github.com/andrewgho/movewin-ruby'
  s.license     = 'BSD-3-Clause'
end


# ========================================================================
