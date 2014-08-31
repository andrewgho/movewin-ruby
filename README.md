movewin - move windows from OS X command line
=============================================

This repository is the source code for the `lswin` and `movewin`
programs, which are OS X command line programs to list and move desktop
windows, respectively.

Getting Started
---------------

To install from RubyGems.org:

    $ gem install movewin

To install from this repository:

    $ gem build movewin.gemspec
    $ gem install movewin-1.0.gem

To build and use from this repository, without installing:

    $ (cd ext/movewin && ruby extconf.rb && make)
    $ ruby -Ilib:ext -rmovewin -e 'puts MoveWin.windows'

To list open windows, their locations, and sizes:

    $ ruby -e 'MoveWin.windows.each { |w| puts "%s - %s - %s %s" %
        [w.app_name, w.title, "%d %d" % w.position, "%d %d" % w.size] }'

To move a window from to the upper left corner:

    $ ruby -e 'MoveWin.windows.first.move!(0, 0)'

Listing and moving windows requires accessibility access to be enabled.

Description
-----------

This Ruby gem lists and moves OS X desktop windows using the OS X QUart 
window functions and accessibility APIs.

### Enabling Accessibility Access

The `movewin` program requires the "Enable access for assistive devices"
setting to be enabled in the "Accessibility" System Preferences pane in
OS X pre-Mavericks. To enable assistive UI scripting in Mavericks, see
this Apple KB article:
[http://support.apple.com/kb/HT5914](http://support.apple.com/kb/HT5914)

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
