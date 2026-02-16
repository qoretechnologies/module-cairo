# -*- mode: qore; indent-tabs-mode: nil -*-
#! @file CairoTextDataProvider.qc provides the CairoTextDataProvider class definition

/** CairoTextDataProvider.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
/** @brief Data provider for text measurement operations

    This provider exposes text actions:
    - @b measure - Measure text dimensions
    - @b get-font-metrics - Get font metrics

    @par Data Provider Path
    Access via: @verbatim cairo{}/text/<action> @endverbatim
*/
public class CairoTextDataProvider inherits AbstractDataProvider {
    public {
        const ProviderInfo = <DataProviderInfo>{
            "name": "text",
            "desc": "Text measurement and font metrics actions",
            "type": "CairoTextDataProvider",
            "supports_request": False,
        };
    }

    private {
        const ChildMap = {
            "measure": "CairoDataProvider::CairoTextMeasureDataProvider",
            "get-font-metrics": "CairoDataProvider::CairoFontGetMetricsDataProvider",
        };
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

    private *AbstractDataProvider getChildProviderImpl(string name) {
        *string cls_name = ChildMap{name};
        if (!cls_name) {
            return NOTHING;
        }
        Class cls = Class::forName(cls_name);
        return cls.newObject(opts);
    }

    private *list<string> getChildProviderNamesImpl() {
        return keys ChildMap;
    }
}
}
