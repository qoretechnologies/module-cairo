# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoImageCreateDataProvider class definition

/** CairoImageCreateDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Create PNG image data provider
public class CairoImageCreateDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "create",
            "desc": "Create PNG from draw commands",
            "type": "CairoImageCreateDataProvider",
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
        return new CairoImageCreateRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoImageCreateResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        int width = int(request.width);
        int height = int(request.height);
        string format = request.format ?? "ARGB32";

        if (width <= 0 || height <= 0) {
            throw "CAIRO-ERROR", sprintf("image dimensions must be positive (%d x %d)",
                width, height);
        }

        # Create image surface
        CairoSurface surface = CairoSurface::createImage(width, height, format);
        CairoContext ctx(surface);

        # Execute draw commands
        CairoActionBase::executeDrawCommands(ctx, request.commands);

        # Get PNG data
        binary png_data = surface.writeToPngData();

        hash<auto> output = CairoActionBase::makeOutputResponse(png_data, request);

        hash<CairoImageCreateResponse> response();
        response += output;
        response.width = width;
        response.height = height;

        return response;
    }
}
}
