movewin-ruby - list and move OS X windows from Ruby
===================================================

This repository is the source code for the `movewin` Ruby gem, which is
a Ruby library to list and move OS X desktop windows.

Getting Started
---------------

To install from RubyGems.org:

    $ gem install movewin

To install from this repository:

    $ gem build movewin.gemspec
    $ gem install movewin-1.4.gem

To build and use from this repository, without installing:

    $ (cd ext/movewin && ruby extconf.rb && make)
    $ ruby -Ilib:ext -rmovewin -e 'puts MoveWin.windows'

To list open windows, their locations, and sizes:

    $ ruby -rubygems -e 'require "movewin";
        puts MoveWin.windows.collect { |w| "%s - %s - %d %d %d %d" %
        [w.app_name, w.title, w.position, w.size].flatten }'

To move a window from to the upper left corner:

    $ ruby -rubygems -e 'require "movewin";
        MoveWin.windows.first.move!(0, 0)'

Listing and moving windows requires accessibility access to be enabled.

Description
-----------

This Ruby gem lists and moves OS X desktop windows using the OS X Quartz
window functions and accessibility APIs.

### Methods

To return true or false, signifying whether the current process is
authorized to use OS X accessibility APIs:

    abort 'not authorized to use accessibility APIs' unless MoveWin.authorized?

To get the dimensions of the current display:

    width, height = MoveWin.display_size
    width = MoveWin.display_width
    height = MoveWin.display_height

To get an array of `MoveWin::Window` objects:

    windows = MoveWin.windows
    w = windows.first

`MoveWin::Window` objects have an application name (like `iTerm` or
`Firefox`) and a window title (like `Default` or
`andrewgho/movewin-ruby`), and can be queried for position, size, or
both:

    app_name = window.app_name
    title = window.title
    x, y = window.position
    width, height = window.size
    x, y, width, height = window.bounds

There are also convenience functions for if you just need a single
coordinate or dimension for a window:

    x = window.x
    y = window.y
    width = window.width
    height = window.height

Windows can be moved, resized, or moved and resized in a single call:

    w.move!(new_x, new_y)
    w.position = [new_x, new_y]
    w.resize!(new_width, new_height)
    w.size = [new_width, new_height]
    w.set_bounds!(new_x, new_y, new_width, new_height)
    w.bounds = [new_x, new_y, new_width, new_height]
    w.x = new_x
    w.y = new_y
    w.width = new_width
    w.height = new_height

### Enabling Accessibility Access

The `movewin` program requires the "Enable access for assistive devices"
setting to be enabled in the "Accessibility" System Preferences pane in
OS X pre-Mavericks. To enable assistive UI scripting in Mavericks, see
this Apple KB article:
[http://support.apple.com/kb/HT5914](http://support.apple.com/kb/HT5914)

### See Also

The source code for this Ruby gem can be found on GitHub:

* https://github.com/andrewgho/movewin-ruby

The source code for for the winutils library (files `winutils.h` and
`winutils.c`) are duplicated from the `movewin` repository, which
includes command line tools for listing and moving windows:

* https://github.com/andrewgho/movewin

Author
------

Andrew Ho (<andrew@zeuscat.com>)

License
-------

    Copyright (c) 2014, Andrew Ho.
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    
    Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    
    Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    
    Neither the name of the author nor the names of its contributors may
    be used to endorse or promote products derived from this software
    without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
