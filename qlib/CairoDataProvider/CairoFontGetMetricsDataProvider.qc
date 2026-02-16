# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoFontGetMetricsDataProvider class definition

/** CairoFontGetMetricsDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Get font metrics data provider
public class CairoFontGetMetricsDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "get-font-metrics",
            "desc": "Get font metrics (ascent, descent, height, max advance) for a given font",
            "type": "CairoFontGetMetricsDataProvider",
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
        return new CairoFontGetMetricsRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoFontGetMetricsResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        # Create a small image surface for measuring
        CairoSurface surface = CairoSurface::createImage(1, 1);
        CairoContext ctx(surface);

        # Set font
        string family = request.family ?? "sans-serif";
        string slant = request.slant ?? "normal";
        string weight = request.weight ?? "normal";
        float size = float(request.size ?? 12.0);
        if (size <= 0.0) {
            throw "CAIRO-ERROR", sprintf("font size must be positive (got %g)", size);
        }
        ctx.selectFontFace(family, slant, weight);
        ctx.setFontSize(size);

        # Get font extents
        hash<CairoFontExtents> ext = ctx.fontExtents();

        return <CairoFontGetMetricsResponse>{
            "success": True,
            "ascent": ext.ascent,
            "descent": ext.descent,
            "height": ext.height,
            "max_x_advance": ext.max_x_advance,
            "max_y_advance": ext.max_y_advance,
        };
    }
}
}
