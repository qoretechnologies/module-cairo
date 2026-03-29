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
        "desc": "File path to read input from. One of `input_path`, `data`, or `location` "
            "must be provided.",
        "example_value": "/path/to/input.svg",
    },
    "data": {
        "type": BinaryOrNothingType,
        "display_name": "Input Data",
        "short_desc": "Binary input data",
        "desc": "Binary data of the input. One of `input_path`, `data`, or `location` "
            "must be provided.",
    },
    "location": {
        "type": StringOrNothingType,
        "display_name": "Input Location",
        "short_desc": "Location of input file",
        "desc": "A file location string as supported by the "
            "[FileLocationHandler](https://docs.qore.org/current/modules/FileLocationHandler/html/index.html) "
            "module (e.g. `file:///path/to/input.png`, `https://example.com/image.png`). "
            "One of `input_path`, `data`, or `location` must be provided.",
        "example_value": "file:///path/to/input.png",
    },
};

#! Common output fields for actions that produce output data
const CairoOutputFields = {
    "output_path": {
        "type": StringOrNothingType,
        "display_name": "Output File Path",
        "short_desc": "Path to write the output to",
        "desc": "File path to write the processed output to. If neither `output_path` nor "
            "`output_location` is provided, the data is returned in the response only.",
        "example_value": "/path/to/output.png",
    },
    "output_location": {
        "type": StringOrNothingType,
        "display_name": "Output Location",
        "short_desc": "Location to write the output to",
        "desc": "A file location string as supported by the "
            "[FileLocationHandler](https://docs.qore.org/current/modules/FileLocationHandler/html/index.html) "
            "module (e.g. `file:///path/to/output.png`, `sftp://host/path/output.png`). "
            "If neither `output_path` nor `output_location` is provided, the data is returned "
            "in the response only.",
        "example_value": "file:///path/to/output.png",
    },
    "return_data": {
        "type": BoolOrNothingType,
        "display_name": "Return Data",
        "short_desc": "Whether to include data in the response",
        "desc": "Whether to include binary data in the response hash. Defaults to `True` when "
            "no output path or location is specified, `False` when an output destination is provided.",
    },
    "overwrite": {
        "type": BoolOrNothingType,
        "display_name": "Overwrite",
        "short_desc": "Overwrite the input file",
        "desc": "If `true` and `output_path` is not specified, the input file will be overwritten "
            "(only applicable when `input_path` is used).",
    },
};

#! Common output response fields
const CairoOutputResponseFields = {
    "data": {
        "type": BinaryOrNothingType,
        "display_name": "Output Data",
        "short_desc": "The output binary data",
        "desc": "Binary output data. Only included when `return_data` is `true` "
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
        "desc": "`True` if the operation completed successfully",
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
        "desc": "Font family name (e.g., `sans-serif`, `Helvetica`). Default: `sans-serif`",
        "default_value": "sans-serif",
        "example_value": "sans-serif",
    },
    "size": {
        "type": FloatOrNothingType,
        "display_name": "Font Size",
        "short_desc": "Font size",
        "desc": "Font size in user-space units. Default: `12.0`",
        "default_value": 12.0,
        "example_value": 24.0,
    },
    "slant": {
        "type": StringOrNothingType,
        "display_name": "Font Slant",
        "short_desc": "Font slant style",
        "desc": "Font slant style. Default: `normal`",
        "default_value": "normal",
        "allowed_values": (
            <AllowedValueInfo>{"value": "normal", "display_name": "Normal", "desc": "Normal (upright) style"},
            <AllowedValueInfo>{"value": "italic", "display_name": "Italic", "desc": "Italic style"},
            <AllowedValueInfo>{"value": "oblique", "display_name": "Oblique", "desc": "Oblique style"},
        ),
    },
    "weight": {
        "type": StringOrNothingType,
        "display_name": "Font Weight",
        "short_desc": "Font weight",
        "desc": "Font weight style. Default: `normal`",
        "default_value": "normal",
        "allowed_values": (
            <AllowedValueInfo>{"value": "normal", "display_name": "Normal", "desc": "Normal weight"},
            <AllowedValueInfo>{"value": "bold", "display_name": "Bold", "desc": "Bold weight"},
        ),
    },
};

#! Draw commands field
const CairoDrawCommandsField = {
    "commands": {
        "type": new Type("list<hash<auto>>"),
        "display_name": "Draw Commands",
        "short_desc": "List of draw commands",
        "desc": "List of draw command hashes. Each command has an `op` key specifying the "
            "operation and operation-specific parameters.\n\n"
            "**Coordinate system**: dimensions are in points (1 point = 1/72 inch). "
            "US Letter = 612 x 792 points; A4 = 595 x 842 points.\n\n"
            "**Color and Style**:\n"
            "- `set_source_rgb` (r, g, b) — color values are floats 0.0-1.0 "
            "(e.g. r=1.0 is full red)\n"
            "- `set_source_rgba` (r, g, b, a)\n"
            "- `set_line_width` (width)\n"
            "- `set_line_cap` (cap: `butt`, `round`, `square`)\n"
            "- `set_line_join` (join: `miter`, `round`, `bevel`)\n"
            "- `set_dash` (dashes, offset), `set_miter_limit` (limit), "
            "`set_tolerance` (tolerance)\n"
            "- `set_fill_rule` (rule: `winding`, `even-odd`)\n"
            "- `set_operator` (op_name)\n"
            "- `set_antialias` (aa: `default`, `none`, `gray`, `subpixel`)\n\n"
            "**Paths**:\n"
            "- `move_to` (x, y), `line_to` (x, y)\n"
            "- `curve_to` (x1, y1, x2, y2, x3, y3)\n"
            "- `rel_move_to` (dx, dy), `rel_line_to` (dx, dy)\n"
            "- `rel_curve_to` (dx1, dy1, dx2, dy2, dx3, dy3)\n"
            "- `arc` (x, y, radius, angle1, angle2), `arc_negative` (...) — angles in "
            "radians (0 = 3 o'clock, pi/2 = 6 o'clock)\n"
            "- `rectangle` (x, y, width, height)\n"
            "- `close_path`, `new_path`, `new_sub_path`\n\n"
            "**Drawing**:\n"
            "- `stroke`, `fill`, `paint` (alpha)\n"
            "- `stroke_preserve`, `fill_preserve`\n"
            "- `clip`, `clip_preserve`, `reset_clip`\n"
            "- `text_path` (text)\n\n"
            "**Text**:\n"
            "- `text` (text, x, y, family, size, slant, weight)\n"
            "- `set_font` (family, size, slant, weight), `set_font_size` (size)\n\n"
            "**Transforms**:\n"
            "- `translate` (x, y), `rotate` (angle — radians), `scale` (x, y)\n"
            "- `identity_matrix`\n"
            "- `set_matrix` (xx, yx, xy, yy, x0, y0), `transform` (...)\n\n"
            "**Gradients**:\n"
            "- `linear_gradient` (x0, y0, x1, y1, stops, extend, filter)\n"
            "- `radial_gradient` (cx0, cy0, r0, cx1, cy1, r1, stops, extend, filter)\n"
            "- Stops: list of hashes with `offset` (0.0-1.0), `r`, `g`, `b`, and "
            "optional `a`\n"
            "- Extend: `none` (transparent), `repeat` (tile), `reflect` (mirror), "
            "`pad` (extend edge color)\n"
            "- Filter: `fast`, `good`, `best`, `nearest`, `bilinear`\n\n"
            "**Other**:\n"
            "- `image` (path/data/location, x, y, width, height) — PNG files only\n"
            "- `mask_surface` (path/data/location, x, y) — uses current source color "
            "masked by a PNG surface's alpha channel\n"
            "- `save`, `restore`, `push_group`, `pop_group_to_source`, `show_page`, "
            "`copy_page`",
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

# ========== SVG Center ==========

#! Request type for centering SVG content on a square canvas
public hashdecl CairoSvgCenterRequest {
    #! Input file path
    *string input_path;

    #! Binary SVG data
    *binary data;

    #! Input location
    *string location;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true (default: True when no explicit output is given)
    *bool overwrite;
}

#! Response type for SVG center operation
public hashdecl CairoSvgCenterResponse {
    #! Output SVG data
    *binary data;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Output size in bytes
    int size;

    #! Original SVG width before centering
    float original_width;

    #! Original SVG height before centering
    float original_height;

    #! Square canvas side length
    float canvas_size;

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

#! SVG center request type
public class CairoSvgCenterRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + CairoOutputFields;
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
                    <AllowedValueInfo>{"value": "ARGB32", "display_name": "ARGB32", "desc": "32-bit ARGB (default)"},
                    <AllowedValueInfo>{"value": "RGB24", "display_name": "RGB24", "desc": "32-bit RGB (no alpha)"},
                    <AllowedValueInfo>{"value": "A8", "display_name": "A8", "desc": "8-bit alpha mask"},
                    <AllowedValueInfo>{"value": "A1", "display_name": "A1", "desc": "1-bit alpha mask"},
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
                "desc": "If `True`, create Encapsulated PostScript (EPS) output",
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
                "desc": "File path to the base image. One of `base_input_path`, `base_data`, "
                    "or `base_location` must be provided.",
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
                "desc": "File path to the overlay image. One of `overlay_input_path`, `overlay_data`, "
                    "or `overlay_location` must be provided.",
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
                "desc": "X position for overlay placement. Default: `0.0`",
                "default_value": 0.0,
                "example_value": 10.0,
            },
            "y": {
                "type": FloatOrNothingType,
                "display_name": "Y Position",
                "short_desc": "Overlay Y position",
                "desc": "Y position for overlay placement. Default: `0.0`",
                "default_value": 0.0,
                "example_value": 10.0,
            },
            "alpha": {
                "type": FloatOrNothingType,
                "display_name": "Alpha",
                "short_desc": "Overlay transparency",
                "desc": "Overlay alpha value (`0.0` = transparent, `1.0` = opaque). Default: `1.0`",
                "default_value": 1.0,
                "example_value": 0.8,
            },
            "overlay_width": {
                "type": IntOrNothingType,
                "display_name": "Overlay Width",
                "short_desc": "Scale overlay to this width",
                "desc": "Optional width to scale the overlay to (in pixels). "
                    "Both `overlay_width` and `overlay_height` must be specified for scaling.",
                "example_value": 100,
            },
            "overlay_height": {
                "type": IntOrNothingType,
                "display_name": "Overlay Height",
                "short_desc": "Scale overlay to this height",
                "desc": "Optional height to scale the overlay to (in pixels). "
                    "Both `overlay_width` and `overlay_height` must be specified for scaling.",
                "example_value": 100,
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

# ========== Image To PDF ==========

#! Request type for converting a PNG image to PDF
public hashdecl CairoImageToPdfRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for image to PDF conversion
public hashdecl CairoImageToPdfResponse {
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

# ========== Image To SVG ==========

#! Request type for converting a PNG image to SVG
public hashdecl CairoImageToSvgRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for image to SVG conversion
public hashdecl CairoImageToSvgResponse {
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

# ========== Image To PS ==========

#! Request type for converting a PNG image to PostScript
public hashdecl CairoImageToPsRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for image to PostScript conversion
public hashdecl CairoImageToPsResponse {
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

# ========== Image To EPS ==========

#! Request type for converting a PNG image to EPS
public hashdecl CairoImageToEpsRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for image to EPS conversion
public hashdecl CairoImageToEpsResponse {
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

# ========== Image Rotate ==========

#! Request type for rotating a PNG image
public hashdecl CairoImageRotateRequest {
    #! Input file path
    *string input_path;

    #! Binary PNG data
    *binary data;

    #! Input location
    *string location;

    #! Rotation angle in degrees (positive = clockwise)
    float angle;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;

    #! Overwrite the input file if true
    *bool overwrite;
}

#! Response type for image rotation
public hashdecl CairoImageRotateResponse {
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

# ========== Text Render ==========

#! Request type for rendering text to a PNG image
public hashdecl CairoTextRenderRequest {
    #! Text to render
    string text;

    #! Font family name
    *string family;

    #! Font size in user-space units
    *float size;

    #! Font slant: "normal", "italic", or "oblique"
    *string slant;

    #! Font weight: "normal" or "bold"
    *string weight;

    #! Text color red component (0.0-1.0)
    *float r;

    #! Text color green component (0.0-1.0)
    *float g;

    #! Text color blue component (0.0-1.0)
    *float b;

    #! Text color alpha component (0.0-1.0)
    *float a;

    #! Background color red component (0.0-1.0)
    *float bg_r;

    #! Background color green component (0.0-1.0)
    *float bg_g;

    #! Background color blue component (0.0-1.0)
    *float bg_b;

    #! Background color alpha (0.0 = transparent, 1.0 = opaque)
    *float bg_a;

    #! Padding in pixels around the text
    *int padding;

    #! Output file path
    *string output_path;

    #! Output location
    *string output_location;

    #! Return data in response
    *bool return_data;
}

#! Response type for text rendering
public hashdecl CairoTextRenderResponse {
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

# ========== New HashDataType Request Classes ==========

#! Image to PDF request type
public class CairoImageToPdfRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image to SVG request type
public class CairoImageToSvgRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image to PS request type
public class CairoImageToPsRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image to EPS request type
public class CairoImageToEpsRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Image rotate request type
public class CairoImageRotateRequestDataType inherits HashDataType {
    public {
        const Fields = CairoInputFields + {
            "angle": {
                "type": FloatType,
                "display_name": "Angle",
                "short_desc": "Rotation angle in degrees",
                "desc": "Rotation angle in degrees (positive = clockwise). "
                    "Common values: `90`, `180`, `270`.",
                "example_value": 90.0,
            },
        } + CairoOutputFields;
    }

    constructor() {
        addQoreFields(Fields);
        setRequiredGroups((("input_path", "data", "location"),));
    }
}

#! Text render request type
public class CairoTextRenderRequestDataType inherits HashDataType {
    public {
        const Fields = {
            "text": {
                "type": StringType,
                "display_name": "Text",
                "short_desc": "Text to render",
                "desc": "The text string to render to a PNG image",
                "example_value": "Hello, World!",
            },
        } + CairoFontFields + {
            "r": {
                "type": FloatOrNothingType,
                "display_name": "Text Red",
                "short_desc": "Text color red component",
                "desc": "Text color red component (`0.0`-`1.0`). Default: `0.0` (black)",
                "default_value": 0.0,
                "example_value": 0.0,
            },
            "g": {
                "type": FloatOrNothingType,
                "display_name": "Text Green",
                "short_desc": "Text color green component",
                "desc": "Text color green component (`0.0`-`1.0`). Default: `0.0`",
                "default_value": 0.0,
                "example_value": 0.0,
            },
            "b": {
                "type": FloatOrNothingType,
                "display_name": "Text Blue",
                "short_desc": "Text color blue component",
                "desc": "Text color blue component (`0.0`-`1.0`). Default: `0.0`",
                "default_value": 0.0,
                "example_value": 0.0,
            },
            "a": {
                "type": FloatOrNothingType,
                "display_name": "Text Alpha",
                "short_desc": "Text color alpha",
                "desc": "Text color alpha (`0.0` = transparent, `1.0` = opaque). Default: `1.0`",
                "default_value": 1.0,
                "example_value": 1.0,
            },
            "bg_r": {
                "type": FloatOrNothingType,
                "display_name": "Background Red",
                "short_desc": "Background color red component",
                "desc": "Background color red component (`0.0`-`1.0`). Default: `1.0` (white)",
                "default_value": 1.0,
                "example_value": 1.0,
            },
            "bg_g": {
                "type": FloatOrNothingType,
                "display_name": "Background Green",
                "short_desc": "Background color green component",
                "desc": "Background color green component (`0.0`-`1.0`). Default: `1.0`",
                "default_value": 1.0,
                "example_value": 1.0,
            },
            "bg_b": {
                "type": FloatOrNothingType,
                "display_name": "Background Blue",
                "short_desc": "Background color blue component",
                "desc": "Background color blue component (`0.0`-`1.0`). Default: `1.0`",
                "default_value": 1.0,
                "example_value": 1.0,
            },
            "bg_a": {
                "type": FloatOrNothingType,
                "display_name": "Background Alpha",
                "short_desc": "Background color alpha",
                "desc": "Background color alpha (`0.0` = transparent, `1.0` = opaque). "
                    "Default: `0.0` (transparent)",
                "default_value": 0.0,
                "example_value": 0.0,
            },
            "padding": {
                "type": IntOrNothingType,
                "display_name": "Padding",
                "short_desc": "Padding around text in pixels",
                "desc": "Padding in pixels around the rendered text. Default: `0`",
                "default_value": 0,
                "example_value": 4,
            },
        } + (CairoOutputFields - "overwrite");
    }

    constructor() {
        addQoreFields(Fields);
    }
}
}
