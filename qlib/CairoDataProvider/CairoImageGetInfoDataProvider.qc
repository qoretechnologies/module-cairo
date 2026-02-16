# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoImageGetInfoDataProvider class definition

/** CairoImageGetInfoDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Get PNG image info data provider
public class CairoImageGetInfoDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "get-info",
            "desc": "Read the dimensions, surface type, and pixel format of a PNG image without "
                "modifying it",
            "type": "CairoImageGetInfoDataProvider",
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
        return new CairoImageGetInfoRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoImageGetInfoResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        # Load PNG data
        binary png_data = CairoActionBase::loadBinaryData(request);

        # Create image surface from PNG data
        CairoSurface surface = CairoSurface::createImageFromPngData(png_data);

        hash<Qore::Cairo::CairoSurfaceInfo> info = surface.getInfo();

        hash<CairoImageGetInfoResponse> response();
        response.width = surface.getWidth();
        response.height = surface.getHeight();
        response.type = info.type;
        response.format = info.format;
        response.success = True;

        return response;
    }
}
}
