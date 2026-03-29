# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoTextRenderDataProvider class definition

/** CairoTextRenderDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Render text to a PNG image data provider
public class CairoTextRenderDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "render",
            "desc": "Render text to a PNG image with specified font, color, and optional "
                "background. The image is automatically sized to fit the text.",
            "type": "CairoTextRenderDataProvider",
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
        return new CairoTextRenderRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoTextRenderResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        string text_str = string(request.text);
        string family = request.family ?? "sans-serif";
        string slant = request.slant ?? "normal";
        string weight = request.weight ?? "normal";
        float font_size = float(request.size ?? 12.0);
        int padding = int(request.padding ?? 0);

        # Measure text on a temporary surface
        CairoSurface measure_surface = CairoSurface::createImage(1, 1);
        CairoContext measure_ctx(measure_surface);
        measure_ctx.selectFontFace(family, slant, weight);
        measure_ctx.setFontSize(font_size);

        hash<CairoTextExtents> ext = measure_ctx.textExtents(text_str);
        hash<CairoFontExtents> fext = measure_ctx.fontExtents();

        # Calculate image dimensions
        int img_w = int(ceil(ext.x_advance)) + padding * 2;
        int img_h = int(ceil(fext.ascent + fext.descent)) + padding * 2;

        if (img_w <= 0) {
            img_w = 1;
        }
        if (img_h <= 0) {
            img_h = 1;
        }

        # Create the image surface
        CairoSurface surface = CairoSurface::createImage(img_w, img_h, "ARGB32");
        CairoContext ctx(surface);

        # Draw background if alpha > 0
        float bg_a = float(request.bg_a ?? 0.0);
        if (bg_a > 0.0) {
            ctx.setSourceRgba(float(request.bg_r ?? 1.0), float(request.bg_g ?? 1.0),
                float(request.bg_b ?? 1.0), bg_a);
            ctx.paint();
        }

        # Set text color and font
        ctx.setSourceRgba(float(request.r ?? 0.0), float(request.g ?? 0.0),
            float(request.b ?? 0.0), float(request.a ?? 1.0));
        ctx.selectFontFace(family, slant, weight);
        ctx.setFontSize(font_size);

        # Position text at padding + ascent for correct baseline placement
        ctx.moveTo(float(padding), float(padding) + fext.ascent);
        ctx.showText(text_str);

        binary png_data = surface.writeToPngData();

        hash<auto> output = CairoActionBase::makeOutputResponse(png_data, request);

        hash<CairoTextRenderResponse> response();
        response += output;
        response.width = img_w;
        response.height = img_h;

        return response;
    }
}
}
