# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoImageResizeDataProvider class definition

/** CairoImageResizeDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Resize PNG image data provider
public class CairoImageResizeDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "resize",
            "desc": "Resize a PNG image to specified dimensions",
            "type": "CairoImageResizeDataProvider",
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
        return new CairoImageResizeRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoImageResizeResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        int target_width = int(request.target_width);
        int target_height = int(request.target_height);

        if (target_width <= 0 || target_height <= 0) {
            throw "CAIRO-ERROR", sprintf("target dimensions must be positive (%d x %d)",
                target_width, target_height);
        }

        # Load source image
        binary src_data = CairoActionBase::loadBinaryData(request);
        CairoSurface src = CairoSurface::createImageFromPngData(src_data);

        int src_width = src.getWidth();
        int src_height = src.getHeight();

        if (src_width <= 0 || src_height <= 0) {
            throw "CAIRO-ERROR", sprintf("source image has invalid dimensions (%d x %d)",
                src_width, src_height);
        }

        # Create target surface
        CairoSurface target = CairoSurface::createImage(target_width, target_height);
        CairoContext ctx(target);

        # Scale and draw source
        float sx = float(target_width) / float(src_width);
        float sy = float(target_height) / float(src_height);
        ctx.scale(sx, sy);
        ctx.setSourceSurface(src, 0.0, 0.0);
        ctx.paint();

        # Write to PNG
        binary png_data = target.writeToPngData();

        hash<auto> output = CairoActionBase::makeOutputResponse(png_data, request);

        hash<CairoImageResizeResponse> response();
        response += output;
        response.width = target_width;
        response.height = target_height;

        return response;
    }
}
}
