# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoSvgToEpsDataProvider class definition

/** CairoSvgToEpsDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Convert SVG to EPS data provider (requires librsvg)
public class CairoSvgToEpsDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "to-eps",
            "desc": "Convert an SVG vector image to Encapsulated PostScript (EPS) format "
                "for embedding in documents. Requires librsvg.",
            "type": "CairoSvgToEpsDataProvider",
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
        return new CairoSvgToEpsRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoSvgToEpsResponse>"));
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
        float out_w = exists request.width ? float(request.width) : svg_w;
        float out_h = exists request.height ? float(request.height) : svg_h;

        if (out_w <= 0.0 || out_h <= 0.0) {
            throw "CAIRO-ERROR", sprintf("output dimensions must be positive (%.2f x %.2f)",
                out_w, out_h);
        }

        # Create PS surface with EPS mode enabled and render SVG
        CairoSurface surface = CairoSurface::createPsToData(out_w, out_h);
        surface.setEps(True);
        CairoContext ctx(surface);

        # Scale to fit output dimensions if different from SVG intrinsic size
        if (svg_w > 0.0 && svg_h > 0.0) {
            float scale_x = out_w / svg_w;
            float scale_y = out_h / svg_h;
            ctx.scale(scale_x, scale_y);
        }

        reader.renderTo(ctx);

        surface.finish();
        binary eps_data = surface.getData();

        hash<auto> output = CairoActionBase::makeOutputResponse(eps_data, request);

        hash<CairoSvgToEpsResponse> response();
        response += output;

        return response;
    }
}
}
