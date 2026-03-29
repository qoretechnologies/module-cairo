# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoImageRotateDataProvider class definition

/** CairoImageRotateDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Rotate a PNG image data provider
public class CairoImageRotateDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "rotate",
            "desc": "Rotate a PNG image by a specified angle in degrees. The output canvas "
                "is automatically sized to contain the full rotated image.",
            "type": "CairoImageRotateDataProvider",
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
        return new CairoImageRotateRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoImageRotateResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        # Load PNG data
        binary src_data = CairoActionBase::loadBinaryData(request);
        CairoSurface src = CairoSurface::createImageFromPngData(src_data);
        int src_w = src.getWidth();
        int src_h = src.getHeight();

        # Convert angle from degrees to radians
        float angle_deg = float(request.angle);
        float angle_rad = angle_deg * M_PI / 180.0;

        # Compute bounding box of rotated image
        # Round near-zero values to avoid floating-point artifacts at exact angles
        float cos_a = abs(cos(angle_rad));
        float sin_a = abs(sin(angle_rad));
        if (cos_a < 1e-10) {
            cos_a = 0.0;
        }
        if (sin_a < 1e-10) {
            sin_a = 0.0;
        }
        int out_w = int(ceil(float(src_w) * cos_a + float(src_h) * sin_a));
        int out_h = int(ceil(float(src_w) * sin_a + float(src_h) * cos_a));

        if (out_w <= 0) {
            out_w = 1;
        }
        if (out_h <= 0) {
            out_h = 1;
        }

        # Create target surface and apply rotation
        CairoSurface target = CairoSurface::createImage(out_w, out_h, "ARGB32");
        CairoContext ctx(target);

        # Translate to center of output, rotate, translate back by half source dims
        ctx.translate(float(out_w) / 2.0, float(out_h) / 2.0);
        ctx.rotate(angle_rad);
        ctx.translate(-float(src_w) / 2.0, -float(src_h) / 2.0);

        ctx.setSourceSurface(src, 0.0, 0.0);
        ctx.paint();

        binary png_data = target.writeToPngData();

        hash<auto> output = CairoActionBase::makeOutputResponse(png_data, request);

        hash<CairoImageRotateResponse> response();
        response += output;
        response.width = out_w;
        response.height = out_h;

        return response;
    }
}
}
