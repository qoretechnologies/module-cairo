# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoImageToPdfDataProvider class definition

/** CairoImageToPdfDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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

#! Contains all public definitions in the CairoDataProvider module
public namespace CairoDataProvider {
#! Convert a PNG image to PDF data provider
public class CairoImageToPdfDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "to-pdf",
            "desc": "Convert a PNG image to a single-page PDF document. The PDF page "
                "dimensions match the image pixel dimensions (in points).",
            "type": "CairoImageToPdfDataProvider",
            "supports_request": True,
        };
    }

    private {
        *hash<auto> opts;
    }

    constructor(*hash<auto> opts) {
        self.opts = opts;
    }

    string getName() {
        return ProviderInfo.name;
    }

    private hash<DataProviderInfo> getStaticInfoImpl() {
        return ProviderInfo;
    }

    private *AbstractDataProviderType getRequestTypeImpl() {
        return new CairoImageToPdfRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoImageToPdfResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        # Load PNG data
        binary src_data = CairoActionBase::loadBinaryData(request);
        CairoSurface src = CairoSurface::createImageFromPngData(src_data);
        int src_w = src.getWidth();
        int src_h = src.getHeight();

        # Create PDF surface at image dimensions and paint the image onto it
        CairoSurface pdf_surface = CairoSurface::createPdfToData(float(src_w), float(src_h));
        CairoContext ctx(pdf_surface);
        ctx.setSourceSurface(src, 0.0, 0.0);
        ctx.paint();
        pdf_surface.finish();
        binary pdf_data = pdf_surface.getData();

        hash<auto> output = CairoActionBase::makeOutputResponse(pdf_data, request);

        hash<CairoImageToPdfResponse> response();
        response += output;

        return response;
    }
}
}
