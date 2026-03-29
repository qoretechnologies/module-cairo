# -*- mode: qore; indent-tabs-mode: nil -*-
#! @file CairoImageDataProvider.qc provides the CairoImageDataProvider class definition

/** CairoImageDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
/** @brief Data provider for image operations

    This provider exposes image actions:
    - @b create - Create PNG from draw commands
    - @b get-info - Get PNG image info
    - @b draw - Draw on existing PNG
    - @b resize - Resize a PNG image
    - @b crop - Crop a region from a PNG image
    - @b composite - Composite an overlay image onto a base image
    - @b rotate - Rotate a PNG image by a specified angle
    - @b to-svg - Convert PNG to SVG
    - @b to-ps - Convert PNG to PostScript
    - @b to-eps - Convert PNG to EPS
    - @b to-pdf - Convert PNG to PDF (requires PDF support)

    @par Data Provider Path
    Access via: @verbatim cairo{}/image/<action> @endverbatim
*/
public class CairoImageDataProvider inherits AbstractDataProvider {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "image",
            "desc": "PNG image creation and manipulation actions",
            "type": "CairoImageDataProvider",
            "supports_request": False,
        };
    }

    private {
        #! Base child map (always available)
        const BaseChildMap = {
            "create": "CairoDataProvider::CairoImageCreateDataProvider",
            "get-info": "CairoDataProvider::CairoImageGetInfoDataProvider",
            "draw": "CairoDataProvider::CairoImageDrawDataProvider",
            "resize": "CairoDataProvider::CairoImageResizeDataProvider",
            "crop": "CairoDataProvider::CairoImageCropDataProvider",
            "composite": "CairoDataProvider::CairoImageCompositeDataProvider",
            "rotate": "CairoDataProvider::CairoImageRotateDataProvider",
            "to-svg": "CairoDataProvider::CairoImageToSvgDataProvider",
            "to-ps": "CairoDataProvider::CairoImageToPsDataProvider",
            "to-eps": "CairoDataProvider::CairoImageToEpsDataProvider",
        };
        *hash<auto> opts;
        hash<string, string> childMap;
    }

    constructor(*hash<auto> opts) {
        self.opts = opts;
        childMap = BaseChildMap;
        if (CairoSurface::isPdfAvailable()) {
            childMap{"to-pdf"} = "CairoDataProvider::CairoImageToPdfDataProvider";
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
