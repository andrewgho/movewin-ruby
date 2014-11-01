# ========================================================================
# movewin.rb - Ruby native code that augments movewin_ext Ruby extension
# Andrew Ho (andrew@zeuscat.com)
#
# Copyright (c) 2014, Andrew Ho.
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

require 'movewin/movewin_ext'

module MoveWin
  VERSION = '1.7'

  # Individual accessors for display size components
  def self.display_width;  MoveWin.display_size[0]; end
  def self.display_height; MoveWin.display_size[1]; end

  class Window
    # Individual accessors and mutators for window position and size components
    def x; self.position[0]; end
    def y; self.position[1]; end
    def width;  self.size[0]; end
    def height; self.size[1]; end
    def x=(x); self.move!(x, self.position[1]); end
    def y=(y); self.move!(self.position[0], y); end
    def width=(width);   self.resize!(width, self.size[1]);  end
    def height=(height); self.resize!(self[0], height); end

    # Combined accessor and mutator for all window bounds together
    def bounds
      self.position + self.size
    end
    def bounds=(*args)
      x, y, width, height = args.flatten
      if x.nil? || y.nil?
        raise ArgumentError,
          'wrong number of arguments (2 coordinates required)'
      elsif width && height.nil?
        raise ArgumentError,
          'wrong number of arguments (height required if width specified)'
      end
      self.move!(x, y)
      self.resize!(width, height) if width && height
    end
    alias_method :set_bounds!, :bounds=
  end
end


# ========================================================================
