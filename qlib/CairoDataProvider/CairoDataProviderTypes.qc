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
        "example_value": "/path/to/input.svg",
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
            "module (e.g. `file:///path/to/input.png`, `https://example.com/image.png`). "
            "One of 'input_path', 'data', or 'location' must be provided.",
        "example_value": "file:///path/to/input.png",
    },
};

#! Common output fields for actions that produce output data
const CairoOutputFields = {
    "output_path": {
        "type": StringOrNothingType,
        "display_name": "Output File Path",
        "short_desc": "Path to write the output to",
        "desc": "File path to write the processed output to. If neither 'output_path' nor "
            "'output_location' is provided, the data is returned in the response only.",
        "example_value": "/path/to/output.png",
    },
    "output_location": {
        "type": StringOrNothingType,
        "display_name": "Output Location",
        "short_desc": "Location to write the output to",
        "desc": "A file location string as supported by the "
            "[FileLocationHandler](https://docs.qore.org/current/modules/FileLocationHandler/html/index.html) "
            "module (e.g. `file:///path/to/output.png`, `sftp://host/path/output.png`). "
            "If neither 'output_path' nor 'output_location' is provided, the data is returned "
            "in the response only.",
        "example_value": "file:///path/to/output.png",
    },
    "return_data": {
        "type": BoolOrNothingType,
        "display_name": "Return Data",
        "short_desc": "Whether to include data in the response",
        "desc": "Whether to include binary data in the response hash. Defaults to True when "
            "no output path or location is specified, False when an output destination is provided.",
    },
    "overwrite": {
        "type": BoolOrNothingType,
        "display_name": "Overwrite",
        "short_desc": "Overwrite the input file",
        "desc": "If true and output_path is not specified, the input file will be overwritten "
            "(only applicable when input_path is used).",
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
    "success": {
        "type": BoolType,
        "display_name": "Success",
        "short_desc": "Whether the operation succeeded",
        "desc": "True if the operation completed successfully",
    },
    "warnings": {
        "type": new Type("*list<string>"),
        "display_name": "Warnings",
        "short_desc": "Warnings encountered during processing",
        "desc": "List of warning messages encountered during processing, if any",
    },
};

#! Common font fields for text and font metric operations
const CairoFontFields = {
    "family": {
        "type": StringOrNothingType,
        "display_name": "Font Family",
        "short_desc": "Font family name",
        "desc": "Font family name (e.g., 'sans-serif', 'Helvetica'). Default: 'sans-serif'",
        "default_value": "sans-serif",
    },
    "size": {
        "type": FloatOrNothingType,
        "display_name": "Font Size",
        "short_desc": "Font size",
        "desc": "Font size in user-space units. Default: 12.0",
        "default_value": 12.0,
    },
    "slant": {
        "type": StringOrNothingType,
        "display_name": "Font Slant",
        "short_desc": "Font slant style",
        "desc": "Font slant: 'normal', 'italic', or 'oblique'. Default: 'normal'",
        "default_value": "normal",
        "allowed_values": (
            <AllowedValueInfo>{"value": "normal", "desc": "Normal (upright) style"},
            <AllowedValueInfo>{"value": "italic", "desc": "Italic style"},
            <AllowedValueInfo>{"value": "oblique", "desc": "Oblique style"},
        ),
    },
    "weight": {
        "type": StringOrNothingType,
        "display_name": "Font Weight",
        "short_desc": "Font weight",
        "desc": "Font weight: 'normal' or 'bold'. Default: 'normal'",
        "default_value": "normal",
        "allowed_values": (
            <AllowedValueInfo>{"value": "normal", "desc": "Normal weight"},
            <AllowedValueInfo>{"value": "bold", "desc": "Bold weight"},
        ),
    },
};

#! Draw commands field
const CairoDrawCommandsField = {
    "commands": {
        "type": new Type("list<hash<auto>>"),
        "display_name": "Draw Commands",
        "short_desc": "List of draw commands",
        "desc": "List of draw command hashes. Each command has an 'op' key specifying the "
            "operation and operation-specific parameters.\n\n"
            "Coordinate system: dimensions are in points (1 point = 1/72 inch). "
            "US Letter = 612 x 792 points; A4 = 595 x 842 points.\n\n"
            "Color and style: set_source_rgb (r, g, b), set_source_rgba (r, g, b, a) — "
            "color values are floats in range 0.0–1.0 (e.g. r=1.0 is full red). "
            "set_line_width (width), set_line_cap (cap: butt, round, square), "
            "set_line_join (join: miter, round, bevel), "
            "set_dash (dashes, offset), set_miter_limit (limit), set_tolerance (tolerance), "
            "set_fill_rule (rule: winding, even-odd), "
            "set_operator (op_name), set_antialias (aa: default, none, gray, subpixel)\n\n"
            "Paths: move_to (x, y), line_to (x, y), curve_to (x1, y1, x2, y2, x3, y3), "
            "rel_move_to (dx, dy), rel_line_to (dx, dy), "
            "rel_curve_to (dx1, dy1, dx2, dy2, dx3, dy3), "
            "arc (x, y, radius, angle1, angle2), arc_negative (x, y, radius, angle1, angle2) "
            "— angles are in radians (0 = 3 o'clock, pi/2 = 6 o'clock), "
            "rectangle (x, y, width, height), close_path, new_path, new_sub_path\n\n"
            "Drawing: stroke, fill, paint (alpha), stroke_preserve, fill_preserve, "
            "clip, clip_preserve, reset_clip, text_path (text)\n\n"
            "Text: text (text, x, y, family, size, slant, weight), "
            "set_font (family, size, slant, weight), set_font_size (size)\n\n"
            "Transforms: translate (x, y), rotate (angle — radians), scale (x, y), "
            "identity_matrix, "
            "set_matrix (xx, yx, xy, yy, x0, y0), transform (xx, yx, xy, yy, x0, y0)\n\n"
            "Gradients: linear_gradient (x0, y0, x1, y1, stops, extend, filter), "
            "radial_gradient (cx0, cy0, r0, cx1, cy1, r1, stops, extend, filter). "
            "Stops: list of hashes with offset (0.0–1.0), r, g, b, and optional a "
            "(e.g. [{\"offset\": 0.0, \"r\": 1.0, \"g\": 0.0, \"b\": 0.0}, ...]). "
            "Extend: none (transparent outside gradient), repeat (tile), reflect (mirror), "
            "pad (extend edge color). "
            "Filter: fast, good, best, nearest, bilinear.\n\n"
            "Other: image (path/data/location, x, y, width, height) — loads PNG files only; "
            "mask_surface (path/data/location, x, y) — uses current source color masked by "
            "a PNG surface's alpha channel; "
            "save, restore, push_group, pop_group_to_source, show_page, copy_page",
    },
};

# ========== SVG Create ==========

#! Request type for creating an SVG
public hashdecl CairoSvgCreateRequest {
    #! Surface width in points (1 point = 1/72 inch; US Letter = 612)
    float width;

    #! Surface height in points (1 point = 1/72 inch; US Letter = 792)
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
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

    #! SVG metadata as key-value pairs (currently contains width and height)
    hash<auto> metadata;

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
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

    #! Overwrite the input file if true
    *bool overwrite;
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
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

    #! Output width in points (1 point = 1/72 inch; default: use SVG intrinsic width)
    *float width;

    #! Output height in points (1 point = 1/72 inch; default: use SVG intrinsic height)
    *float height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
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

    #! Output width in points (1 point = 1/72 inch; default: use SVG intrinsic width)
    *float width;

    #! Output height in points (1 point = 1/72 inch; default: use SVG intrinsic height)
    *float height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
}

# ========== SVG To PDF ==========

#! Request type for converting SVG to PDF
public hashdecl CairoSvgToPdfRequest {
    #! Input file path
    *string input_path;

    #! Binary SVG data
    *binary data;

    #! Input location
    *string location;

    #! Output width in points (1 point = 1/72 inch; default: use SVG intrinsic width)
    *float width;

    #! Output height in points (1 point = 1/72 inch; default: use SVG intrinsic height)
    *float height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for SVG to PDF conversion
public hashdecl CairoSvgToPdfResponse {
    #! Output PDF data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
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

    #! Overwrite the input file if true
    *bool overwrite;
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
}

# ========== PostScript Create ==========

#! Request type for creating a PostScript document
public hashdecl CairoPostScriptCreateRequest {
    #! Page width in points (1 point = 1/72 inch; US Letter = 612)
    float width;

    #! Page height in points (1 point = 1/72 inch; US Letter = 792)
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
}

# ========== PDF Create ==========

#! Request type for creating a PDF document
public hashdecl CairoPdfCreateRequest {
    #! Page width in points (1 point = 1/72 inch; US Letter = 612)
    float width;

    #! Page height in points (1 point = 1/72 inch; US Letter = 792)
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

#! Response type for creating a PDF document
public hashdecl CairoPdfCreateResponse {
    #! Output PDF data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
}

# ========== Text Measure ==========

#! Request type for measuring text dimensions
public hashdecl CairoTextMeasureRequest {
    #! Text to measure
    string text;

    #! Font family name
    *string family;

    #! Font size in user-space units
    *float size;

    #! Font slant: "normal", "italic", or "oblique"
    *string slant;

    #! Font weight: "normal" or "bold"
    *string weight;
}

#! Response type for text measurement
public hashdecl CairoTextMeasureResponse {
    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;

    #! X bearing
    float x_bearing;

    #! Y bearing
    float y_bearing;

    #! Width of the text
    float width;

    #! Height of the text
    float height;

    #! X advance
    float x_advance;

    #! Y advance
    float y_advance;
}

# ========== Font Get Metrics ==========

#! Request type for getting font metrics
public hashdecl CairoFontGetMetricsRequest {
    #! Font family name
    *string family;

    #! Font size in user-space units
    *float size;

    #! Font slant: "normal", "italic", or "oblique"
    *string slant;

    #! Font weight: "normal" or "bold"
    *string weight;
}

#! Response type for font metrics
public hashdecl CairoFontGetMetricsResponse {
    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;

    #! Distance the font extends above the baseline
    float ascent;

    #! Distance the font extends below the baseline
    float descent;

    #! Recommended vertical distance between baselines
    float height;

    #! Maximum distance in X a glyph advances
    float max_x_advance;

    #! Maximum distance in Y a glyph advances
    float max_y_advance;
}

# ========== Image Resize ==========

#! Request type for resizing an image
public hashdecl CairoImageResizeRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! Target width in pixels
    int target_width;

    #! Target height in pixels
    int target_height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for image resize
public hashdecl CairoImageResizeResponse {
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
}

# ========== Image Crop ==========

#! Request type for cropping an image
public hashdecl CairoImageCropRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! X offset of the crop region
    int x;

    #! Y offset of the crop region
    int y;

    #! Width of the crop region in pixels
    int crop_width;

    #! Height of the crop region in pixels
    int crop_height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for image crop
public hashdecl CairoImageCropResponse {
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
}

# ========== Image Composite ==========

#! Request type for compositing images
public hashdecl CairoImageCompositeRequest {
    #! Base image file path
    *string base_input_path;

    #! Base image binary PNG data
    *binary base_data;

    #! Base image location
    *string base_location;

    #! Overlay image file path
    *string overlay_input_path;

    #! Overlay image binary PNG data
    *binary overlay_data;

    #! Overlay image location
    *string overlay_location;

    #! X position for overlay placement
    *float x;

    #! Y position for overlay placement
    *float y;

    #! Overlay alpha (0.0 = transparent, 1.0 = opaque)
    *float alpha;

    #! Optional overlay width (for scaling)
    *int overlay_width;

    #! Optional overlay height (for scaling)
    *int overlay_height;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for image composite
public hashdecl CairoImageCompositeResponse {
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

    #! True if the operation completed successfully
    bool success;

    #! Warnings encountered during processing
    *list<string> warnings;
}

# ========== HashDataType Request Classes ==========

#! SVG create request type
public class CairoSvgCreateRequestDataType inherits HashDataType {
    public {
        const Fields = {
            "width": {
                "type": FloatType,
                "display_name": "Width",
                "short_desc": "SVG width in points",
                "desc": "Width of the SVG surface in points (72 points = 1 inch)",
                "example_value": 612.0,
            },
            "height": {
                "type": FloatType,
                "display_name": "Height",
                "short_desc": "SVG height in points",
                "desc": "Height of the SVG surface in points (72 points = 1 inch)",
                "example_value": 792.0,
            },
        } + CairoDrawCommandsField + (CairoOutputFields - "overwrite");
    }

    constructor() {
        addQoreFields(Fields);
    }
}

#! SVG get info request type
public class CairoSvgGetInfoRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! SVG to PNG request type
public class CairoSvgToPngRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + {
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
        } + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! SVG to PS request type
public class CairoSvgToPsRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + {
            "width": {
                "type": FloatOrNothingType,
                "display_name": "Width",
                "short_desc": "Output width in points",
                "desc": "Output page width in points (72 points = 1 inch). Default: use SVG intrinsic width.",
            },
            "height": {
                "type": FloatOrNothingType,
                "display_name": "Height",
                "short_desc": "Output height in points",
                "desc": "Output page height in points (72 points = 1 inch). Default: use SVG intrinsic height.",
            },
        } + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! SVG to EPS request type
public class CairoSvgToEpsRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + {
            "width": {
                "type": FloatOrNothingType,
                "display_name": "Width",
                "short_desc": "Output width in points",
                "desc": "Output page width in points (72 points = 1 inch). Default: use SVG intrinsic width.",
            },
            "height": {
                "type": FloatOrNothingType,
                "display_name": "Height",
                "short_desc": "Output height in points",
                "desc": "Output page height in points (72 points = 1 inch). Default: use SVG intrinsic height.",
            },
        } + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! SVG to PDF request type
public class CairoSvgToPdfRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + {
            "width": {
                "type": FloatOrNothingType,
                "display_name": "Width",
                "short_desc": "Output width in points",
                "desc": "Output page width in points (1 point = 1/72 inch; US Letter = 612). "
                    "Default: use SVG intrinsic width.",
            },
            "height": {
                "type": FloatOrNothingType,
                "display_name": "Height",
                "short_desc": "Output height in points",
                "desc": "Output page height in points (1 point = 1/72 inch; US Letter = 792). "
                    "Default: use SVG intrinsic height.",
            },
        } + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image create request type
public class CairoImageCreateRequestDataType inherits HashDataType {
    public {
        const Fields = {
            "width": {
                "type": IntType,
                "display_name": "Width",
                "short_desc": "Image width in pixels",
                "desc": "Width of the image in pixels",
                "example_value": 800,
            },
            "height": {
                "type": IntType,
                "display_name": "Height",
                "short_desc": "Image height in pixels",
                "desc": "Height of the image in pixels",
                "example_value": 600,
            },
            "format": {
                "type": StringOrNothingType,
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
        } + CairoDrawCommandsField + (CairoOutputFields - "overwrite");
    }

    constructor() {
        addQoreFields(Fields);
    }
}

#! Image get info request type
public class CairoImageGetInfoRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image draw request type
public class CairoImageDrawRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + CairoDrawCommandsField + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! PostScript create request type
public class CairoPostScriptCreateRequestDataType inherits HashDataType {
    public {
        const Fields = {
            "width": {
                "type": FloatType,
                "display_name": "Width",
                "short_desc": "Page width in points",
                "desc": "Width of the PostScript page in points (72 points = 1 inch)",
                "example_value": 612.0,
            },
            "height": {
                "type": FloatType,
                "display_name": "Height",
                "short_desc": "Page height in points",
                "desc": "Height of the PostScript page in points (72 points = 1 inch)",
                "example_value": 792.0,
            },
            "eps": {
                "type": BoolOrNothingType,
                "display_name": "EPS Mode",
                "short_desc": "Enable EPS mode",
                "desc": "If True, create Encapsulated PostScript (EPS) output",
                "default_value": False,
            },
        } + CairoDrawCommandsField + (CairoOutputFields - "overwrite");
    }

    constructor() {
        addQoreFields(Fields);
    }
}

#! PDF create request type
public class CairoPdfCreateRequestDataType inherits HashDataType {
    public {
        const Fields = {
            "width": {
                "type": FloatType,
                "display_name": "Width",
                "short_desc": "Page width in points",
                "desc": "Width of the PDF page in points (72 points = 1 inch)",
                "example_value": 612.0,
            },
            "height": {
                "type": FloatType,
                "display_name": "Height",
                "short_desc": "Page height in points",
                "desc": "Height of the PDF page in points (72 points = 1 inch)",
                "example_value": 792.0,
            },
        } + CairoDrawCommandsField + (CairoOutputFields - "overwrite");
    }

    constructor() {
        addQoreFields(Fields);
    }
}

#! Text measure request type
public class CairoTextMeasureRequestDataType inherits HashDataType {
    public {
        const Fields = {
            "text": {
                "type": StringType,
                "display_name": "Text",
                "short_desc": "Text to measure",
                "desc": "The text string to measure dimensions for",
                "example_value": "Hello, World!",
            },
        } + CairoFontFields;
    }

    constructor() {
        addQoreFields(Fields);
    }
}

#! Font get metrics request type
public class CairoFontGetMetricsRequestDataType inherits HashDataType {
    public {
        const Fields = CairoFontFields;
    }

    constructor() {
        addQoreFields(Fields);
    }
}

#! Image resize request type
public class CairoImageResizeRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + {
            "target_width": {
                "type": IntType,
                "display_name": "Target Width",
                "short_desc": "Target width in pixels",
                "desc": "Target image width in pixels",
                "example_value": 800,
            },
            "target_height": {
                "type": IntType,
                "display_name": "Target Height",
                "short_desc": "Target height in pixels",
                "desc": "Target image height in pixels",
                "example_value": 600,
            },
        } + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image crop request type
public class CairoImageCropRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + {
            "x": {
                "type": IntType,
                "display_name": "X Offset",
                "short_desc": "X offset of crop region",
                "desc": "X offset of the top-left corner of the crop region in pixels",
                "example_value": 0,
            },
            "y": {
                "type": IntType,
                "display_name": "Y Offset",
                "short_desc": "Y offset of crop region",
                "desc": "Y offset of the top-left corner of the crop region in pixels",
                "example_value": 0,
            },
            "crop_width": {
                "type": IntType,
                "display_name": "Crop Width",
                "short_desc": "Width of crop region",
                "desc": "Width of the crop region in pixels",
                "example_value": 100,
            },
            "crop_height": {
                "type": IntType,
                "display_name": "Crop Height",
                "short_desc": "Height of crop region",
                "desc": "Height of the crop region in pixels",
                "example_value": 100,
            },
        } + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image composite request type
public class CairoImageCompositeRequestDataType inherits HashDataType {
    public {
        const Fields = {
            "base_input_path": {
                "type": StringOrNothingType,
                "display_name": "Base Image Path",
                "short_desc": "Path to base image file",
                "desc": "File path to the base image. One of 'base_input_path', 'base_data', "
                    "or 'base_location' must be provided.",
            },
            "base_data": {
                "type": BinaryOrNothingType,
                "display_name": "Base Image Data",
                "short_desc": "Binary base image data",
                "desc": "Binary PNG data of the base image.",
            },
            "base_location": {
                "type": StringOrNothingType,
                "display_name": "Base Image Location",
                "short_desc": "Location of base image",
                "desc": "A file location string for the base image.",
            },
            "overlay_input_path": {
                "type": StringOrNothingType,
                "display_name": "Overlay Image Path",
                "short_desc": "Path to overlay image file",
                "desc": "File path to the overlay image. One of 'overlay_input_path', 'overlay_data', "
                    "or 'overlay_location' must be provided.",
            },
            "overlay_data": {
                "type": BinaryOrNothingType,
                "display_name": "Overlay Image Data",
                "short_desc": "Binary overlay image data",
                "desc": "Binary PNG data of the overlay image.",
            },
            "overlay_location": {
                "type": StringOrNothingType,
                "display_name": "Overlay Image Location",
                "short_desc": "Location of overlay image",
                "desc": "A file location string for the overlay image.",
            },
            "x": {
                "type": FloatOrNothingType,
                "display_name": "X Position",
                "short_desc": "Overlay X position",
                "desc": "X position for overlay placement. Default: 0.0",
                "default_value": 0.0,
            },
            "y": {
                "type": FloatOrNothingType,
                "display_name": "Y Position",
                "short_desc": "Overlay Y position",
                "desc": "Y position for overlay placement. Default: 0.0",
                "default_value": 0.0,
            },
            "alpha": {
                "type": FloatOrNothingType,
                "display_name": "Alpha",
                "short_desc": "Overlay transparency",
                "desc": "Overlay alpha value (0.0 = transparent, 1.0 = opaque). Default: 1.0",
                "default_value": 1.0,
            },
            "overlay_width": {
                "type": IntOrNothingType,
                "display_name": "Overlay Width",
                "short_desc": "Scale overlay to this width",
                "desc": "Optional width to scale the overlay to (in pixels). "
                    "Both overlay_width and overlay_height must be specified for scaling.",
            },
            "overlay_height": {
                "type": IntOrNothingType,
                "display_name": "Overlay Height",
                "short_desc": "Scale overlay to this height",
                "desc": "Optional height to scale the overlay to (in pixels). "
                    "Both overlay_width and overlay_height must be specified for scaling.",
            },
        } + (CairoOutputFields - "overwrite");
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((
            ("base_input_path", "base_data", "base_location"),
            ("overlay_input_path", "overlay_data", "overlay_location"),
        ));
    }
}
}
