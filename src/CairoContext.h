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

#ifndef QORE_CAIRO_CONTEXT_H
#define QORE_CAIRO_CONTEXT_H

#include <qore/Qore.h>
#include <cairo.h>

#include <string>

class QoreCairoSurface;

class QoreCairoContext : public AbstractPrivateData {
public:
    QoreCairoContext(QoreCairoSurface* surface, ExceptionSink* xsink);
    ~QoreCairoContext();

    // Path operations
    void moveTo(double x, double y, ExceptionSink* xsink);
    void lineTo(double x, double y, ExceptionSink* xsink);
    void curveTo(double x1, double y1, double x2, double y2, double x3, double y3, ExceptionSink* xsink);
    void arc(double xc, double yc, double radius, double angle1, double angle2, ExceptionSink* xsink);
    void arcNegative(double xc, double yc, double radius, double angle1, double angle2, ExceptionSink* xsink);
    void rectangle(double x, double y, double width, double height, ExceptionSink* xsink);
    void closePath(ExceptionSink* xsink);
    void newPath(ExceptionSink* xsink);
    void newSubPath(ExceptionSink* xsink);

    // Drawing
    void stroke(ExceptionSink* xsink);
    void strokePreserve(ExceptionSink* xsink);
    void fill(ExceptionSink* xsink);
    void fillPreserve(ExceptionSink* xsink);
    void paint(ExceptionSink* xsink);
    void paintWithAlpha(double alpha, ExceptionSink* xsink);
    void clip(ExceptionSink* xsink);
    void clipPreserve(ExceptionSink* xsink);

    // Source
    void setSourceRgb(double r, double g, double b, ExceptionSink* xsink);
    void setSourceRgba(double r, double g, double b, double a, ExceptionSink* xsink);
    void setSourceSurface(QoreCairoSurface* surface, double x, double y, ExceptionSink* xsink);
    void setSource(cairo_pattern_t* pattern, ExceptionSink* xsink);

    // State
    void save(ExceptionSink* xsink);
    void restore(ExceptionSink* xsink);
    void setLineWidth(double width, ExceptionSink* xsink);
    void setLineCap(const std::string& cap, ExceptionSink* xsink);
    void setLineJoin(const std::string& join, ExceptionSink* xsink);
    void setDash(const QoreListNode* dashes, double offset, ExceptionSink* xsink);
    void setFillRule(const std::string& rule, ExceptionSink* xsink);
    void setOperator(const std::string& op, ExceptionSink* xsink);
    void setAntialias(const std::string& aa, ExceptionSink* xsink);

    // Transforms
    void translate(double tx, double ty, ExceptionSink* xsink);
    void scale(double sx, double sy, ExceptionSink* xsink);
    void rotate(double angle, ExceptionSink* xsink);
    void transform(const QoreHashNode* matrix, ExceptionSink* xsink);
    void setMatrix(const QoreHashNode* matrix, ExceptionSink* xsink);
    void identityMatrix(ExceptionSink* xsink);

    // Text
    void selectFontFace(const std::string& family, const std::string& slant,
        const std::string& weight, ExceptionSink* xsink);
    void setFontSize(double size, ExceptionSink* xsink);
    void showText(const std::string& text, ExceptionSink* xsink);
    void textPath(const std::string& text, ExceptionSink* xsink);
    QoreHashNode* textExtents(const std::string& text, ExceptionSink* xsink);
    QoreHashNode* fontExtents(ExceptionSink* xsink);
    QoreHashNode* getCurrentPoint(ExceptionSink* xsink);
    QoreHashNode* pathExtents(ExceptionSink* xsink);

    // Page
    void showPage(ExceptionSink* xsink);
    void copyPage(ExceptionSink* xsink);

    cairo_t* getContext() const { return cr; }

private:
    cairo_t* cr = nullptr;
    QoreCairoSurface* surface_ref;

    void checkStatus(ExceptionSink* xsink) const;
    static cairo_matrix_t hashToMatrix(const QoreHashNode* h, ExceptionSink* xsink);
};

#endif
