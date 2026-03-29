# -*- mode: qore; indent-tabs-mode: nil -*-
#! @file CairoSvgDataProvider.qc provides the CairoSvgDataProvider class definition

/** CairoSvgDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
/** @brief Data provider for SVG operations

    This provider exposes SVG actions:
    - @b create - Create SVG from draw commands
    - @b center - Center SVG on a square canvas (requires librsvg)
    - @b get-info - Get SVG dimensions and metadata (requires librsvg)
    - @b to-png - Convert SVG to PNG (requires librsvg)
    - @b to-ps - Convert SVG to PostScript (requires librsvg)
    - @b to-eps - Convert SVG to EPS (requires librsvg)
    - @b to-pdf - Convert SVG to PDF (requires librsvg and PDF support)

    @par Data Provider Path
    Access via: @verbatim cairo{}/svg/<action> @endverbatim
*/
public class CairoSvgDataProvider inherits AbstractDataProvider {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "svg",
            "desc": "SVG creation and conversion actions",
            "type": "CairoSvgDataProvider",
            "supports_request": False,
        };
    }

    private {
        #! Base child map (always available)
        const BaseChildMap = {
            "create": "CairoDataProvider::CairoSvgCreateDataProvider",
        };
        #! Additional children requiring librsvg
        const RsvgChildMap = {
            "center": "CairoDataProvider::CairoSvgCenterDataProvider",
            "get-info": "CairoDataProvider::CairoSvgGetInfoDataProvider",
            "to-png": "CairoDataProvider::CairoSvgToPngDataProvider",
            "to-ps": "CairoDataProvider::CairoSvgToPsDataProvider",
            "to-eps": "CairoDataProvider::CairoSvgToEpsDataProvider",
        };
        *hash<auto> opts;
        hash<string, string> childMap;
    }

    constructor(*hash<auto> opts) {
        self.opts = opts;
        childMap = BaseChildMap;
        if (CairoSvgReader::isAvailable()) {
            childMap += RsvgChildMap;
            if (CairoSurface::isPdfAvailable()) {
                childMap{"to-pdf"} = "CairoDataProvider::CairoSvgToPdfDataProvider";
            }
        }
    }

    string getName() {
        return ProviderInfo.name;
    }

    private hash<DataProviderInfo> getStaticInfoImpl() {
        return ProviderInfo;
    }

    private *AbstractDataProvider getChildProviderImpl(string name) {
        *string cls_name = childMap{name};
        if (!cls_name) {
            return NOTHING;
        }
        Class cls = Class::forName(cls_name);
        return cls.newObject(opts);
    }

    private *list<string> getChildProviderNamesImpl() {
        return keys childMap;
    }
}
}
