/* -*- mode: c++; indent-tabs-mode: nil -*- */
/** @file CairoSurface.cpp CairoSurface implementation */
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

#include "CairoSurface.h"
#include "cairo-module.h"

#include <cassert>
#include <cstring>

// SVG surface to file
QoreCairoSurface::QoreCairoSurface(const std::string& path, double width, double height,
        ExceptionSink* xsink) : type(CST_SVG), surface_width(width), surface_height(height) {
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "surface dimensions must be positive (%.2f x %.2f)", width, height);
        return;
    }
    QoreSandboxManagerHelper smh;
    if (smh && !smh->checkFilesystemAccess(path.c_str(), QSEC_WRITE | QSEC_CREATE, xsink)) {
        return;
    }
    if (qore_check_cancel(xsink, "SVG surface create")) {
        return;
    }
    surface = cairo_svg_surface_create(path.c_str(), width, height);
    checkStatus(xsink);
}

// SVG surface to memory
QoreCairoSurface::QoreCairoSurface(double width, double height, bool svg, ExceptionSink* xsink)
        : type(CST_SVG_STREAM), surface_width(width), surface_height(height) {
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "surface dimensions must be positive (%.2f x %.2f)", width, height);
        return;
    }
    surface = cairo_svg_surface_create_for_stream(writeCallback, &stream_data, width, height);
    checkStatus(xsink);
}

// PS surface to file
QoreCairoSurface::QoreCairoSurface(const std::string& path, double width, double height, bool ps,
        ExceptionSink* xsink) : type(CST_PS), surface_width(width), surface_height(height) {
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "surface dimensions must be positive (%.2f x %.2f)", width, height);
        return;
    }
    QoreSandboxManagerHelper smh;
    if (smh && !smh->checkFilesystemAccess(path.c_str(), QSEC_WRITE | QSEC_CREATE, xsink)) {
        return;
    }
    if (qore_check_cancel(xsink, "PostScript surface create")) {
        return;
    }
    surface = cairo_ps_surface_create(path.c_str(), width, height);
    checkStatus(xsink);
}

// PS surface to memory
QoreCairoSurface::QoreCairoSurface(double width, double height, ExceptionSink* xsink)
        : type(CST_PS_STREAM), surface_width(width), surface_height(height) {
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "surface dimensions must be positive (%.2f x %.2f)", width, height);
        return;
    }
    surface = cairo_ps_surface_create_for_stream(writeCallback, &stream_data, width, height);
    checkStatus(xsink);
}

// Image surface
QoreCairoSurface::QoreCairoSurface(int width, int height, cairo_format_t format, ExceptionSink* xsink)
        : type(CST_IMAGE), surface_width(width), surface_height(height) {
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "image dimensions must be positive (%d x %d)", width, height);
        return;
    }
    surface = cairo_image_surface_create(format, width, height);
    checkStatus(xsink);
}

// Image surface from PNG file
QoreCairoSurface::QoreCairoSurface(const std::string& path, ExceptionSink* xsink) : type(CST_IMAGE) {
    QoreSandboxManagerHelper smh;
    if (smh && !smh->checkFilesystemAccess(path.c_str(), QSEC_READ, xsink)) {
        return;
    }
    if (qore_check_cancel(xsink, "PNG file load")) {
        return;
    }
    surface = cairo_image_surface_create_from_png(path.c_str());
    cairo_status_t status = cairo_surface_status(surface);
    if (status != CAIRO_STATUS_SUCCESS) {
        xsink->raiseException("CAIRO-ERROR", "failed to load PNG from '%s': %s",
            path.c_str(), cairo_status_to_string(status));
        if (surface) {
            cairo_surface_destroy(surface);
            surface = nullptr;
        }
        return;
    }
    surface_width = cairo_image_surface_get_width(surface);
    surface_height = cairo_image_surface_get_height(surface);
}

// Image surface from PNG binary data
QoreCairoSurface::QoreCairoSurface(const BinaryNode* data, ExceptionSink* xsink) : type(CST_IMAGE) {
    PngReadData rd;
    rd.data = reinterpret_cast<const unsigned char*>(data->getPtr());
    rd.size = data->size();
    rd.offset = 0;

    surface = cairo_image_surface_create_from_png_stream(pngReadCallback, &rd);
    cairo_status_t status = cairo_surface_status(surface);
    if (status != CAIRO_STATUS_SUCCESS) {
        xsink->raiseException("CAIRO-ERROR", "failed to load PNG from binary data: %s",
            cairo_status_to_string(status));
        if (surface) {
            cairo_surface_destroy(surface);
            surface = nullptr;
        }
        return;
    }
    surface_width = cairo_image_surface_get_width(surface);
    surface_height = cairo_image_surface_get_height(surface);
}

#ifdef HAVE_CAIRO_PDF
// PDF surface to file
QoreCairoSurface::QoreCairoSurface(const std::string& path, double width, double height,
        PdfTag, ExceptionSink* xsink) : type(CST_PDF), surface_width(width), surface_height(height) {
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "surface dimensions must be positive (%.2f x %.2f)", width, height);
        return;
    }
    QoreSandboxManagerHelper smh;
    if (smh && !smh->checkFilesystemAccess(path.c_str(), QSEC_WRITE | QSEC_CREATE, xsink)) {
        return;
    }
    if (qore_check_cancel(xsink, "PDF surface create")) {
        return;
    }
    surface = cairo_pdf_surface_create(path.c_str(), width, height);
    checkStatus(xsink);
}

// PDF surface to memory
QoreCairoSurface::QoreCairoSurface(double width, double height, PdfTag, ExceptionSink* xsink)
        : type(CST_PDF_STREAM), surface_width(width), surface_height(height) {
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "surface dimensions must be positive (%.2f x %.2f)", width, height);
        return;
    }
    surface = cairo_pdf_surface_create_for_stream(writeCallback, &stream_data, width, height);
    checkStatus(xsink);
}
#endif

// Recording surface
QoreCairoSurface::QoreCairoSurface(double x, double y, double width, double height, bool has_extents,
        ExceptionSink* xsink) : type(CST_RECORDING) {
    if (has_extents) {
        cairo_rectangle_t extents = {x, y, width, height};
        surface = cairo_recording_surface_create(CAIRO_CONTENT_COLOR_ALPHA, &extents);
        surface_width = width;
        surface_height = height;
    } else {
        surface = cairo_recording_surface_create(CAIRO_CONTENT_COLOR_ALPHA, nullptr);
    }
    checkStatus(xsink);
}

QoreCairoSurface::~QoreCairoSurface() {
    if (surface) {
        cairo_surface_destroy(surface);
        surface = nullptr;
    }
}

void QoreCairoSurface::finish(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return;
    }
    cairo_surface_finish(surface);
    checkStatus(xsink);
}

void QoreCairoSurface::flush(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return;
    }
    cairo_surface_flush(surface);
    checkStatus(xsink);
}

void QoreCairoSurface::writeToPng(const std::string& path, ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return;
    }
    if (type != CST_IMAGE && type != CST_RECORDING) {
        xsink->raiseException("CAIRO-ERROR", "writeToPng is only available for image and recording surfaces");
        return;
    }
    QoreSandboxManagerHelper smh;
    if (smh && !smh->checkFilesystemAccess(path.c_str(), QSEC_WRITE | QSEC_CREATE, xsink)) {
        return;
    }
    if (qore_check_cancel(xsink, "PNG file write")) {
        return;
    }
    cairo_status_t status = cairo_surface_write_to_png(surface, path.c_str());
    if (status != CAIRO_STATUS_SUCCESS) {
        xsink->raiseException("CAIRO-ERROR", "failed to write PNG to '%s': %s",
            path.c_str(), cairo_status_to_string(status));
    }
}

BinaryNode* QoreCairoSurface::writeToPngData(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return nullptr;
    }
    if (type != CST_IMAGE && type != CST_RECORDING) {
        xsink->raiseException("CAIRO-ERROR", "writeToPngData is only available for image and recording surfaces");
        return nullptr;
    }

    PngWriteData pwd;
    cairo_status_t status = cairo_surface_write_to_png_stream(surface, pngWriteCallback, &pwd);
    if (status != CAIRO_STATUS_SUCCESS) {
        xsink->raiseException("CAIRO-ERROR", "failed to write PNG to memory: %s",
            cairo_status_to_string(status));
        return nullptr;
    }

    BinaryNode* rv = new BinaryNode;
    if (!pwd.data.empty()) {
        rv->append(pwd.data.data(), pwd.data.size());
    }
    return rv;
}

BinaryNode* QoreCairoSurface::getData(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return nullptr;
    }
    if (type != CST_SVG_STREAM && type != CST_PS_STREAM && type != CST_PDF_STREAM) {
        xsink->raiseException("CAIRO-ERROR", "getData is only available for stream-based surfaces");
        return nullptr;
    }

    // Flush to ensure all data is written to the stream
    cairo_surface_flush(surface);

    BinaryNode* rv = new BinaryNode;
    if (!stream_data.empty()) {
        rv->append(stream_data.data(), stream_data.size());
    }
    return rv;
}

int QoreCairoSurface::getWidth(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return 0;
    }
    if (type == CST_IMAGE) {
        return cairo_image_surface_get_width(surface);
    }
    return static_cast<int>(surface_width);
}

int QoreCairoSurface::getHeight(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return 0;
    }
    if (type == CST_IMAGE) {
        return cairo_image_surface_get_height(surface);
    }
    return static_cast<int>(surface_height);
}

QoreHashNode* QoreCairoSurface::getInfo(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return nullptr;
    }

    ReferenceHolder<QoreHashNode> h(new QoreHashNode(hashdeclCairoSurfaceInfo, xsink), xsink);
    if (*xsink) {
        return nullptr;
    }

    const char* type_str;
    switch (type) {
        case CST_SVG:
        case CST_SVG_STREAM:
            type_str = "svg";
            break;
        case CST_PS:
        case CST_PS_STREAM:
            type_str = "ps";
            break;
        case CST_IMAGE:
            type_str = "image";
            break;
        case CST_RECORDING:
            type_str = "recording";
            break;
        case CST_PDF:
        case CST_PDF_STREAM:
            type_str = "pdf";
            break;
        default:
            type_str = "unknown";
    }

    h->setKeyValue("type", new QoreStringNode(type_str), xsink);
    h->setKeyValue("width", surface_width, xsink);
    h->setKeyValue("height", surface_height, xsink);

    if (type == CST_IMAGE) {
        cairo_format_t fmt = cairo_image_surface_get_format(surface);
        const char* fmt_str;
        switch (fmt) {
            case CAIRO_FORMAT_ARGB32:
                fmt_str = "ARGB32";
                break;
            case CAIRO_FORMAT_RGB24:
                fmt_str = "RGB24";
                break;
            case CAIRO_FORMAT_A8:
                fmt_str = "A8";
                break;
            case CAIRO_FORMAT_A1:
                fmt_str = "A1";
                break;
            default:
                fmt_str = "unknown";
        }
        h->setKeyValue("format", new QoreStringNode(fmt_str), xsink);
    }

    return h.release();
}

void QoreCairoSurface::setEps(bool eps, ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return;
    }
    if (type != CST_PS && type != CST_PS_STREAM) {
        xsink->raiseException("CAIRO-ERROR", "setEps is only available for PostScript surfaces");
        return;
    }
    cairo_ps_surface_set_eps(surface, eps ? 1 : 0);
    checkStatus(xsink);
}

void QoreCairoSurface::setPsSize(double width, double height, ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return;
    }
    if (type != CST_PS && type != CST_PS_STREAM) {
        xsink->raiseException("CAIRO-ERROR", "setPsSize is only available for PostScript surfaces");
        return;
    }
    cairo_ps_surface_set_size(surface, width, height);
    surface_width = width;
    surface_height = height;
    checkStatus(xsink);
}

#ifdef HAVE_CAIRO_PDF
void QoreCairoSurface::setPdfSize(double width, double height, ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return;
    }
    if (type != CST_PDF && type != CST_PDF_STREAM) {
        xsink->raiseException("CAIRO-ERROR", "setPdfSize is only available for PDF surfaces");
        return;
    }
    if (width <= 0 || height <= 0) {
        xsink->raiseException("CAIRO-ERROR", "PDF page dimensions must be positive (%.2f x %.2f)", width, height);
        return;
    }
    cairo_pdf_surface_set_size(surface, width, height);
    surface_width = width;
    surface_height = height;
    checkStatus(xsink);
}

bool QoreCairoSurface::isPdfAvailable() {
    return true;
}
#else
void QoreCairoSurface::setPdfSize(double width, double height, ExceptionSink* xsink) {
    xsink->raiseException("CAIRO-ERROR", "PDF surface support not available");
}

bool QoreCairoSurface::isPdfAvailable() {
    return false;
}
#endif

void QoreCairoSurface::showPage(ExceptionSink* xsink) {
    if (!surface) {
        xsink->raiseException("CAIRO-ERROR", "surface is not initialized");
        return;
    }
    cairo_surface_show_page(surface);
    checkStatus(xsink);
}

cairo_status_t QoreCairoSurface::writeCallback(void* closure, const unsigned char* data, unsigned int length) {
    auto* vec = static_cast<std::vector<unsigned char>*>(closure);
    vec->insert(vec->end(), data, data + length);
    return CAIRO_STATUS_SUCCESS;
}

void QoreCairoSurface::checkStatus(ExceptionSink* xsink) const {
    if (!surface) {
        return;
    }
    cairo_status_t status = cairo_surface_status(surface);
    if (status != CAIRO_STATUS_SUCCESS) {
        xsink->raiseException("CAIRO-ERROR", "surface error: %s", cairo_status_to_string(status));
    }
}

cairo_status_t QoreCairoSurface::pngReadCallback(void* closure, unsigned char* data, unsigned int length) {
    auto* rd = static_cast<PngReadData*>(closure);
    if (rd->offset + length > rd->size) {
        return CAIRO_STATUS_READ_ERROR;
    }
    memcpy(data, rd->data + rd->offset, length);
    rd->offset += length;
    return CAIRO_STATUS_SUCCESS;
}

cairo_status_t QoreCairoSurface::pngWriteCallback(void* closure, const unsigned char* data, unsigned int length) {
    auto* pwd = static_cast<PngWriteData*>(closure);
    pwd->data.insert(pwd->data.end(), data, data + length);
    return CAIRO_STATUS_SUCCESS;
}
