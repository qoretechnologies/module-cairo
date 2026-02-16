/* -*- mode: c++; indent-tabs-mode: nil -*- */
/** @file CairoContext.cpp CairoContext implementation */
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

#include "CairoContext.h"
#include "CairoSurface.h"
#include "cairo-module.h"

#include <cassert>

QoreCairoContext::QoreCairoContext(QoreCairoSurface* surface, ExceptionSink* xsink) : surface_ref(surface) {
    assert(surface);
    // NOTE: caller (QPP-generated code via HARD_QORE_VALUE_OBJ_DATA) already holds a reference
    // from getReferencedPrivateData(); we take ownership of that reference here
    cr = cairo_create(surface->getSurface());
    checkStatus(xsink);
}

QoreCairoContext::~QoreCairoContext() {
    if (cr) {
        cairo_destroy(cr);
        cr = nullptr;
    }
    if (surface_ref) {
        surface_ref->deref();
        surface_ref = nullptr;
    }
}

// Path operations
void QoreCairoContext::moveTo(double x, double y, ExceptionSink* xsink) {
    cairo_move_to(cr, x, y);
    checkStatus(xsink);
}

void QoreCairoContext::lineTo(double x, double y, ExceptionSink* xsink) {
    cairo_line_to(cr, x, y);
    checkStatus(xsink);
}

void QoreCairoContext::curveTo(double x1, double y1, double x2, double y2, double x3, double y3,
        ExceptionSink* xsink) {
    cairo_curve_to(cr, x1, y1, x2, y2, x3, y3);
    checkStatus(xsink);
}

void QoreCairoContext::arc(double xc, double yc, double radius, double angle1, double angle2,
        ExceptionSink* xsink) {
    cairo_arc(cr, xc, yc, radius, angle1, angle2);
    checkStatus(xsink);
}

void QoreCairoContext::arcNegative(double xc, double yc, double radius, double angle1, double angle2,
        ExceptionSink* xsink) {
    cairo_arc_negative(cr, xc, yc, radius, angle1, angle2);
    checkStatus(xsink);
}

void QoreCairoContext::rectangle(double x, double y, double width, double height, ExceptionSink* xsink) {
    cairo_rectangle(cr, x, y, width, height);
    checkStatus(xsink);
}

void QoreCairoContext::closePath(ExceptionSink* xsink) {
    cairo_close_path(cr);
    checkStatus(xsink);
}

void QoreCairoContext::newPath(ExceptionSink* xsink) {
    cairo_new_path(cr);
    checkStatus(xsink);
}

void QoreCairoContext::newSubPath(ExceptionSink* xsink) {
    cairo_new_sub_path(cr);
    checkStatus(xsink);
}

// Drawing
void QoreCairoContext::stroke(ExceptionSink* xsink) {
    cairo_stroke(cr);
    checkStatus(xsink);
}

void QoreCairoContext::strokePreserve(ExceptionSink* xsink) {
    cairo_stroke_preserve(cr);
    checkStatus(xsink);
}

void QoreCairoContext::fill(ExceptionSink* xsink) {
    cairo_fill(cr);
    checkStatus(xsink);
}

void QoreCairoContext::fillPreserve(ExceptionSink* xsink) {
    cairo_fill_preserve(cr);
    checkStatus(xsink);
}

void QoreCairoContext::paint(ExceptionSink* xsink) {
    cairo_paint(cr);
    checkStatus(xsink);
}

void QoreCairoContext::paintWithAlpha(double alpha, ExceptionSink* xsink) {
    cairo_paint_with_alpha(cr, alpha);
    checkStatus(xsink);
}

void QoreCairoContext::clip(ExceptionSink* xsink) {
    cairo_clip(cr);
    checkStatus(xsink);
}

void QoreCairoContext::clipPreserve(ExceptionSink* xsink) {
    cairo_clip_preserve(cr);
    checkStatus(xsink);
}

// Source
void QoreCairoContext::setSourceRgb(double r, double g, double b, ExceptionSink* xsink) {
    cairo_set_source_rgb(cr, r, g, b);
    checkStatus(xsink);
}

void QoreCairoContext::setSourceRgba(double r, double g, double b, double a, ExceptionSink* xsink) {
    cairo_set_source_rgba(cr, r, g, b, a);
    checkStatus(xsink);
}

void QoreCairoContext::setSourceSurface(QoreCairoSurface* surface, double x, double y, ExceptionSink* xsink) {
    cairo_set_source_surface(cr, surface->getSurface(), x, y);
    checkStatus(xsink);
}

void QoreCairoContext::setSource(cairo_pattern_t* pattern, ExceptionSink* xsink) {
    cairo_set_source(cr, pattern);
    checkStatus(xsink);
}

// State
void QoreCairoContext::save(ExceptionSink* xsink) {
    cairo_save(cr);
    checkStatus(xsink);
}

void QoreCairoContext::restore(ExceptionSink* xsink) {
    cairo_restore(cr);
    checkStatus(xsink);
}

void QoreCairoContext::setLineWidth(double width, ExceptionSink* xsink) {
    cairo_set_line_width(cr, width);
    checkStatus(xsink);
}

void QoreCairoContext::setLineCap(const std::string& cap, ExceptionSink* xsink) {
    cairo_line_cap_t c;
    if (cap == "butt") {
        c = CAIRO_LINE_CAP_BUTT;
    } else if (cap == "round") {
        c = CAIRO_LINE_CAP_ROUND;
    } else if (cap == "square") {
        c = CAIRO_LINE_CAP_SQUARE;
    } else {
        xsink->raiseException("CAIRO-ERROR", "invalid line cap '%s'; valid values: butt, round, square",
            cap.c_str());
        return;
    }
    cairo_set_line_cap(cr, c);
    checkStatus(xsink);
}

void QoreCairoContext::setLineJoin(const std::string& join, ExceptionSink* xsink) {
    cairo_line_join_t j;
    if (join == "miter") {
        j = CAIRO_LINE_JOIN_MITER;
    } else if (join == "round") {
        j = CAIRO_LINE_JOIN_ROUND;
    } else if (join == "bevel") {
        j = CAIRO_LINE_JOIN_BEVEL;
    } else {
        xsink->raiseException("CAIRO-ERROR", "invalid line join '%s'; valid values: miter, round, bevel",
            join.c_str());
        return;
    }
    cairo_set_line_join(cr, j);
    checkStatus(xsink);
}

void QoreCairoContext::setDash(const QoreListNode* dashes, double offset, ExceptionSink* xsink) {
    size_t count = dashes ? dashes->size() : 0;
    if (count == 0) {
        cairo_set_dash(cr, nullptr, 0, 0);
        return;
    }

    std::vector<double> dash_array(count);
    for (size_t i = 0; i < count; ++i) {
        dash_array[i] = dashes->retrieveEntry(i).getAsFloat();
    }
    cairo_set_dash(cr, dash_array.data(), static_cast<int>(count), offset);
    checkStatus(xsink);
}

void QoreCairoContext::setFillRule(const std::string& rule, ExceptionSink* xsink) {
    cairo_fill_rule_t r;
    if (rule == "winding") {
        r = CAIRO_FILL_RULE_WINDING;
    } else if (rule == "even-odd") {
        r = CAIRO_FILL_RULE_EVEN_ODD;
    } else {
        xsink->raiseException("CAIRO-ERROR", "invalid fill rule '%s'; valid values: winding, even-odd",
            rule.c_str());
        return;
    }
    cairo_set_fill_rule(cr, r);
    checkStatus(xsink);
}

void QoreCairoContext::setOperator(const std::string& op, ExceptionSink* xsink) {
    cairo_operator_t o;
    if (op == "clear") {
        o = CAIRO_OPERATOR_CLEAR;
    } else if (op == "source") {
        o = CAIRO_OPERATOR_SOURCE;
    } else if (op == "over") {
        o = CAIRO_OPERATOR_OVER;
    } else if (op == "in") {
        o = CAIRO_OPERATOR_IN;
    } else if (op == "out") {
        o = CAIRO_OPERATOR_OUT;
    } else if (op == "atop") {
        o = CAIRO_OPERATOR_ATOP;
    } else if (op == "dest") {
        o = CAIRO_OPERATOR_DEST;
    } else if (op == "dest-over") {
        o = CAIRO_OPERATOR_DEST_OVER;
    } else if (op == "dest-in") {
        o = CAIRO_OPERATOR_DEST_IN;
    } else if (op == "dest-out") {
        o = CAIRO_OPERATOR_DEST_OUT;
    } else if (op == "dest-atop") {
        o = CAIRO_OPERATOR_DEST_ATOP;
    } else if (op == "xor") {
        o = CAIRO_OPERATOR_XOR;
    } else if (op == "add") {
        o = CAIRO_OPERATOR_ADD;
    } else if (op == "saturate") {
        o = CAIRO_OPERATOR_SATURATE;
    } else {
        xsink->raiseException("CAIRO-ERROR", "invalid operator '%s'", op.c_str());
        return;
    }
    cairo_set_operator(cr, o);
    checkStatus(xsink);
}

void QoreCairoContext::setAntialias(const std::string& aa, ExceptionSink* xsink) {
    cairo_antialias_t a;
    if (aa == "default") {
        a = CAIRO_ANTIALIAS_DEFAULT;
    } else if (aa == "none") {
        a = CAIRO_ANTIALIAS_NONE;
    } else if (aa == "gray") {
        a = CAIRO_ANTIALIAS_GRAY;
    } else if (aa == "subpixel") {
        a = CAIRO_ANTIALIAS_SUBPIXEL;
    } else if (aa == "fast") {
        a = CAIRO_ANTIALIAS_FAST;
    } else if (aa == "good") {
        a = CAIRO_ANTIALIAS_GOOD;
    } else if (aa == "best") {
        a = CAIRO_ANTIALIAS_BEST;
    } else {
        xsink->raiseException("CAIRO-ERROR",
            "invalid antialias '%s'; valid values: default, none, gray, subpixel, fast, good, best",
            aa.c_str());
        return;
    }
    cairo_set_antialias(cr, a);
    checkStatus(xsink);
}

// Transforms
void QoreCairoContext::translate(double tx, double ty, ExceptionSink* xsink) {
    cairo_translate(cr, tx, ty);
    checkStatus(xsink);
}

void QoreCairoContext::scale(double sx, double sy, ExceptionSink* xsink) {
    cairo_scale(cr, sx, sy);
    checkStatus(xsink);
}

void QoreCairoContext::rotate(double angle, ExceptionSink* xsink) {
    cairo_rotate(cr, angle);
    checkStatus(xsink);
}

cairo_matrix_t QoreCairoContext::hashToMatrix(const QoreHashNode* h, ExceptionSink* xsink) {
    cairo_matrix_t m;
    m.xx = h->getKeyValue("xx").getAsFloat();
    m.yx = h->getKeyValue("yx").getAsFloat();
    m.xy = h->getKeyValue("xy").getAsFloat();
    m.yy = h->getKeyValue("yy").getAsFloat();
    m.x0 = h->getKeyValue("x0").getAsFloat();
    m.y0 = h->getKeyValue("y0").getAsFloat();
    return m;
}

void QoreCairoContext::transform(const QoreHashNode* matrix, ExceptionSink* xsink) {
    cairo_matrix_t m = hashToMatrix(matrix, xsink);
    if (*xsink) {
        return;
    }
    cairo_transform(cr, &m);
    checkStatus(xsink);
}

void QoreCairoContext::setMatrix(const QoreHashNode* matrix, ExceptionSink* xsink) {
    cairo_matrix_t m = hashToMatrix(matrix, xsink);
    if (*xsink) {
        return;
    }
    cairo_set_matrix(cr, &m);
    checkStatus(xsink);
}

void QoreCairoContext::identityMatrix(ExceptionSink* xsink) {
    cairo_identity_matrix(cr);
    checkStatus(xsink);
}

// Text
void QoreCairoContext::selectFontFace(const std::string& family, const std::string& slant,
        const std::string& weight, ExceptionSink* xsink) {
    cairo_font_slant_t s;
    if (slant == "normal") {
        s = CAIRO_FONT_SLANT_NORMAL;
    } else if (slant == "italic") {
        s = CAIRO_FONT_SLANT_ITALIC;
    } else if (slant == "oblique") {
        s = CAIRO_FONT_SLANT_OBLIQUE;
    } else {
        xsink->raiseException("CAIRO-ERROR", "invalid font slant '%s'; valid values: normal, italic, oblique",
            slant.c_str());
        return;
    }

    cairo_font_weight_t w;
    if (weight == "normal") {
        w = CAIRO_FONT_WEIGHT_NORMAL;
    } else if (weight == "bold") {
        w = CAIRO_FONT_WEIGHT_BOLD;
    } else {
        xsink->raiseException("CAIRO-ERROR", "invalid font weight '%s'; valid values: normal, bold",
            weight.c_str());
        return;
    }

    cairo_select_font_face(cr, family.c_str(), s, w);
    checkStatus(xsink);
}

void QoreCairoContext::setFontSize(double size, ExceptionSink* xsink) {
    cairo_set_font_size(cr, size);
    checkStatus(xsink);
}

void QoreCairoContext::showText(const std::string& text, ExceptionSink* xsink) {
    cairo_show_text(cr, text.c_str());
    checkStatus(xsink);
}

void QoreCairoContext::textPath(const std::string& text, ExceptionSink* xsink) {
    cairo_text_path(cr, text.c_str());
    checkStatus(xsink);
}

QoreHashNode* QoreCairoContext::textExtents(const std::string& text, ExceptionSink* xsink) {
    cairo_text_extents_t extents;
    cairo_text_extents(cr, text.c_str(), &extents);

    ReferenceHolder<QoreHashNode> h(new QoreHashNode(hashdeclCairoTextExtents, xsink), xsink);
    if (*xsink) {
        return nullptr;
    }

    h->setKeyValue("x_bearing", extents.x_bearing, xsink);
    h->setKeyValue("y_bearing", extents.y_bearing, xsink);
    h->setKeyValue("width", extents.width, xsink);
    h->setKeyValue("height", extents.height, xsink);
    h->setKeyValue("x_advance", extents.x_advance, xsink);
    h->setKeyValue("y_advance", extents.y_advance, xsink);

    return h.release();
}

QoreHashNode* QoreCairoContext::fontExtents(ExceptionSink* xsink) {
    cairo_font_extents_t extents;
    cairo_font_extents(cr, &extents);

    ReferenceHolder<QoreHashNode> h(new QoreHashNode(hashdeclCairoFontExtents, xsink), xsink);
    if (*xsink) {
        return nullptr;
    }

    h->setKeyValue("ascent", extents.ascent, xsink);
    h->setKeyValue("descent", extents.descent, xsink);
    h->setKeyValue("height", extents.height, xsink);
    h->setKeyValue("max_x_advance", extents.max_x_advance, xsink);
    h->setKeyValue("max_y_advance", extents.max_y_advance, xsink);

    return h.release();
}

QoreHashNode* QoreCairoContext::getCurrentPoint(ExceptionSink* xsink) {
    if (!cairo_has_current_point(cr)) {
        return nullptr;
    }
    double x, y;
    cairo_get_current_point(cr, &x, &y);

    ReferenceHolder<QoreHashNode> h(new QoreHashNode(hashdeclCairoPoint, xsink), xsink);
    if (*xsink) {
        return nullptr;
    }
    h->setKeyValue("x", x, xsink);
    h->setKeyValue("y", y, xsink);
    return h.release();
}

QoreHashNode* QoreCairoContext::pathExtents(ExceptionSink* xsink) {
    double x1, y1, x2, y2;
    cairo_path_extents(cr, &x1, &y1, &x2, &y2);

    ReferenceHolder<QoreHashNode> h(new QoreHashNode(hashdeclCairoPathExtents, xsink), xsink);
    if (*xsink) {
        return nullptr;
    }
    h->setKeyValue("x1", x1, xsink);
    h->setKeyValue("y1", y1, xsink);
    h->setKeyValue("x2", x2, xsink);
    h->setKeyValue("y2", y2, xsink);
    return h.release();
}

// Page
void QoreCairoContext::showPage(ExceptionSink* xsink) {
    cairo_show_page(cr);
    checkStatus(xsink);
}

void QoreCairoContext::copyPage(ExceptionSink* xsink) {
    cairo_copy_page(cr);
    checkStatus(xsink);
}

void QoreCairoContext::checkStatus(ExceptionSink* xsink) const {
    if (!cr) {
        return;
    }
    cairo_status_t status = cairo_status(cr);
    if (status != CAIRO_STATUS_SUCCESS) {
        xsink->raiseException("CAIRO-ERROR", "context error: %s", cairo_status_to_string(status));
    }
}
