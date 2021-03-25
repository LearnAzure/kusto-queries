FROM squidfunk/mkdocs-material
RUN apk update
RUN apk add --no-cache \
    python3-dev \
    libffi-dev \
    build-base \
    # deps for Pillow
    freetype-dev \
    fribidi-dev \
    harfbuzz-dev \
    jpeg-dev \
    lcms2-dev \
    openjpeg-dev \
    tcl-dev \
    tiff-dev \
    tk-dev \
    zlib-dev \
    # deps for macros plugin
    cairo-dev \
    cairo \
    cairo-tools \
    libxml2-dev \
    libxslt-dev \
    libxslt \
    pango-dev \
    gdk-pixbuf-dev \
    shared-mime-info
RUN pip3 install --upgrade pip
RUN pip install --upgrade cffi 
RUN pip install --upgrade Pillow
RUN pip install mkdocs-macros-plugin mkdocs-pdf-export-plugin