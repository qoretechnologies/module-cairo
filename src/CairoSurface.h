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

#ifndef QORE_CAIRO_SURFACE_H
#define QORE_CAIRO_SURFACE_H

#include <qore/Qore.h>

#include <cairo.h>
#include <cairo-svg.h>
#include <cairo-ps.h>
#ifdef HAVE_CAIRO_PDF
#include <cairo-pdf.h>
#endif

#include <string>
#include <vector>

//! Surface types
enum CairoSurfaceType {
    CST_SVG,
    CST_SVG_STREAM,
    CST_PS,
    CST_PS_STREAM,
    CST_IMAGE,
    CST_RECORDING,
    CST_PDF,
    CST_PDF_STREAM,
};

class QoreCairoSurface : public AbstractPrivateData {
public:
    //! Create SVG surface writing to file
    QoreCairoSurface(const std::string& path, double width, double height, ExceptionSink* xsink);

    //! Create SVG surface writing to memory
    QoreCairoSurface(double width, double height, bool svg, ExceptionSink* xsink);

    //! Create PS surface writing to file
    QoreCairoSurface(const std::string& path, double width, double height, bool ps, ExceptionSink* xsink);

    //! Create PS surface writing to memory
    QoreCairoSurface(double width, double height, ExceptionSink* xsink);

    //! Create image surface
    QoreCairoSurface(int width, int height, cairo_format_t format, ExceptionSink* xsink);

    //! Create image surface from PNG file
    QoreCairoSurface(const std::string& path, ExceptionSink* xsink);

    //! Create image surface from PNG binary data
    QoreCairoSurface(const BinaryNode* data, ExceptionSink* xsink);

    //! Create recording surface
    QoreCairoSurface(double x, double y, double width, double height, bool has_extents, ExceptionSink* xsink);

#ifdef HAVE_CAIRO_PDF
    //! Tag struct to differentiate PDF constructors from PS constructors
    struct PdfTag {};

    //! Create PDF surface writing to file
    QoreCairoSurface(const std::string& path, double width, double height, PdfTag, ExceptionSink* xsink);

    //! Create PDF surface writing to memory
    QoreCairoSurface(double width, double height, PdfTag, ExceptionSink* xsink);
#endif

    ~QoreCairoSurface();

    void finish(ExceptionSink* xsink);
    void flush(ExceptionSink* xsink);

    void writeToPng(const std::string& path, ExceptionSink* xsink);
    BinaryNode* writeToPngData(ExceptionSink* xsink);
    BinaryNode* getData(ExceptionSink* xsink);

    int getWidth(ExceptionSink* xsink);
    int getHeight(ExceptionSink* xsink);
    QoreHashNode* getInfo(ExceptionSink* xsink);

    void setEps(bool eps, ExceptionSink* xsink);
    void setPsSize(double width, double height, ExceptionSink* xsink);
#ifdef HAVE_CAIRO_PDF
    void setPdfSize(double width, double height, ExceptionSink* xsink);
#endif
    void showPage(ExceptionSink* xsink);

    static bool isPdfAvailable();

    cairo_surface_t* getSurface() const { return surface; }
    CairoSurfaceType getType() const { return type; }

private:
    cairo_surface_t* surface = nullptr;
    CairoSurfaceType type;
    std::vector<unsigned char> stream_data;
    double surface_width = 0;
    double surface_height = 0;

    static cairo_status_t writeCallback(void* closure, const unsigned char* data, unsigned int length);
    void checkStatus(ExceptionSink* xsink) const;

    //! PNG read callback data
    struct PngReadData {
        const unsigned char* data;
        size_t size;
        size_t offset;
    };

    static cairo_status_t pngReadCallback(void* closure, unsigned char* data, unsigned int length);

    //! PNG write callback data
    struct PngWriteData {
        std::vector<unsigned char> data;
    };

    static cairo_status_t pngWriteCallback(void* closure, const unsigned char* data, unsigned int length);
};

#endif
