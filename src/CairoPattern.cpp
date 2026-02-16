/* -*- mode: c++; indent-tabs-mode: nil -*- */
/** @file CairoPattern.cpp CairoPattern implementation */
/*
    Qore cairo module

    Copyright (C) 2026 Qore Technologies, s.r.o.

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
*/

#include "CairoPattern.h"
#include "CairoSurface.h"
#include "cairo-module.h"

// Linear gradient
QoreCairoPattern::QoreCairoPattern(double x0, double y0, double x1, double y1, ExceptionSink* xsink) {
    pattern = cairo_pattern_create_linear(x0, y0, x1, y1);
    checkStatus(xsink);
}

// Radial gradient
QoreCairoPattern::QoreCairoPattern(double cx0, double cy0, double r0, double cx1, double cy1, double r1,
        ExceptionSink* xsink) {
    pattern = cairo_pattern_create_radial(cx0, cy0, r0, cx1, cy1, r1);
    checkStatus(xsink);
}

// Solid RGB
QoreCairoPattern::QoreCairoPattern(double r, double g, double b, ExceptionSink* xsink) {
    pattern = cairo_pattern_create_rgb(r, g, b);
    checkStatus(xsink);
}

// Solid RGBA
QoreCairoPattern::QoreCairoPattern(double r, double g, double b, double a, bool rgba, ExceptionSink* xsink) {
    pattern = cairo_pattern_create_rgba(r, g, b, a);
    checkStatus(xsink);
}

// Surface pattern
QoreCairoPattern::QoreCairoPattern(QoreCairoSurface* surface, ExceptionSink* xsink) {
    pattern = cairo_pattern_create_for_surface(surface->getSurface());
    checkStatus(xsink);
}

QoreCairoPattern::~QoreCairoPattern() {
    if (pattern) {
        cairo_pattern_destroy(pattern);
        pattern = nullptr;
    }
}

void QoreCairoPattern::addColorStopRgb(double offset, double r, double g, double b, ExceptionSink* xsink) {
    cairo_pattern_add_color_stop_rgb(pattern, offset, r, g, b);
    checkStatus(xsink);
}

void QoreCairoPattern::addColorStopRgba(double offset, double r, double g, double b, double a,
        ExceptionSink* xsink) {
    cairo_pattern_add_color_stop_rgba(pattern, offset, r, g, b, a);
    checkStatus(xsink);
}

void QoreCairoPattern::setExtend(const std::string& extend, ExceptionSink* xsink) {
    cairo_extend_t e;
    if (extend == "none") {
        e = CAIRO_EXTEND_NONE;
    } else if (extend == "repeat") {
        e = CAIRO_EXTEND_REPEAT;
    } else if (extend == "reflect") {
        e = CAIRO_EXTEND_REFLECT;
    } else if (extend == "pad") {
        e = CAIRO_EXTEND_PAD;
    } else {
        xsink->raiseException("CAIRO-ERROR", "invalid extend '%s'; valid values: none, repeat, reflect, pad",
            extend.c_str());
        return;
    }
    cairo_pattern_set_extend(pattern, e);
    checkStatus(xsink);
}

void QoreCairoPattern::setFilter(const std::string& filter, ExceptionSink* xsink) {
    cairo_filter_t f;
    if (filter == "fast") {
        f = CAIRO_FILTER_FAST;
    } else if (filter == "good") {
        f = CAIRO_FILTER_GOOD;
    } else if (filter == "best") {
        f = CAIRO_FILTER_BEST;
    } else if (filter == "nearest") {
        f = CAIRO_FILTER_NEAREST;
    } else if (filter == "bilinear") {
        f = CAIRO_FILTER_BILINEAR;
    } else {
        xsink->raiseException("CAIRO-ERROR",
            "invalid filter '%s'; valid values: fast, good, best, nearest, bilinear",
            filter.c_str());
        return;
    }
    cairo_pattern_set_filter(pattern, f);
    checkStatus(xsink);
}

void QoreCairoPattern::setMatrix(const QoreHashNode* matrix, ExceptionSink* xsink) {
    cairo_matrix_t m;
    m.xx = matrix->getKeyValue("xx").getAsFloat();
    m.yx = matrix->getKeyValue("yx").getAsFloat();
    m.xy = matrix->getKeyValue("xy").getAsFloat();
    m.yy = matrix->getKeyValue("yy").getAsFloat();
    m.x0 = matrix->getKeyValue("x0").getAsFloat();
    m.y0 = matrix->getKeyValue("y0").getAsFloat();
    cairo_pattern_set_matrix(pattern, &m);
    checkStatus(xsink);
}

void QoreCairoPattern::checkStatus(ExceptionSink* xsink) const {
    if (!pattern) {
        return;
    }
    cairo_status_t status = cairo_pattern_status(pattern);
    if (status != CAIRO_STATUS_SUCCESS) {
        xsink->raiseException("CAIRO-ERROR", "pattern error: %s", cairo_status_to_string(status));
    }
}
