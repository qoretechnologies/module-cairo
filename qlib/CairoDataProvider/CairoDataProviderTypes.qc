# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoDataProvider type definitions

/** CairoDataProviderTypes.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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

# ========== Common Field Constants ==========

#! Common input fields for actions that read a file (input_path, data, or location)
const CairoInputFields = {
    "input_path": {
        "type": StringOrNothingType,
        "display_name": "Input File Path",
        "short_desc": "Path to input file",
        "desc": "File path to read input from. One of 'input_path', 'data', or 'location' "
            "must be provided.",
    },
    "data": {
        "type": BinaryOrNothingType,
        "display_name": "Input Data",
        "short_desc": "Binary input data",
        "desc": "Binary data of the input. One of 'input_path', 'data', or 'location' "
            "must be provided.",
    },
    "location": {
        "type": StringOrNothingType,
        "display_name": "Input Location",
        "short_desc": "Location of input file",
        "desc": "A file location string as supported by the "
            "[FileLocationHandler](https://docs.qore.org/current/modules/FileLocationHandler/html/index.html) "
            "module. One of 'input_path', 'data', or 'location' must be provided.",
    },
};

#! Common output fields for actions that produce output data
const CairoOutputFields = {
    "output_path": {
        "type": StringOrNothingType,
        "display_name": "Output File Path",
        "short_desc": "Path to write the output to",
        "desc": "File path to write the output to. If neither 'output_path' nor "
            "'output_location' is provided, the data is returned in the response only.",
    },
    "output_location": {
        "type": StringOrNothingType,
        "display_name": "Output Location",
        "short_desc": "Location to write the output to",
        "desc": "A file location string as supported by the "
            "[FileLocationHandler](https://docs.qore.org/current/modules/FileLocationHandler/html/index.html) "
            "module.",
    },
    "return_data": {
        "type": BoolOrNothingType,
        "display_name": "Return Data",
        "short_desc": "Whether to include data in the response",
        "desc": "Whether to include binary data in the response hash. Defaults to True when "
            "no output path or location is specified, False otherwise.",
    },
};

#! Common output response fields
const CairoOutputResponseFields = {
    "data": {
        "type": BinaryOrNothingType,
        "display_name": "Output Data",
        "short_desc": "The output binary data",
        "desc": "Binary output data. Only included when 'return_data' is true "
            "(default when no output destination is specified).",
    },
    "output_path": {
        "type": StringOrNothingType,
        "display_name": "Output File Path",
        "short_desc": "Path the output was written to",
        "desc": "File path where the output was written",
    },
    "output_location": {
        "type": StringOrNothingType,
        "display_name": "Output Location",
        "short_desc": "Location the output was written to",
        "desc": "File location where the output was written",
    },
    "size": {
        "type": IntType,
        "display_name": "Size",
        "short_desc": "Output data size in bytes",
        "desc": "Size of the output data in bytes",
    },
};

#! Draw commands field
const CairoDrawCommandsField = {
    "commands": {
        "type": new Type("list<hash<auto>>"),
        "display_name": "Draw Commands",
        "short_desc": "List of draw commands",
        "desc": "List of draw command hashes. Each command has an 'op' key specifying the "
            "operation. Supported ops: set_source_rgb, set_source_rgba, set_line_width, "
            "set_font, move_to, line_to, curve_to, arc, rectangle, close_path, stroke, fill, "
            "paint, text, save, restore, translate, rotate, scale, set_dash, set_line_cap, "
            "set_line_join, linear_gradient, radial_gradient, image, show_page, clip",
    },
};

# ========== SVG Create ==========

#! Request type for creating an SVG
public hashdecl CairoSvgCreateRequest {
    #! Surface width in points
    float width;

    #! Surface height in points
    float height;

    #! Draw commands
    list<hash<auto>> commands;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for creating an SVG
public hashdecl CairoSvgCreateResponse {
    #! Output SVG data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;
}

# ========== SVG Get Info ==========

#! Request type for getting SVG info
public hashdecl CairoSvgGetInfoRequest {
    #! Input file path
    *string input_path;

    #! Binary SVG data
    *binary data;

    #! Input location
    *string location;
}

#! Response type for SVG info
public hashdecl CairoSvgGetInfoResponse {
    #! SVG width
    float width;

    #! SVG height
    float height;

    #! SVG metadata
    hash<auto> metadata;
}

# ========== SVG To PNG ==========

#! Request type for converting SVG to PNG
public hashdecl CairoSvgToPngRequest {
    #! Input file path
    *string input_path;

    #! Binary SVG data
    *binary data;

    #! Input location
    *string location;

    #! Output width in pixels (default: use SVG intrinsic width)
    *int width;

    #! Output height in pixels (default: use SVG intrinsic height)
    *int height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for SVG to PNG conversion
public hashdecl CairoSvgToPngResponse {
    #! Output PNG data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;

    #! Image width in pixels
    int width;

    #! Image height in pixels
    int height;
}

# ========== SVG To PS ==========

#! Request type for converting SVG to PostScript
public hashdecl CairoSvgToPsRequest {
    #! Input file path
    *string input_path;

    #! Binary SVG data
    *binary data;

    #! Input location
    *string location;

    #! Output width in points (default: use SVG intrinsic width)
    *float width;

    #! Output height in points (default: use SVG intrinsic height)
    *float height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for SVG to PostScript conversion
public hashdecl CairoSvgToPsResponse {
    #! Output PS data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;
}

# ========== SVG To EPS ==========

#! Request type for converting SVG to EPS
public hashdecl CairoSvgToEpsRequest {
    #! Input file path
    *string input_path;

    #! Binary SVG data
    *binary data;

    #! Input location
    *string location;

    #! Output width in points (default: use SVG intrinsic width)
    *float width;

    #! Output height in points (default: use SVG intrinsic height)
    *float height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for SVG to EPS conversion
public hashdecl CairoSvgToEpsResponse {
    #! Output EPS data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;
}

# ========== Image Create ==========

#! Request type for creating a PNG image
public hashdecl CairoImageCreateRequest {
    #! Image width in pixels
    int width;

    #! Image height in pixels
    int height;

    #! Pixel format: "ARGB32" (default), "RGB24", "A8", "A1"
    *string format;

    #! Draw commands
    list<hash<auto>> commands;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for creating a PNG image
public hashdecl CairoImageCreateResponse {
    #! Output PNG data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;

    #! Image width in pixels
    int width;

    #! Image height in pixels
    int height;
}

# ========== Image Get Info ==========

#! Request type for getting PNG image info
public hashdecl CairoImageGetInfoRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;
}

#! Response type for PNG image info
public hashdecl CairoImageGetInfoResponse {
    #! Image width in pixels
    int width;

    #! Image height in pixels
    int height;

    #! Surface type
    string type;

    #! Pixel format
    *string format;
}

# ========== Image Draw ==========

#! Request type for drawing on an existing PNG
public hashdecl CairoImageDrawRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! Draw commands
    list<hash<auto>> commands;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for drawing on an existing PNG
public hashdecl CairoImageDrawResponse {
    #! Output PNG data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;

    #! Image width in pixels
    int width;

    #! Image height in pixels
    int height;
}

# ========== PostScript Create ==========

#! Request type for creating a PostScript document
public hashdecl CairoPostScriptCreateRequest {
    #! Page width in points
    float width;

    #! Page height in points
    float height;

    #! Enable EPS mode
    *bool eps;

    #! Draw commands
    list<hash<auto>> commands;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for creating a PostScript document
public hashdecl CairoPostScriptCreateResponse {
    #! Output PS/EPS data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;
}

# ========== HashDataType Request Classes ==========

#! SVG create request type
public class CairoSvgCreateRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields({
            "width": {
                "type": FloatType,
                "display_name": "Width",
                "short_desc": "SVG width in points",
                "desc": "Width of the SVG surface in points",
            },
            "height": {
                "type": FloatType,
                "display_name": "Height",
                "short_desc": "SVG height in points",
                "desc": "Height of the SVG surface in points",
            },
        });
        addQoreFields(CairoDrawCommandsField);
        addQoreFields(CairoOutputFields);
    }
}

#! SVG get info request type
public class CairoSvgGetInfoRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields(CairoInputFields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! SVG to PNG request type
public class CairoSvgToPngRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields(CairoInputFields);
        addQoreFields({
            "width": {
                "type": IntOrNothingType,
                "display_name": "Width",
                "short_desc": "Output width in pixels",
                "desc": "Output image width in pixels. Default: use SVG intrinsic width.",
            },
            "height": {
                "type": IntOrNothingType,
                "display_name": "Height",
                "short_desc": "Output height in pixels",
                "desc": "Output image height in pixels. Default: use SVG intrinsic height.",
            },
        });
        addQoreFields(CairoOutputFields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! SVG to PS request type
public class CairoSvgToPsRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields(CairoInputFields);
        addQoreFields({
            "width": {
                "type": FloatOrNothingType,
                "display_name": "Width",
                "short_desc": "Output width in points",
                "desc": "Output page width in points. Default: use SVG intrinsic width.",
            },
            "height": {
                "type": FloatOrNothingType,
                "display_name": "Height",
                "short_desc": "Output height in points",
                "desc": "Output page height in points. Default: use SVG intrinsic height.",
            },
        });
        addQoreFields(CairoOutputFields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! SVG to EPS request type
public class CairoSvgToEpsRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields(CairoInputFields);
        addQoreFields({
            "width": {
                "type": FloatOrNothingType,
                "display_name": "Width",
                "short_desc": "Output width in points",
                "desc": "Output page width in points. Default: use SVG intrinsic width.",
            },
            "height": {
                "type": FloatOrNothingType,
                "display_name": "Height",
                "short_desc": "Output height in points",
                "desc": "Output page height in points. Default: use SVG intrinsic height.",
            },
        });
        addQoreFields(CairoOutputFields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image create request type
public class CairoImageCreateRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields({
            "width": {
                "type": IntType,
                "display_name": "Width",
                "short_desc": "Image width in pixels",
                "desc": "Width of the image in pixels",
            },
            "height": {
                "type": IntType,
                "display_name": "Height",
                "short_desc": "Image height in pixels",
                "desc": "Height of the image in pixels",
            },
            "format": {
                "type": StringType,
                "display_name": "Format",
                "short_desc": "Pixel format",
                "desc": "Pixel format for the image surface",
                "default_value": "ARGB32",
                "allowed_values": (
                    <AllowedValueInfo>{"value": "ARGB32", "desc": "32-bit ARGB (default)"},
                    <AllowedValueInfo>{"value": "RGB24", "desc": "32-bit RGB (no alpha)"},
                    <AllowedValueInfo>{"value": "A8", "desc": "8-bit alpha mask"},
                    <AllowedValueInfo>{"value": "A1", "desc": "1-bit alpha mask"},
                ),
            },
        });
        addQoreFields(CairoDrawCommandsField);
        addQoreFields(CairoOutputFields);
    }
}

#! Image get info request type
public class CairoImageGetInfoRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields(CairoInputFields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image draw request type
public class CairoImageDrawRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields(CairoInputFields);
        addQoreFields(CairoDrawCommandsField);
        addQoreFields(CairoOutputFields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! PostScript create request type
public class CairoPostScriptCreateRequestDataType inherits HashDataType {
    constructor() {
        addQoreFields({
            "width": {
                "type": FloatType,
                "display_name": "Width",
                "short_desc": "Page width in points",
                "desc": "Width of the PostScript page in points (72 points = 1 inch)",
            },
            "height": {
                "type": FloatType,
                "display_name": "Height",
                "short_desc": "Page height in points",
                "desc": "Height of the PostScript page in points (72 points = 1 inch)",
            },
            "eps": {
                "type": BoolOrNothingType,
                "display_name": "EPS Mode",
                "short_desc": "Enable EPS mode",
                "desc": "If True, create Encapsulated PostScript (EPS) output",
                "default_value": False,
            },
        });
        addQoreFields(CairoDrawCommandsField);
        addQoreFields(CairoOutputFields);
    }
}
}
