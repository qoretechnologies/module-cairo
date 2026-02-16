# -*- mode: qore; indent-tabs-mode: nil -*-
#! Qore CairoActionBase class definition

/** CairoActionBase.qc Copyright (C) 2026 Qore Technologies, s.r.o.

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
#! Base class for Cairo action providers
/** Provides common functionality for loading input data, writing output, and
    interpreting draw commands.
*/
public class CairoActionBase inherits AbstractDataProvider {
    #! Loads binary data from a request hash (input_path, data, or location)
    static binary loadBinaryData(hash<auto> req) {
        if (req.data) {
            return req.data;
        }
        if (req.location) {
            return FileLocationHandler::getBinaryFileFromLocation(req.location);
        }
        if (req.input_path) {
            return ReadOnlyFile::readBinaryFile(req.input_path);
        }
        throw "CAIRO-ERROR", "one of 'input_path', 'data', or 'location' must be provided";
    }

    #! Returns the output response hash for data-producing actions
    /** Handles writing to output_path, output_location, and returning data.

        @param out_data the output binary data
        @param req the original request hash
        @return response hash with output_path, output_location, data, and size
    */
    static hash<auto> makeOutputResponse(binary out_data, hash<auto> req) {
        hash<auto> response = {};

        # Write to output_path if specified
        if (req.output_path) {
            CairoActionBase::writeBinaryFile(req.output_path, out_data);
            response."output_path" = req.output_path;
        }

        # Write to output_location if specified
        if (req.output_location) {
            FileLocationHandler::writeFileToLocation(req.output_location, out_data);
            response."output_location" = req.output_location;
        }

        # Determine if we should return data in the response
        bool has_output = exists req.output_path || exists req.output_location;
        bool do_return_data = exists req.return_data ? req.return_data : !has_output;
        if (do_return_data) {
            response."data" = out_data;
        }

        response."size" = out_data.size();
        return response;
    }

    #! Executes a list of draw commands on a CairoContext
    /** @param ctx the Cairo drawing context
        @param commands list of draw command hashes, each with an "op" key
    */
    static executeDrawCommands(CairoContext ctx, list<hash<auto>> commands) {
        foreach hash<auto> cmd in (commands) {
            if (!cmd.op) {
                throw "CAIRO-ERROR", "draw command missing 'op' key";
            }
            string op = cmd.op;
            switch (op) {
                case "set_source_rgb": {
                    ctx.setSourceRgb(float(cmd.r), float(cmd.g), float(cmd.b));
                    break;
                }
                case "set_source_rgba": {
                    ctx.setSourceRgba(float(cmd.r), float(cmd.g), float(cmd.b), float(cmd.a));
                    break;
                }
                case "set_line_width": {
                    ctx.setLineWidth(float(cmd.width));
                    break;
                }
                case "set_font": {
                    ctx.selectFontFace(string(cmd.family),
                        cmd.slant ?? "normal", cmd.weight ?? "normal");
                    ctx.setFontSize(float(cmd.size));
                    break;
                }
                case "move_to": {
                    ctx.moveTo(float(cmd.x), float(cmd.y));
                    break;
                }
                case "line_to": {
                    ctx.lineTo(float(cmd.x), float(cmd.y));
                    break;
                }
                case "curve_to": {
                    ctx.curveTo(float(cmd.x1), float(cmd.y1),
                        float(cmd.x2), float(cmd.y2),
                        float(cmd.x3), float(cmd.y3));
                    break;
                }
                case "arc": {
                    ctx.arc(float(cmd.x), float(cmd.y), float(cmd.radius),
                        float(cmd.angle1), float(cmd.angle2));
                    break;
                }
                case "rectangle": {
                    ctx.rectangle(float(cmd.x), float(cmd.y),
                        float(cmd.width), float(cmd.height));
                    break;
                }
                case "close_path": {
                    ctx.closePath();
                    break;
                }
                case "stroke": {
                    ctx.stroke();
                    break;
                }
                case "fill": {
                    ctx.fill();
                    break;
                }
                case "paint": {
                    if (exists cmd.alpha) {
                        ctx.paintWithAlpha(float(cmd.alpha));
                    } else {
                        ctx.paint();
                    }
                    break;
                }
                case "text": {
                    ctx.save();
                    string family = cmd.family ?? "sans-serif";
                    string slant = cmd.slant ?? "normal";
                    string weight = cmd.weight ?? "normal";
                    ctx.selectFontFace(family, slant, weight);
                    if (exists cmd.size) {
                        ctx.setFontSize(float(cmd.size));
                    }
                    ctx.moveTo(float(cmd.x), float(cmd.y));
                    ctx.showText(string(cmd.text));
                    ctx.restore();
                    break;
                }
                case "save": {
                    ctx.save();
                    break;
                }
                case "restore": {
                    ctx.restore();
                    break;
                }
                case "translate": {
                    ctx.translate(float(cmd.x), float(cmd.y));
                    break;
                }
                case "rotate": {
                    ctx.rotate(float(cmd.angle));
                    break;
                }
                case "scale": {
                    ctx.scale(float(cmd.x), float(cmd.y));
                    break;
                }
                case "set_dash": {
                    list<float> dashes = cast<list<float>>(cmd.dashes);
                    float offset = exists cmd.offset ? float(cmd.offset) : 0.0;
                    ctx.setDash(dashes, offset);
                    break;
                }
                case "set_line_cap": {
                    ctx.setLineCap(string(cmd.cap));
                    break;
                }
                case "set_line_join": {
                    ctx.setLineJoin(string(cmd.join));
                    break;
                }
                case "set_fill_rule": {
                    ctx.setFillRule(string(cmd.rule));
                    break;
                }
                case "set_operator": {
                    ctx.setOperator(string(cmd.op_name));
                    break;
                }
                case "set_antialias": {
                    ctx.setAntialias(string(cmd.aa));
                    break;
                }
                case "linear_gradient": {
                    CairoPattern pat = CairoPattern::createLinear(
                        float(cmd.x0), float(cmd.y0),
                        float(cmd.x1), float(cmd.y1));
                    if (cmd.stops) {
                        foreach hash<auto> stop in (cmd.stops) {
                            if (exists stop.a) {
                                pat.addColorStopRgba(float(stop.offset),
                                    float(stop.r), float(stop.g), float(stop.b),
                                    float(stop.a));
                            } else {
                                pat.addColorStopRgb(float(stop.offset),
                                    float(stop.r), float(stop.g), float(stop.b));
                            }
                        }
                    }
                    ctx.setSource(pat);
                    break;
                }
                case "radial_gradient": {
                    CairoPattern pat = CairoPattern::createRadial(
                        float(cmd.cx0), float(cmd.cy0), float(cmd.r0),
                        float(cmd.cx1), float(cmd.cy1), float(cmd.r1));
                    if (cmd.stops) {
                        foreach hash<auto> stop in (cmd.stops) {
                            if (exists stop.a) {
                                pat.addColorStopRgba(float(stop.offset),
                                    float(stop.r), float(stop.g), float(stop.b),
                                    float(stop.a));
                            } else {
                                pat.addColorStopRgb(float(stop.offset),
                                    float(stop.r), float(stop.g), float(stop.b));
                            }
                        }
                    }
                    ctx.setSource(pat);
                    break;
                }
                case "image": {
                    CairoSurface img;
                    if (cmd.path) {
                        img = CairoSurface::createImageFromPng(string(cmd.path));
                    } else if (cmd.data) {
                        img = CairoSurface::createImageFromPngData(binary(cmd.data));
                    } else {
                        throw "CAIRO-ERROR", "image command requires 'path' or 'data'";
                    }
                    ctx.save();
                    float x = exists cmd.x ? float(cmd.x) : 0.0;
                    float y = exists cmd.y ? float(cmd.y) : 0.0;
                    ctx.translate(x, y);
                    if (exists cmd.width && exists cmd.height) {
                        float sw = float(cmd.width) / float(img.getWidth());
                        float sh = float(cmd.height) / float(img.getHeight());
                        ctx.scale(sw, sh);
                    }
                    ctx.setSourceSurface(img, 0.0, 0.0);
                    ctx.paint();
                    ctx.restore();
                    break;
                }
                case "show_page": {
                    ctx.showPage();
                    break;
                }
                case "clip": {
                    ctx.clip();
                    break;
                }
                case "new_path": {
                    ctx.newPath();
                    break;
                }
                case "new_sub_path": {
                    ctx.newSubPath();
                    break;
                }
                case "stroke_preserve": {
                    ctx.strokePreserve();
                    break;
                }
                case "fill_preserve": {
                    ctx.fillPreserve();
                    break;
                }
                case "clip_preserve": {
                    ctx.clipPreserve();
                    break;
                }
                case "text_path": {
                    ctx.textPath(string(cmd.text));
                    break;
                }
                case "identity_matrix": {
                    ctx.identityMatrix();
                    break;
                }
                default: {
                    throw "CAIRO-ERROR", sprintf("unknown draw command op: %y", op);
                }
            }
        }
    }

    #! Writes binary data to a file
    static writeBinaryFile(string path, binary data) {
        File f();
        f.open2(path, O_CREAT | O_WRONLY | O_TRUNC);
        f.write(data);
    }
}
}
