# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoSvgCenterDataProvider class definition

/** CairoSvgCenterDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Center SVG content on a square canvas (requires librsvg)
/** Reads an SVG, makes the canvas square (using the larger dimension), and centers the
    content on both axes.  By default the output overwrites the input file.
*/
public class CairoSvgCenterDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "center",
            "desc": "Center SVG content on a square canvas. Reads an SVG, makes the canvas "
                "square (using the larger of width/height), and centers the content on both "
                "axes. By default the output overwrites the input file. Requires librsvg.",
            "type": "CairoSvgCenterDataProvider",
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
        return new CairoSvgCenterRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoSvgCenterResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        # Default overwrite to True when no explicit output is given
        if (!exists request.output_path && !exists request.output_location
                && !exists request.return_data) {
            request.overwrite = True;
        }

        # Load SVG data
        binary svg_data = CairoActionBase::loadBinaryData(request);

        # Parse with librsvg to get dimensions
        CairoSvgReader reader(svg_data);
        float svg_w = reader.getWidth();
        float svg_h = reader.getHeight();

        if (svg_w <= 0.0 || svg_h <= 0.0) {
            throw "CAIRO-ERROR", sprintf("SVG has non-positive dimensions (%.1f x %.1f)",
                svg_w, svg_h);
        }

        # Compute square canvas size
        float side = svg_w > svg_h ? svg_w : svg_h;

        # Compute centering offsets
        float dx = (side - svg_w) / 2.0;
        float dy = (side - svg_h) / 2.0;

        # Create new SVG surface, translate to center, and render
        CairoSurface surface = CairoSurface::createSvgToData(side, side);
        CairoContext ctx(surface);
        ctx.translate(dx, dy);
        reader.renderTo(ctx);
        surface.finish();

        binary out_data = surface.getData();

        hash<auto> output = CairoActionBase::makeOutputResponse(out_data, request);

        hash<CairoSvgCenterResponse> response();
        response += output;
        response.original_width = svg_w;
        response.original_height = svg_h;
        response.canvas_size = side;

        return response;
    }
}
}
