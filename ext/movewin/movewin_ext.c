/* ========================================================================
 * movewin_ext.c - Ruby extension to list and move OS X windows
 * Andrew Ho (andrew@zeuscat.com)
 *
 * Copyright (c) 2014, Andrew Ho.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the author nor the names of its contributors may
 * be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * ========================================================================
 */

#include <ruby.h>
#include "winutils.h"

/* Global MoveWin::Window handle, so StoreWindows() can create objects */
static VALUE MW_WindowClass;

/* Ruby extension setup code */
void Init_movewin_ext();

/* Ruby method implementations */
VALUE MW_is_authorized(VALUE module);   /* MoveWin.authorized? */
VALUE MW_display_size(VALUE module);    /* MoveWin.display_size */
VALUE MW_windows(VALUE module);         /* MoveWin.windows */
VALUE MW_Window_app_name(VALUE self);   /* MoveWin::Window.app_name */
VALUE MW_Window_title(VALUE self);      /* MoveWin::Window.title */
VALUE MW_Window_position(VALUE self);   /* MoveWin::Window.position */
VALUE MW_Window_size(VALUE self);       /* MoveWin::Window.size */
VALUE MW_Window_set_position(VALUE self, VALUE args);  /* position=, move! */
VALUE MW_Window_set_size(VALUE self, VALUE args);      /* size=, resize! */
VALUE MW_Window_to_string(VALUE self);  /* MoveWin::Window.to_s */

/* MW_Window is a structure that holds CFDictionaryRef and AXUIElementRefs */
typedef struct {
    CFDictionaryRef cgWindow;
    AXUIElementRef axWindow;
} MW_Window;

/* EnumerateWindows callback creates and stores MW_Windows in Ruby array */
void StoreWindows(CFDictionaryRef cgWindow, void *rb_ary_ptr);

/* Callback for Data_Wrap_Struct(), frees internal refs with CFRelease() */
void MW_Window_destroy(void *ref);

/* Check if VALUE is number or has to_i() method; get number as integer */
static bool canGetNumber(VALUE v);
static int getNumber(VALUE v);

/* Copy contents of a CFStringRef into a Ruby string */
static VALUE convertStringRef(CFStringRef str);


/* ------------------------------------------------------------------------
 * Public implementation
 */

/* Define Ruby MoveWin module, MoveWin::Window class, and related methods */
void Init_movewin_ext() {
    VALUE MW_Module;

    /* Define module MoveWin and its methods */
    MW_Module = rb_define_module("MoveWin");
    rb_define_singleton_method(MW_Module, "authorized?",  MW_is_authorized, 0);
    rb_define_singleton_method(MW_Module, "display_size", MW_display_size,  0);
    rb_define_singleton_method(MW_Module, "windows",      MW_windows,       0);

    /* Define class MoveWin::Window and its methods */
    MW_WindowClass = rb_define_class_under(MW_Module, "Window", rb_cObject);
    rb_define_method(MW_WindowClass, "app_name",  MW_Window_app_name,      0);
    rb_define_method(MW_WindowClass, "title",     MW_Window_title,         0);
    rb_define_method(MW_WindowClass, "position",  MW_Window_position,      0);
    rb_define_method(MW_WindowClass, "size",      MW_Window_size,          0);
    rb_define_method(MW_WindowClass, "position=", MW_Window_set_position, -2);
    rb_define_method(MW_WindowClass, "size=",     MW_Window_set_size,     -2);
    rb_define_method(MW_WindowClass, "move!",     MW_Window_set_position, -2);
    rb_define_method(MW_WindowClass, "resize!",   MW_Window_set_size,     -2);
    rb_define_method(MW_WindowClass, "to_s",      MW_Window_to_string,     0);
}

/* Return true if we are authorized to use OS X accessibility APIs */
VALUE MW_is_authorized(VALUE module) {
    return isAuthorized() ? Qtrue : Qfalse;
}

/* Return dimensions of current main display as an array of two integers */
VALUE MW_display_size(VALUE module) {
    CGRect bounds;
    VALUE retval;

    bounds = CGDisplayBounds(CGMainDisplayID());
    retval = rb_ary_new();
    rb_ary_push(retval, INT2NUM((int)CGRectGetMaxX(bounds)));
    rb_ary_push(retval, INT2NUM((int)CGRectGetMaxY(bounds)));

    return retval;
}

/* Return an array of MoveWin::Window objects (wrapped MW_Window structures) */
VALUE MW_windows(VALUE module) {
    VALUE retval = rb_ary_new();
    EnumerateWindows(NULL, StoreWindows, (void *)retval);
    return retval;
}

/* Return application name (owner) of a MoveWin::Window as a Ruby string */
VALUE MW_Window_app_name(VALUE self) {
    void *mwWindow;
    CFStringRef app_name;

    Data_Get_Struct(self, MW_Window, mwWindow);
    app_name = CFDictionaryGetValue(
        ((MW_Window *)mwWindow)->cgWindow, kCGWindowOwnerName
    );

    return convertStringRef(app_name);
}

/* Return title of a MoveWin::Window as a Ruby string */
VALUE MW_Window_title(VALUE self) {
    void *mwWindow;
    CFStringRef title;

    Data_Get_Struct(self, MW_Window, mwWindow);
    AXUIElementCopyAttributeValue(
        ((MW_Window *)mwWindow)->axWindow, kAXTitleAttribute, (CFTypeRef *)&title
    );

    return convertStringRef(title);
}

/* Return position of a MoveWin::Window as array of two integer coordinates */
VALUE MW_Window_position(VALUE self) {
    void *mwWindow;
    CGPoint position;
    VALUE retval;

    Data_Get_Struct(self, MW_Window, mwWindow);
    position = AXWindowGetPosition(((MW_Window *)mwWindow)->axWindow);
    retval = rb_ary_new();
    rb_ary_push(retval, INT2NUM((int)position.x));
    rb_ary_push(retval, INT2NUM((int)position.y));

    return retval;
}

/* Return position of a MoveWin::Window as array of two integer dimensions */
VALUE MW_Window_size(VALUE self) {
    void *mwWindow;
    CGSize size;
    VALUE retval;

    Data_Get_Struct(self, MW_Window, mwWindow);
    size = AXWindowGetSize(((MW_Window *)mwWindow)->axWindow);
    retval = rb_ary_new();
    rb_ary_push(retval, INT2NUM((int)size.width));
    rb_ary_push(retval, INT2NUM((int)size.height));

    return retval;
}

/* Given two integers, or array of two integers, set position of window */
VALUE MW_Window_set_position(VALUE self, VALUE args) {
    CGPoint position;
    void *mwWindow;

    if(RARRAY_LEN(args) == 1 && TYPE(rb_ary_entry(args, 0)) == T_ARRAY) {
        args = rb_ary_entry(args, 0);
    }
    if( RARRAY_LEN(args) == 2 &&
        canGetNumber(rb_ary_entry(args, 0)) &&
        canGetNumber(rb_ary_entry(args, 1)) )
    {
        position.x = getNumber(rb_ary_entry(args, 0));
        position.y = getNumber(rb_ary_entry(args, 1));
    } else {
        rb_raise(rb_eArgError, "wrong number of arguments");
    }
    Data_Get_Struct(self, MW_Window, mwWindow);
    AXWindowSetPosition(((MW_Window *)mwWindow)->axWindow, position);

    return MW_Window_position(self);
}

/* Given two integers, or array of two integers, set size of window */
VALUE MW_Window_set_size(VALUE self, VALUE args) {
    CGSize size;
    void *mwWindow;

    if(RARRAY_LEN(args) == 1 && TYPE(rb_ary_entry(args, 0)) == T_ARRAY) {
        args = rb_ary_entry(args, 0);
    }
    if( RARRAY_LEN(args) == 2 &&
        canGetNumber(rb_ary_entry(args, 0)) &&
        canGetNumber(rb_ary_entry(args, 1)) )
    {
        size.width = getNumber(rb_ary_entry(args, 0));
        size.height = getNumber(rb_ary_entry(args, 1));
    } else {
        rb_raise(rb_eArgError, "wrong number of arguments");
    }
    Data_Get_Struct(self, MW_Window, mwWindow);
    AXWindowSetSize(((MW_Window *)mwWindow)->axWindow, size);

    return MW_Window_size(self);
}

/* Return "Application Name - Window Title" string to identify a window */
VALUE MW_Window_to_string(VALUE self) {
    return rb_str_plus(
        MW_Window_app_name(self),
        rb_str_plus(rb_str_new2(" - "), MW_Window_title(self))
    );
}


/* ------------------------------------------------------------------------
 * Internal utility functions
 */

/* Given window CFDictionaryRef and Ruby array, push MW_Window to array */
void StoreWindows(CFDictionaryRef cgWindow, void *rb_ary_ptr) {
    int i;
    AXUIElementRef axWindow;
    MW_Window *mwWindow;
    VALUE wrappedMwWindow;
    VALUE mwWindows;

    mwWindows = (VALUE)rb_ary_ptr;

    i = 0;
    while(1) {
         axWindow = AXWindowFromCGWindow(cgWindow, i);
         if(!axWindow) break;
         mwWindow = (MW_Window *)malloc(sizeof(MW_Window));
         mwWindow->cgWindow =
             CFDictionaryCreateCopy(kCFAllocatorDefault, cgWindow);
         mwWindow->axWindow = axWindow;
         wrappedMwWindow = Data_Wrap_Struct(
             MW_WindowClass, NULL, MW_Window_destroy, (void *)mwWindow
         );
         rb_ary_push(mwWindows, wrappedMwWindow);
         i++;
    }
}

/* Free up MW_Window resources, for Ruby finalizer in Data_Wrap_Struct() */
void MW_Window_destroy(void *ref) {
    MW_Window *mwWindow = (MW_Window *)ref;

    if(mwWindow->cgWindow) CFRelease(mwWindow->cgWindow);
    if(mwWindow->axWindow) CFRelease(mwWindow->axWindow);
    free(mwWindow);
}

/* Return true if a VALUE is a number, or has a to_i() method */
static bool canGetNumber(VALUE v) {
    ID rb_respond_to = rb_intern("respond_to?");
    ID rb_to_i = rb_intern("to_i");

    return TYPE(v) == T_FIXNUM ||
           rb_funcall(v, rb_respond_to, 1, ID2SYM(rb_to_i)) == Qtrue;
}

/* Return an integer for a VALUE, calling to_i() first if needed */
static int getNumber(VALUE v) {
    ID rb_to_i = rb_intern("to_i");

    if(TYPE(v) == T_FIXNUM) {
        return NUM2INT(v);
    } else if(canGetNumber(v)) {
        return NUM2INT(rb_funcall(v, rb_to_i, 0));
    } else {
        return 0;
    }
}

/* Given a CFStringRef, copy its contents into a Ruby string */
static VALUE convertStringRef(CFStringRef str) {
    CFRange range;
    CFStringEncoding encoding;
    CFIndex byteCount;
    UInt8 *buffer;
    VALUE retval;

    range = CFRangeMake(0, CFStringGetLength(str));
    encoding = kCFStringEncodingUTF8;
    CFStringGetBytes(str, range, encoding, 0, false, NULL, 0, &byteCount);
    buffer = ALLOC_N(UInt8, byteCount);
    CFStringGetBytes(str, range, encoding, 0, false, buffer, byteCount, NULL);
    retval = rb_str_new((char *)buffer, (long)byteCount);
    free(buffer);

    return retval;
}


/* ======================================================================== */
