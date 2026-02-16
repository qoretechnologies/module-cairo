# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoImageCompositeDataProvider class definition

/** CairoImageCompositeDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Composite PNG images data provider
public class CairoImageCompositeDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "composite",
            "desc": "Composite an overlay image onto a base image with optional alpha and positioning",
            "type": "CairoImageCompositeDataProvider",
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
        return new CairoImageCompositeRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoImageCompositeResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;
        list<string> warnings = ();

        float alpha = float(request.alpha ?? 1.0);
        if (alpha < 0.0 || alpha > 1.0) {
            throw "CAIRO-ERROR", sprintf("alpha must be between 0.0 and 1.0 (got %g)", alpha);
        }

        # Warn if only one of overlay_width/overlay_height is provided
        if ((exists request.overlay_width) != (exists request.overlay_height)) {
            warnings += "only one of overlay_width/overlay_height provided; both are required for "
                "scaling, ignoring";
        }

        # Load base image
        binary base_bin = CairoActionBase::loadBinaryData({
            "input_path": request.base_input_path,
            "data": request.base_data,
            "location": request.base_location,
        });
        CairoSurface base_surface = CairoSurface::createImageFromPngData(base_bin);
        int base_width = base_surface.getWidth();
        int base_height = base_surface.getHeight();

        if (base_width <= 0 || base_height <= 0) {
            throw "CAIRO-ERROR", sprintf("base image has invalid dimensions (%d x %d)",
                base_width, base_height);
        }

        # Load overlay image
        binary overlay_bin = CairoActionBase::loadBinaryData({
            "input_path": request.overlay_input_path,
            "data": request.overlay_data,
            "location": request.overlay_location,
        });
        CairoSurface overlay_surface = CairoSurface::createImageFromPngData(overlay_bin);
        int overlay_width = overlay_surface.getWidth();
        int overlay_height = overlay_surface.getHeight();

        if (overlay_width <= 0 || overlay_height <= 0) {
            throw "CAIRO-ERROR", sprintf("overlay image has invalid dimensions (%d x %d)",
                overlay_width, overlay_height);
        }

        # Create output surface (same dimensions as base)
        CairoSurface output = CairoSurface::createImage(base_width, base_height);
        CairoContext ctx(output);

        # Draw base image
        ctx.setSourceSurface(base_surface, 0.0, 0.0);
        ctx.paint();

        # Draw overlay
        float x = float(request.x ?? 0.0);
        float y = float(request.y ?? 0.0);

        ctx.save();
        ctx.translate(x, y);

        if (exists request.overlay_width && exists request.overlay_height) {
            float sw = float(request.overlay_width) / float(overlay_width);
            float sh = float(request.overlay_height) / float(overlay_height);
            ctx.scale(sw, sh);
        }

        ctx.setSourceSurface(overlay_surface, 0.0, 0.0);
        if (alpha < 1.0) {
            ctx.paintWithAlpha(alpha);
        } else {
            ctx.paint();
        }
        ctx.restore();

        # Write to PNG
        binary png_data = output.writeToPngData();

        hash<auto> out = CairoActionBase::makeOutputResponse(png_data, request);

        hash<CairoImageCompositeResponse> response();
        response += out;
        response.width = base_width;
        response.height = base_height;
        if (warnings) {
            response.warnings = warnings;
        }

        return response;
    }
}
}
