# Qore Cairo Module

## Introduction

The `cairo` module provides Qore bindings for the
[Cairo 2D graphics library](https://www.cairographics.org/), enabling
creation and manipulation of vector graphics in SVG, PostScript, and EPS
formats, as well as PNG raster images.

With optional [librsvg](https://wiki.gnome.org/Projects/LibRsvg) support,
the module can also load and render existing SVG files, converting them to
PNG, PostScript, or EPS.

## Features

- Create SVG, PostScript, and EPS documents from drawing commands
- Create and manipulate PNG raster images
- Path operations: lines, curves, arcs, rectangles
- Text rendering with font face and size control
- Linear and radial gradient patterns
- Affine transformations: translate, rotate, scale, matrix
- Multi-page PostScript output
- Recording surfaces for deferred rendering
- SVG input and format conversion (requires librsvg)
- Data provider integration for Qorus workflows

## Requirements

- Qore 2.0+
- CMake 3.5+
- C++17 compiler
- Cairo (required)
- librsvg (optional; enables SVG input and conversion)

## OS Packages

Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y cmake pkg-config libcairo2-dev
# Optional: SVG input support
sudo apt-get install -y librsvg2-dev
```

Alpine:

```bash
sudo apk add --no-cache cmake pkgconfig cairo-dev
# Optional: SVG input support
sudo apk add --no-cache librsvg-dev
```

Fedora:

```bash
sudo dnf install -y cmake pkgconf-pkg-config cairo-devel
# Optional: SVG input support
sudo dnf install -y librsvg2-devel
```

MacPorts:

```bash
sudo port install cmake pkgconfig cairo
# Optional: SVG input support
sudo port install librsvg
```

## Building

```bash
mkdir build
cd build
cmake ..
make
make install
```

To disable librsvg SVG input support:

```bash
cmake .. -DENABLE_RSVG=OFF
```

## Quick Start

### Create an SVG file

```qore
#!/usr/bin/qore

%requires cairo

CairoSurface svg = CairoSurface::createSvg("label.svg", 400.0, 200.0);
CairoContext ctx(svg);

# Draw border
ctx.rectangle(5.0, 5.0, 390.0, 190.0);
ctx.setSourceRgb(0.0, 0.0, 0.0);
ctx.setLineWidth(2.0);
ctx.stroke();

# Add title
ctx.selectFontFace("Helvetica", "normal", "bold");
ctx.setFontSize(24.0);
ctx.moveTo(20.0, 40.0);
ctx.showText("SHIPPING LABEL");

# Add details
ctx.selectFontFace("Helvetica", "normal", "normal");
ctx.setFontSize(14.0);
ctx.moveTo(20.0, 70.0);
ctx.showText("To: Customer Name");
ctx.moveTo(20.0, 90.0);
ctx.showText("123 Main Street");

svg.finish();
```

### Create a PNG image with gradients

```qore
#!/usr/bin/qore

%requires cairo

CairoSurface img = CairoSurface::createImage(300, 300);
CairoContext ctx(img);

# Background gradient
CairoPattern grad = CairoPattern::createLinear(0.0, 0.0, 0.0, 300.0);
grad.addColorStopRgb(0.0, 0.2, 0.4, 0.8);
grad.addColorStopRgb(1.0, 0.0, 0.1, 0.3);
ctx.setSource(grad);
ctx.paint();

# Draw a white circle
ctx.setSourceRgba(1.0, 1.0, 1.0, 0.9);
ctx.arc(150.0, 150.0, 100.0, 0.0, 2.0 * M_PI);
ctx.fill();

img.writeToPng("gradient.png");
```

### Convert SVG to PNG (requires librsvg)

```qore
#!/usr/bin/qore

%requires cairo

CairoSvgReader reader("logo.svg");
float w = reader.getWidth();
float h = reader.getHeight();

CairoSurface img = CairoSurface::createImage(int(w), int(h));
CairoContext ctx(img);
reader.renderTo(ctx);
img.writeToPng("logo.png");
```

### Create a PostScript document

```qore
#!/usr/bin/qore

%requires cairo

# US Letter: 612 x 792 points
CairoSurface ps = CairoSurface::createPs("document.ps", 612.0, 792.0);
CairoContext ctx(ps);

# Page 1
ctx.selectFontFace("Times", "normal", "bold");
ctx.setFontSize(36.0);
ctx.setSourceRgb(0.0, 0.0, 0.0);
ctx.moveTo(72.0, 720.0);
ctx.showText("Chapter 1");
ctx.showPage();

# Page 2
ctx.selectFontFace("Times", "normal", "normal");
ctx.setFontSize(12.0);
ctx.moveTo(72.0, 720.0);
ctx.showText("Body text on page two.");

ps.finish();
```

## Data Provider

The module includes a CairoDataProvider for integration with Qore's data
provider framework and Qorus workflows.

```qore
%requires CairoDataProvider

AbstractDataProvider dp = DataProvider::getFactoryObjectFromStringEx("cairo{}/image/create");

hash<auto> result = dp.doRequest({
    "width": 200,
    "height": 200,
    "commands": (
        {"op": "set_source_rgb", "r": 1.0, "g": 0.0, "b": 0.0},
        {"op": "arc", "x": 100, "y": 100, "radius": 80, "angle1": 0.0, "angle2": 6.283},
        {"op": "fill"},
    ),
    "output_path": "circle.png",
});
```

Example `qdp` actions:

```bash
# Create SVG
qdp 'cairo{}/svg/create' width=400,height=200,output_path=out.svg,commands='({"op":"set_source_rgb","r":0,"g":0,"b":0},{"op":"rectangle","x":10,"y":10,"width":380,"height":180},{"op":"stroke"})'

# Convert SVG to PNG (requires librsvg)
qdp 'cairo{}/svg/to-png' input_path=logo.svg,output_path=logo.png,width=256,height=256

# Get SVG info (requires librsvg)
qdp 'cairo{}/svg/get-info' input_path=logo.svg

# Create PNG image
qdp 'cairo{}/image/create' width=200,height=200,output_path=circle.png,commands='({"op":"set_source_rgba","r":1,"g":0,"b":0,"a":1},{"op":"arc","x":100,"y":100,"radius":80,"angle1":0,"angle2":6.283},{"op":"fill"})'

# Get PNG image info
qdp 'cairo{}/image/get-info' input_path=photo.png

# Draw on existing PNG
qdp 'cairo{}/image/draw' input_path=photo.png,output_path=annotated.png,commands='({"op":"text","text":"Watermark","x":10,"y":30,"size":20})'

# Create PostScript
qdp 'cairo{}/postscript/create' width=612,height=792,output_path=doc.ps,commands='({"op":"text","text":"Hello","x":72,"y":720,"family":"Helvetica","size":24})'

# Create EPS
qdp 'cairo{}/postscript/create' width=400,height=300,eps=true,output_path=figure.eps,commands='({"op":"rectangle","x":10,"y":10,"width":380,"height":280},{"op":"stroke"})'

# Convert SVG to PostScript (requires librsvg)
qdp 'cairo{}/svg/to-ps' input_path=diagram.svg,output_path=diagram.ps,width=612,height=792

# Convert SVG to EPS (requires librsvg)
qdp 'cairo{}/svg/to-eps' input_path=logo.svg,output_path=logo.eps,width=400,height=400
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Copyright

Copyright 2026 Qore Technologies, s.r.o.
