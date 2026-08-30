/* -*- mode: c++; indent-tabs-mode: nil -*- */
/** @file cairo-module.cpp cairo module implementation */
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

#include "cairo-module.h"
#include "QC_CairoSurface.h"
#include "QC_CairoContext.h"
#include "QC_CairoPattern.h"
#include "QC_CairoSvgReader.h"

#include <cairo.h>

static void cairo_module_init(QoreModuleInitContext& ctx, ExceptionSink& xsink);
static void cairo_module_ns_init(QoreNamespace* rns, QoreNamespace* qns, ExceptionSink& xsink);
static void cairo_module_delete();

extern "C" DLLEXPORT void cairo_qore_module_desc(QoreModuleInfo& mod_info) {
    mod_info.name = "cairo";
    mod_info.version = "1.0.0";
    mod_info.desc = "Qore Cairo module for vector graphics (SVG, PDF, PostScript, EPS)";
    mod_info.author = "Qore Technologies, s.r.o.";
    mod_info.url = "https://github.com/qoretechnologies/module-cairo";
    mod_info.api_major = QORE_MODULE_API_MAJOR;
    mod_info.api_minor = QORE_MODULE_API_MINOR;
    mod_info.init = cairo_module_init;
    mod_info.ns_init = cairo_module_ns_init;
    mod_info.del = cairo_module_delete;
    mod_info.license = QL_MIT;
    mod_info.license_str = "MIT";
}

const TypedHashDecl* hashdeclCairoSurfaceInfo = nullptr;
const TypedHashDecl* hashdeclCairoMatrix = nullptr;
const TypedHashDecl* hashdeclCairoTextExtents = nullptr;
const TypedHashDecl* hashdeclCairoFontExtents = nullptr;
const TypedHashDecl* hashdeclCairoPoint = nullptr;
const TypedHashDecl* hashdeclCairoPathExtents = nullptr;

QoreNamespace CairoNs("Qore::Cairo");

static void cairo_module_init(QoreModuleInitContext& ctx, ExceptionSink& xsink) {
    hashdeclCairoSurfaceInfo = init_hashdecl_CairoSurfaceInfo(CairoNs);
    hashdeclCairoMatrix = init_hashdecl_CairoMatrix(CairoNs);
    hashdeclCairoTextExtents = init_hashdecl_CairoTextExtents(CairoNs);
    hashdeclCairoFontExtents = init_hashdecl_CairoFontExtents(CairoNs);
    hashdeclCairoPoint = init_hashdecl_CairoPoint(CairoNs);
    hashdeclCairoPathExtents = init_hashdecl_CairoPathExtents(CairoNs);

    CairoNs.addSystemClass(initCairoSurfaceClass(CairoNs));
    CairoNs.addSystemClass(initCairoPatternClass(CairoNs));
    CairoNs.addSystemClass(initCairoContextClass(CairoNs));
    CairoNs.addSystemClass(initCairoSvgReaderClass(CairoNs));
}

static void cairo_module_ns_init(QoreNamespace* rns, QoreNamespace* qns, ExceptionSink& xsink) {
    qns->addNamespace(CairoNs.copy());
}

static void cairo_module_delete() {
    // NOTE: do NOT call cairo_debug_reset_static_data() here; Qore's GC may
    // not have collected all Cairo objects yet, and the function asserts that
    // all internal hash tables are empty (font cache, etc.)
}
