# TEI format used in HWGW

## XML Schema

The format is defined in the three main XML schema files:

- `apparat-schema.xsd` for the appatatus, documents and indexes
- `books-schema.xsd` for the edition text
- `introduction-schema.xsd` for the introductions for each volume
- `register-schema.xsd` for the indexes for the digital edition

These definitions are dependent on following files:

- `core-schema.xsd` for elements in the different texts
- `xml.xsd` for XML core attributes

## Metadata

The metadata are defined in the TEI header. The XML Schema gives most hints but does not strictly define the content
yet.

The TEI header includes information about the documents themselves, the project and funding, and how the data can be
shared.

## Format of the introductions

The introductions follow a format with the text contained in the `text/body` element, while the `text/back` element is 
used for keeping track which endnote was printed on what page.

## Format of the edition text

Title pages, prefaces and tables of content are placed in the `text/front` element.

The element `main/body` contains the core of the original book.

Tables of content after the body are placed in `text/back`.

The edition text contains two kinds of comments:

- The original footnotes are placed directly in the content and their original position is marked with the attribute
  `@place`
- The comments that are part of the edition are placed inline and can be recognized by the attribute `@type="comment"`.

Similar to the comments, there are two sets of page breaks. Due to limitations of TEI Publisher, different tags are
used:

- The original page breaks are marked with `milestone` and the attribute `@unit="page"`.
- The modern page breaks are marked with the element `pb`.

## Format of the apparatus

All content is located in `text/body`. Internally it is divided into explanations about the edition, documents relevant
to the edited book, and indexes of the entities mentioned in the volume.

## Individual phenomenons

#### Notes and comments

Notes in the introduction are placed inline with the element `note`. Notes in principle contain `p` elements.
All notes have the attributes `@n` and `@xml:id`.

##### Notes in the introduction

Notes to the introduction are marked with the element `note`.

Example:

```xml
<p>... Kunstsprache ins Zentrum der 
Darstellung.<note xml:id="s03-in-comment-9" n="9">
<p xml:id="s03-in-comment-9-p-1"><bibl corresp="bib-Woelfflin.1889.Gessner">Wölfflin 1889 Geßner</bibl>, 
S. <ref type="page" target="#s03-ed-pg109">109–121</ref>.</p>
</note>
</p>
```

Notes can generally occur in paragraphs and similar positions. They can also occur in inline elements like highlighting.
A special case is their usage in the `figure` element when they comment an image.

##### Original footnotes in the edition text

Footnotes in the original text are distinguished by the attribute `@place="foot"`. They are numbered in `@n` according
to the modern printed edition while the original number together with the page number is preserved in a special `fw`
element.

Example:

```xml
<p>... Quart,<note place="foot" n="I" xml:id="s03-ed-pg37-note-2"><fw type="original-footnote" n="{37}2"/><p 
        xml:id="s03-ed-pg37-note-2-p-2">Er plante sie seit 1771. Vgl. ...</p></note> auf</p>
```

##### Comments to the edition text

The modern comments in the edition text and the documents are distinguished by the attribute `@type="comment"`.

Example:

```xml
<p> 1771.<note type="comment" n="144" xml:id="s03-ed-comment-144"><p xml:id="s03-ed-comment-144-p-2"><bibl
        corresp="bib-Gessner.1862.Briefe">Gessner 1862 Briefe</bibl>, S. 169.</p></note>
</p>
```

##### Comments to the apparatus

The comments in the apparatus text are distinguished by the attribute `@type="note"`.

Example:

```xml
<p>... verwendete.<note type="note" n="16" xml:id="s03-app-ch-1-note-16"><p 
        xml:id="s03-app-ch-1-note-16-p-1">Vgl. den Kommentar, 
    Anm. <ref type="comment" target="#s03-ed-comment-250">250</ref>.</p></note> Auch ...
</p>
```

#### Figures

All figures are linked to IIIF images. Additionally, they are numbered with their position in the local IIIF manifest.

Figures are tagged with `figure`. The required child elements are `graphic` (containing the image file information) and
`figDesc` (containing from the table of figures from the edition).

Captions are described in containing `head` elements.
In case, there are comments to an image, a `note` element is placed into the `figure` element. In presence of a caption,
the comments are usually attached to the caption in the `note` element.

Figures require a number (attribute `@n`) and a unique `@xml:id`.

`@type="moved"` indicates that the image is in the position where it was printed for the edition and that the position
differs from the source data. The original position is indicated with a `ptr` element.

Figures can have the attribute `@rendition` to indicate lateral alignment. A special case is the attribute `@rend` that
is solely used with the value `inline` when the figure is floating in the text.

The `graphic` element has no content. It requires the attributes `@url` for the path to the image and `@n` for the
position in the IIIF manifest.

Figures can generally occur in `div` elements. When used inline, they can also stan in `p` elements.

#### Headings



#### Lists

Lists (element `list`) can contain the child elements `item` and (optionally) `label`.

<!-- TODO gloss -->

#### Page breaks

#### Links and annotations

## Specific encodings for HWGW

### 