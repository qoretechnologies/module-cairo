# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoSvgCreateDataProvider class definition

/** CairoSvgCreateDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Create SVG data provider
public class CairoSvgCreateDataProvider inherits CairoActionBase {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "create",
            "desc": "Create an SVG vector image from declarative draw commands specifying "
                "shapes, text, colors, and transformations",
            "type": "CairoSvgCreateDataProvider",
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
        return new CairoSvgCreateRequestDataType();
    }

    private *AbstractDataProviderType getResponseTypeImpl() {
        return AbstractDataProviderType::get(new Type("hash<CairoSvgCreateResponse>"));
    }

    private auto doRequestImpl(auto req, *hash<auto> request_options) {
        hash<auto> request = req;

        float width = float(request.width);
        float height = float(request.height);

        if (width <= 0.0 || height <= 0.0) {
            throw "CAIRO-ERROR", sprintf("SVG dimensions must be positive (%.2f x %.2f)",
                width, height);
        }

        # Create SVG surface writing to memory
        CairoSurface surface = CairoSurface::createSvgToData(width, height);
        CairoContext ctx(surface);

        # Execute draw commands
        CairoActionBase::executeDrawCommands(ctx, request.commands);

        # Finalize and get data
        surface.finish();
        binary svg_data = surface.getData();

        hash<auto> output = CairoActionBase::makeOutputResponse(svg_data, request);

        hash<CairoSvgCreateResponse> response();
        response += output;

        return response;
    }
}
}
