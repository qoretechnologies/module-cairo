# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoImageCropDataProvider class definition

/** CairoImageCropDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Crop PNG image data provider
public class CairoImageCropDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "crop",
            "desc": "Crop a region from a PNG image",
            "type": "CairoImageCropDataProvider",
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
        return new CairoImageCropRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoImageCropResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        int x = int(request.x);
        int y = int(request.y);
        int crop_width = int(request.crop_width);
        int crop_height = int(request.crop_height);

        if (crop_width <= 0 || crop_height <= 0) {
            throw "CAIRO-ERROR", sprintf("crop dimensions must be positive (%d x %d)",
                crop_width, crop_height);
        }

        # Load source image
        binary src_data = CairoActionBase::loadBinaryData(request);
        CairoSurface src = CairoSurface::createImageFromPngData(src_data);

        int src_width = src.getWidth();
        int src_height = src.getHeight();

        if (x < 0 || y < 0 || x + crop_width > src_width || y + crop_height > src_height) {
            throw "CAIRO-ERROR", sprintf("crop region (%d, %d, %d, %d) exceeds image bounds (%d x %d)",
                x, y, crop_width, crop_height, src_width, src_height);
        }

        # Create target surface at crop dimensions
        CairoSurface target = CairoSurface::createImage(crop_width, crop_height);
        CairoContext ctx(target);

        # Translate to offset the source and paint
        ctx.translate(float(-x), float(-y));
        ctx.setSourceSurface(src, 0.0, 0.0);
        ctx.paint();

        # Write to PNG
        binary png_data = target.writeToPngData();

        hash<auto> output = CairoActionBase::makeOutputResponse(png_data, request);

        hash<CairoImageCropResponse> response();
        response += output;
        response.width = crop_width;
        response.height = crop_height;

        return response;
    }
}
}
