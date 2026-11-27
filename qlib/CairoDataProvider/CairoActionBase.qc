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
    /**
        @throw PERMISSION-DENIED the calling code (also the code that a host-created provider was lent to) is restricted
        from the \c FILESYSTEM functional domain, or from a functional domain of the handler of a location; see
        checkCallerPaths()
    */
    static binary loadBinaryData(hash<auto> req) {
        # the path and location are the caller's input (also when this public method is called directly)
        CairoActionBase::checkCallerPaths(req, ("input_path",), ("location",));
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

    #! Determines if the request uses a file path input
    static bool hasFilePathInput(hash<auto> req) {
        return exists req.input_path && req.input_path.val();
    }

    #! Returns the output response hash for data-producing actions
    /** Handles writing to output_path, output_location, overwrite, and returning data.

        @param out_data the output binary data
        @param req the original request hash
        @return response hash with output_path, output_location, data, and size

        @throw PERMISSION-DENIED the calling code (also the code that a host-created provider was lent to) is restricted
        from the \c FILESYSTEM functional domain, or from a functional domain of the handler of a location; see
        checkCallerPaths()
    */
    static hash<auto> makeOutputResponse(binary out_data, hash<auto> req) {
        # the paths and location are the caller's input (also when this public method is called directly); with
        # overwrite, the input file is written
        CairoActionBase::checkCallerPaths(req, req.overwrite ? ("output_path", "input_path") : ("output_path",),
            ("output_location",));
        hash<auto> response = {};

        # Write to output_path if specified
        if (req.output_path) {
            CairoActionBase::writeBinaryFile(req.output_path, out_data);
            response."output_path" = req.output_path;
        } else if (req.overwrite && CairoActionBase::hasFilePathInput(req)) {
            # Overwrite input file with atomic temp + rename
            string output_path = req.input_path;
            string temp_path = output_path + ".tmp";
            on_error {
                unlink(temp_path);
            }
            CairoActionBase::writeBinaryFile(temp_path, out_data);
            rename(temp_path, output_path);
            response."output_path" = output_path;
        }

        # Write to output_location if specified
        if (req.output_location) {
            FileLocationHandler::writeFileToLocation(req.output_location, out_data);
            response."output_location" = req.output_location;
        }

        # Determine if we should return data in the response
        bool has_output = exists req.output_path || exists req.output_location
            || (req.overwrite && CairoActionBase::hasFilePathInput(req));
        bool do_return_data = exists req.return_data ? req.return_data : !has_output;
        if (do_return_data) {
            response."data" = out_data;
        }

        response."size" = out_data.size();
        response."success" = True;
        return response;
    }

    #! Executes a list of draw commands on a CairoContext
    /** @param ctx the Cairo drawing context
        @param commands list of draw command hashes, each with an "op" key

        @throw PERMISSION-DENIED the calling code (also the code that a host-created provider was lent to) is restricted
        from the \c FILESYSTEM functional domain, or from a functional domain of the handler of a location; see
        checkCallerPaths()
    */
    static executeDrawCommands(CairoContext ctx, list<hash<auto>> commands) {
        # the paths and locations of the commands are the caller's input (also when this public method is called
        # directly): refused before any command is executed
        CairoActionBase::checkCommandPaths(commands);
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
                case "rel_move_to": {
                    ctx.relMoveTo(float(cmd.dx), float(cmd.dy));
                    break;
                }
                case "rel_line_to": {
                    ctx.relLineTo(float(cmd.dx), float(cmd.dy));
                    break;
                }
                case "rel_curve_to": {
                    ctx.relCurveTo(float(cmd.dx1), float(cmd.dy1),
                        float(cmd.dx2), float(cmd.dy2),
                        float(cmd.dx3), float(cmd.dy3));
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
                case "set_miter_limit": {
                    ctx.setMiterLimit(float(cmd.limit));
                    break;
                }
                case "set_tolerance": {
                    ctx.setTolerance(float(cmd.tolerance));
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
                    CairoActionBase::configureGradientPattern(pat, cmd);
                    ctx.setSource(pat);
                    break;
                }
                case "radial_gradient": {
                    CairoPattern pat = CairoPattern::createRadial(
                        float(cmd.cx0), float(cmd.cy0), float(cmd.r0),
                        float(cmd.cx1), float(cmd.cy1), float(cmd.r1));
                    CairoActionBase::configureGradientPattern(pat, cmd);
                    ctx.setSource(pat);
                    break;
                }
                case "image": {
                    CairoSurface img;
                    if (cmd.path) {
                        img = CairoSurface::createImageFromPng(string(cmd.path));
                    } else if (cmd.data) {
                        img = CairoSurface::createImageFromPngData(binary(cmd.data));
                    } else if (cmd.location) {
                        binary img_data = FileLocationHandler::getBinaryFileFromLocation(
                            string(cmd.location));
                        img = CairoSurface::createImageFromPngData(img_data);
                    } else {
                        throw "CAIRO-ERROR", "image command requires 'path', 'data', or 'location'";
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
                case "reset_clip": {
                    ctx.resetClip();
                    break;
                }
                case "push_group": {
                    ctx.pushGroup();
                    break;
                }
                case "pop_group_to_source": {
                    ctx.popGroupToSource();
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
                case "arc_negative": {
                    ctx.arcNegative(float(cmd.x), float(cmd.y), float(cmd.radius),
                        float(cmd.angle1), float(cmd.angle2));
                    break;
                }
                case "copy_page": {
                    ctx.copyPage();
                    break;
                }
                case "mask_surface": {
                    CairoSurface mask_img;
                    if (cmd.path) {
                        mask_img = CairoSurface::createImageFromPng(string(cmd.path));
                    } else if (cmd.data) {
                        mask_img = CairoSurface::createImageFromPngData(binary(cmd.data));
                    } else if (cmd.location) {
                        binary mask_data = FileLocationHandler::getBinaryFileFromLocation(
                            string(cmd.location));
                        mask_img = CairoSurface::createImageFromPngData(mask_data);
                    } else {
                        throw "CAIRO-ERROR",
                            "mask_surface command requires 'path', 'data', or 'location'";
                    }
                    float x = exists cmd.x ? float(cmd.x) : 0.0;
                    float y = exists cmd.y ? float(cmd.y) : 0.0;
                    ctx.maskSurface(mask_img, x, y);
                    break;
                }
                case "set_font_size": {
                    ctx.setFontSize(float(cmd.size));
                    break;
                }
                case "set_matrix": {
                    ctx.setMatrix(<CairoMatrix>{
                        "xx": float(cmd.xx), "yx": float(cmd.yx),
                        "xy": float(cmd.xy), "yy": float(cmd.yy),
                        "x0": float(cmd.x0), "y0": float(cmd.y0),
                    });
                    break;
                }
                case "transform": {
                    ctx.transform(<CairoMatrix>{
                        "xx": float(cmd.xx), "yx": float(cmd.yx),
                        "xy": float(cmd.xy), "yy": float(cmd.yy),
                        "x0": float(cmd.x0), "y0": float(cmd.y0),
                    });
                    break;
                }
                default: {
                    throw "CAIRO-ERROR", sprintf("unknown draw command op: %y", op);
                }
            }
        }
    }

    #! Configures a gradient pattern with stops, extend, and filter from a draw command hash
    /** @param pat the gradient pattern to configure
        @param cmd the draw command hash containing optional stops, extend, and filter keys
    */
    static configureGradientPattern(CairoPattern pat, hash<auto> cmd) {
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
        if (cmd.extend) {
            pat.setExtend(string(cmd.extend));
        }
        if (cmd.filter) {
            pat.setFilter(string(cmd.filter));
        }
    }

    #! Refuses the filesystem paths and locations of a request if the calling code is restricted from them
    /** Library code runs with its own %Program's options, so the paths and locations that the calling code gives are
        refused before anything is read or written if that code is restricted from the \c FILESYSTEM functional
        domain (for example with \c PO_NO_FILESYSTEM), also when the provider was lent to that code by the host (see
        @ref Qore::SandboxManager::isLentToRestricted() "SandboxManager::isLentToRestricted()"); a location is refused
        if that code is restricted from a functional domain that the handler of the location's scheme uses for its
        caller (see @ref FileLocationHandler::AbstractFileLocationHandler::getCallerDomains()
        "AbstractFileLocationHandler::getCallerDomains()").

        @param req the request
        @param paths the fields of the request that are filesystem paths; a field of a nested hash is given with
        \c "." (ex: \c "commands[0].path" for the field \c "path" of the hash in the field \c "commands[0]"), and
        \c "[]" after the name of a field that holds a list stands for each of its elements (ex:
        \c "commands[].path")
        @param locations the fields of the request that are FileLocationHandler locations, given as \a paths

        @throw LOCATION-ERROR the options of a location cannot be parsed
        @throw PERMISSION-DENIED the calling code is restricted from the \c FILESYSTEM functional domain or from a
        functional domain of the handler of a location
    */
    static checkCallerPaths(hash<auto> req, list<string> paths, *list<string> locations) {
        foreach string field in (paths) {
            foreach auto v in (CairoActionBase::getFieldValues(req, field.split("."))) {
                if (exists v && SandboxManager::isLentToRestricted(DOM_FILESYSTEM)) {
                    throw "PERMISSION-DENIED", sprintf("the %y field of the request cannot be used: the calling code "
                        "is restricted from the FILESYSTEM functional domain", field);
                }
            }
        }
        foreach string field in (locations) {
            foreach auto v in (CairoActionBase::getFieldValues(req, field.split("."))) {
                if (exists v) {
                    CairoActionBase::checkCallerLocation(field, v);
                }
            }
        }
    }

    #! Refuses the filesystem paths and locations of draw commands if the calling code is restricted from them
    /** The \c path and \c location of the \c image and \c mask_surface commands are read for the calling code; see
        checkCallerPaths()

        @param commands the draw commands

        @throw LOCATION-ERROR the options of a location cannot be parsed
        @throw PERMISSION-DENIED the calling code is restricted from the \c FILESYSTEM functional domain or from a
        functional domain of the handler of a location
    */
    static checkCommandPaths(auto commands) {
        if (commands.typeCode() != NT_LIST) {
            return;
        }
        foreach auto cmd in (commands) {
            if (cmd.typeCode() == NT_HASH && (cmd.op == "image" || cmd.op == "mask_surface")) {
                string field = sprintf("commands[%d]", $#);
                CairoActionBase::checkCallerPaths({field: cmd}, (field + ".path",), (field + ".location",));
            }
        }
    }

    #! Returns the values of the given field of a request
    /** @param v the value to search
        @param path the components of the field's name; a component that ends in \c "[]" stands for each element of
        a list

        @return the values found; a value that is not a hash where a hash is expected (or not a list where a list is
        expected) has no fields
    */
    private static list<auto> getFieldValues(auto v, list<string> path) {
        if (!path) {
            return (v,);
        }
        string key = shift path;
        bool each = key =~ /\[\]$/;
        if (each) {
            splice key, -2;
        }
        if (v.typeCode() != NT_HASH) {
            return ();
        }
        auto fv = v{key};
        if (!each) {
            return CairoActionBase::getFieldValues(fv, path);
        }
        list<auto> rv = ();
        if (fv.typeCode() == NT_LIST) {
            foreach auto e in (fv) {
                rv += CairoActionBase::getFieldValues(e, path);
            }
        }
        return rv;
    }

    #! Refuses a location given in a request if the calling code is restricted from a functional domain of its handler
    /** @param field the name of the request field, for the error message
        @param location the location

        @throw LOCATION-ERROR the options of the location cannot be parsed
        @throw PERMISSION-DENIED the calling code is restricted from a functional domain of the location's handler
    */
    private static checkCallerLocation(string field, string location) {
        string scheme = (location =~ x/^(\w+):\/\//)[0] ?? "file";
        AbstractFileLocationHandler handler;
        try {
            handler = FileLocationHandler::getHandler(scheme);
        } catch (hash<ExceptionInfo> ex) {
            if (ex.err == "SCHEME-ERROR") {
                # an unknown scheme is refused when the location is used
                return;
            }
            rethrow;
        }
        # the options at the end of the location, as FileLocationHandler takes them
        *hash<auto> opts;
        *string opt_str = (location =~ x/((?:{).*(?:}))$/)[0];
        if (opt_str) {
            auto v = parse_to_qore_value(opt_str);
            if (v.typeCode() == NT_HASH) {
                opts = v;
            } else if (v.strp()) {
                opts = {v: True};
            } else {
                throw "LOCATION-ERROR", sprintf("the options of the location in the %y field of the request cannot be "
                    "parsed", field);
            }
        }
        int dom = handler.getCallerDomains(scheme, opts);
        if (dom && SandboxManager::isLentToRestricted(dom)) {
            throw "PERMISSION-DENIED", sprintf("the %y field of the request cannot be used: the calling code is "
                "restricted from a functional domain of the handler of %y locations", field, scheme);
        }
        # the handler of conn locations has no domains of its own and gives the options that the caller adds to the
        # handler that it resolves the location to, which judges the calling code as
        # SandboxManager::isCallerRestricted() does; for the code that a host-created provider was lent to, which that
        # does not see, the options are refused here if that code is restricted from the file system or the network
        if (!dom && opts && (scheme == "conn" || scheme == "connection")
                && ((SandboxManager::isLentToRestricted(DOM_FILESYSTEM)
                        && !SandboxManager::isCallerRestricted(DOM_FILESYSTEM))
                    || (SandboxManager::isLentToRestricted(DOM_NETWORK)
                        && !SandboxManager::isCallerRestricted(DOM_NETWORK)))) {
            throw "PERMISSION-DENIED", sprintf("the options of the location in the %y field of the request cannot be "
                "used: the calling code is restricted from the FILESYSTEM or NETWORK functional domain", field);
        }
    }

    #! Writes binary data to a file
    /**
        @throw PERMISSION-DENIED the calling code (also the code that a host-created provider was lent to) is restricted
        from the \c FILESYSTEM functional domain, or from a functional domain of the handler of a location; see
        checkCallerPaths()
    */
    static writeBinaryFile(string path, binary data) {
        # the path is the caller's input when this public method is called directly
        CairoActionBase::checkCallerPaths({"path": path}, ("path",));
        File f();
        f.open2(path, O_CREAT | O_WRONLY | O_TRUNC);
        f.write(data);
    }
}
}
