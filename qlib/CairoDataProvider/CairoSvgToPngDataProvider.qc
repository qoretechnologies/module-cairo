# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoSvgToPngDataProvider class definition

/** CairoSvgToPngDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Convert SVG to PNG data provider (requires librsvg)
public class CairoSvgToPngDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "to-png",
            "desc": "Convert SVG to PNG (requires librsvg)",
            "type": "CairoSvgToPngDataProvider",
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
        return new CairoSvgToPngRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoSvgToPngResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        # Load SVG data
        binary svg_data = CairoActionBase::loadBinaryData(request);

        # Parse with librsvg
        CairoSvgReader reader(svg_data);

        # Determine output dimensions
        float svg_w = reader.getWidth();
        float svg_h = reader.getHeight();
        int out_w = exists request.width ? int(request.width) : int(svg_w);
        int out_h = exists request.height ? int(request.height) : int(svg_h);

        if (out_w <= 0 || out_h <= 0) {
            throw "CAIRO-ERROR", sprintf("output dimensions must be positive (%d x %d)",
                out_w, out_h);
        }

        # Create image surface and render SVG
        CairoSurface surface = CairoSurface::createImage(out_w, out_h, "ARGB32");
        CairoContext ctx(surface);

        # Scale to fit output dimensions if different from SVG intrinsic size
        if (svg_w > 0.0 && svg_h > 0.0) {
            float scale_x = float(out_w) / svg_w;
            float scale_y = float(out_h) / svg_h;
            ctx.scale(scale_x, scale_y);
        }

        reader.renderTo(ctx);

        # Get PNG data
        binary png_data = surface.writeToPngData();

        hash<auto> output = CairoActionBase::makeOutputResponse(png_data, request);

        hash<CairoSvgToPngResponse> response();
        response += output;
        response.width = out_w;
        response.height = out_h;

        return response;
    }
}
}
