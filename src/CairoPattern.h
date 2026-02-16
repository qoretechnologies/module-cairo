/* -*- mode: c++; indent-tabs-mode: nil -*- */
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

#ifndef QORE_CAIRO_PATTERN_H
#define QORE_CAIRO_PATTERN_H

#include <qore/Qore.h>
#include <cairo.h>

#include <string>

class QoreCairoSurface;

class QoreCairoPattern : public AbstractPrivateData {
public:
    //! Create linear gradient
    QoreCairoPattern(double x0, double y0, double x1, double y1, ExceptionSink* xsink);

    //! Create radial gradient
    QoreCairoPattern(double cx0, double cy0, double r0, double cx1, double cy1, double r1, ExceptionSink* xsink);

    //! Create solid color (RGB)
    QoreCairoPattern(double r, double g, double b, ExceptionSink* xsink);

    //! Create solid color (RGBA)
    QoreCairoPattern(double r, double g, double b, double a, bool rgba, ExceptionSink* xsink);

    //! Create surface pattern
    QoreCairoPattern(QoreCairoSurface* surface, ExceptionSink* xsink);

    ~QoreCairoPattern();

    void addColorStopRgb(double offset, double r, double g, double b, ExceptionSink* xsink);
    void addColorStopRgba(double offset, double r, double g, double b, double a, ExceptionSink* xsink);
    void setExtend(const std::string& extend, ExceptionSink* xsink);
    void setFilter(const std::string& filter, ExceptionSink* xsink);
    void setMatrix(const QoreHashNode* matrix, ExceptionSink* xsink);

    cairo_pattern_t* getPattern() const { return pattern; }

private:
    cairo_pattern_t* pattern = nullptr;

    void checkStatus(ExceptionSink* xsink) const;
};

#endif
