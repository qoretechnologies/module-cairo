/* -*- mode: c++; indent-tabs-mode: nil -*- */
/** @file CairoSvgReader.cpp CairoSvgReader implementation */
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

#include "CairoSvgReader.h"
#include "CairoContext.h"
#include "cairo-module.h"

#ifdef HAVE_RSVG

QoreCairoSvgReader::QoreCairoSvgReader(const std::string& path, ExceptionSink* xsink) {
    QoreSandboxManagerHelper smh;
    if (smh && !smh->checkFilesystemAccess(path.c_str(), QSEC_READ, xsink)) {
        return;
    }
    if (qore_check_cancel(xsink, "SVG file load")) {
        return;
    }
    GError* error = nullptr;
    GFile* file = g_file_new_for_path(path.c_str());
    handle = rsvg_handle_new_from_gfile_sync(file, RSVG_HANDLE_FLAGS_NONE, nullptr, &error);
    g_object_unref(file);

    if (!handle) {
        xsink->raiseException("CAIRO-ERROR", "failed to load SVG from '%s': %s",
            path.c_str(), error ? error->message : "unknown error");
        if (error) {
            g_error_free(error);
        }
        return;
    }

    // Get intrinsic dimensions
    gboolean has_width, has_height;
    RsvgLength rsvg_width, rsvg_height;
    rsvg_handle_get_intrinsic_dimensions(handle, &has_width, &rsvg_width, &has_height, &rsvg_height,
        nullptr, nullptr);

    if (has_width) {
        width = rsvg_width.length;
    }
    if (has_height) {
        height = rsvg_height.length;
    }

    // If no intrinsic dimensions, try viewport
    if (width == 0 || height == 0) {
        gdouble out_width, out_height;
        rsvg_handle_get_intrinsic_size_in_pixels(handle, &out_width, &out_height);
        if (width == 0) {
            width = out_width;
        }
        if (height == 0) {
            height = out_height;
        }
    }
}

QoreCairoSvgReader::QoreCairoSvgReader(const BinaryNode* data, ExceptionSink* xsink) {
    GError* error = nullptr;
    GInputStream* stream = g_memory_input_stream_new_from_data(data->getPtr(), data->size(), nullptr);
    handle = rsvg_handle_new_from_stream_sync(stream, nullptr, RSVG_HANDLE_FLAGS_NONE, nullptr, &error);
    g_object_unref(stream);

    if (!handle) {
        xsink->raiseException("CAIRO-ERROR", "failed to load SVG from binary data: %s",
            error ? error->message : "unknown error");
        if (error) {
            g_error_free(error);
        }
        return;
    }

    // Get intrinsic dimensions
    gboolean has_width, has_height;
    RsvgLength rsvg_width, rsvg_height;
    rsvg_handle_get_intrinsic_dimensions(handle, &has_width, &rsvg_width, &has_height, &rsvg_height,
        nullptr, nullptr);

    if (has_width) {
        width = rsvg_width.length;
    }
    if (has_height) {
        height = rsvg_height.length;
    }

    // If no intrinsic dimensions, try viewport
    if (width == 0 || height == 0) {
        gdouble out_width, out_height;
        rsvg_handle_get_intrinsic_size_in_pixels(handle, &out_width, &out_height);
        if (width == 0) {
            width = out_width;
        }
        if (height == 0) {
            height = out_height;
        }
    }
}

QoreCairoSvgReader::~QoreCairoSvgReader() {
    if (handle) {
        g_object_unref(handle);
        handle = nullptr;
    }
}

double QoreCairoSvgReader::getWidth(ExceptionSink* xsink) {
    if (!handle) {
        xsink->raiseException("CAIRO-ERROR", "SVG handle is not initialized");
        return 0;
    }
    return width;
}

double QoreCairoSvgReader::getHeight(ExceptionSink* xsink) {
    if (!handle) {
        xsink->raiseException("CAIRO-ERROR", "SVG handle is not initialized");
        return 0;
    }
    return height;
}

QoreHashNode* QoreCairoSvgReader::getDimensions(ExceptionSink* xsink) {
    if (!handle) {
        xsink->raiseException("CAIRO-ERROR", "SVG handle is not initialized");
        return nullptr;
    }

    ReferenceHolder<QoreHashNode> h(new QoreHashNode(autoTypeInfo), xsink);
    if (*xsink) {
        return nullptr;
    }
    h->setKeyValue("width", width, xsink);
    h->setKeyValue("height", height, xsink);

    // Get em and ex if available
    gboolean has_width_b, has_height_b;
    RsvgLength rsvg_width, rsvg_height;
    gboolean has_viewbox;
    RsvgRectangle viewbox;
    rsvg_handle_get_intrinsic_dimensions(handle, &has_width_b, &rsvg_width, &has_height_b, &rsvg_height,
        &has_viewbox, &viewbox);

    return h.release();
}

void QoreCairoSvgReader::renderTo(QoreCairoContext* ctx, ExceptionSink* xsink) {
    if (!handle) {
        xsink->raiseException("CAIRO-ERROR", "SVG handle is not initialized");
        return;
    }

    RsvgRectangle viewport = {0, 0, width, height};
    GError* error = nullptr;
    gboolean ok = rsvg_handle_render_document(handle, ctx->getContext(), &viewport, &error);
    if (!ok) {
        xsink->raiseException("CAIRO-ERROR", "failed to render SVG: %s",
            error ? error->message : "unknown error");
        if (error) {
            g_error_free(error);
        }
    }
}

QoreHashNode* QoreCairoSvgReader::getMetadata(ExceptionSink* xsink) {
    if (!handle) {
        xsink->raiseException("CAIRO-ERROR", "SVG handle is not initialized");
        return nullptr;
    }

    ReferenceHolder<QoreHashNode> h(new QoreHashNode(autoTypeInfo), xsink);
    if (*xsink) {
        return nullptr;
    }

    // librsvg 2.52+ has rsvg_handle_get_title/description as deprecated but still available
    // For now just return dimensions as metadata
    h->setKeyValue("width", width, xsink);
    h->setKeyValue("height", height, xsink);

    return h.release();
}

bool QoreCairoSvgReader::isAvailable() {
    return true;
}

#else // !HAVE_RSVG

QoreCairoSvgReader::QoreCairoSvgReader(const std::string& path, ExceptionSink* xsink) {
    xsink->raiseException("MISSING-FEATURE-ERROR", "librsvg is not available; SVG reading is disabled");
}

QoreCairoSvgReader::QoreCairoSvgReader(const BinaryNode* data, ExceptionSink* xsink) {
    xsink->raiseException("MISSING-FEATURE-ERROR", "librsvg is not available; SVG reading is disabled");
}

QoreCairoSvgReader::~QoreCairoSvgReader() {
}

double QoreCairoSvgReader::getWidth(ExceptionSink* xsink) {
    xsink->raiseException("MISSING-FEATURE-ERROR", "librsvg is not available");
    return 0;
}

double QoreCairoSvgReader::getHeight(ExceptionSink* xsink) {
    xsink->raiseException("MISSING-FEATURE-ERROR", "librsvg is not available");
    return 0;
}

QoreHashNode* QoreCairoSvgReader::getDimensions(ExceptionSink* xsink) {
    xsink->raiseException("MISSING-FEATURE-ERROR", "librsvg is not available");
    return nullptr;
}

void QoreCairoSvgReader::renderTo(QoreCairoContext* ctx, ExceptionSink* xsink) {
    xsink->raiseException("MISSING-FEATURE-ERROR", "librsvg is not available");
}

QoreHashNode* QoreCairoSvgReader::getMetadata(ExceptionSink* xsink) {
    xsink->raiseException("MISSING-FEATURE-ERROR", "librsvg is not available");
    return nullptr;
}

bool QoreCairoSvgReader::isAvailable() {
    return false;
}

#endif // HAVE_RSVG
