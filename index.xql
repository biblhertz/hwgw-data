xquery version "3.1";

module namespace idx="http://teipublisher.com/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace dbk="http://docbook.org/ns/docbook";

declare variable $idx:app-root :=
    let $rawPath := system:get-module-load-path()
    return
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    ;

(:~
 : Helper function called from collection.xconf to create index fields and facets.
 : This module needs to be loaded before collection.xconf starts indexing documents
 : and therefore should reside in the root of the app.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    return
        switch ($field)
            case "title" return
                string-join((
                    $header//tei:msDesc/tei:head, $header//tei:titleStmt/tei:title[@type = 'main'],
                    $header//tei:titleStmt/tei:title,
                    $root/dbk:info/dbk:title
                ), " - ")
            case "author" return (
                $header//tei:correspDesc/tei:correspAction/tei:persName,
                $header//tei:titleStmt/tei:author,
                $root/dbk:info/dbk:author
            )
            case "language" return
                head((
                    $header//tei:langUsage/tei:language/@ident,
                    $root/@xml:lang,
                    $header/@xml:lang
                ))
            case "date" return head((
                $header//tei:correspDesc/tei:correspAction/tei:date/@when,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:publicationStmt/tei:date,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:date/@when,
                $header//tei:fileDesc/tei:editionStmt/tei:edition/tei:date,
                $header//tei:publicationStmt/tei:date
            ))
            case "genre" return (
                idx:get-genre($header),
                $root/dbk:info/dbk:keywordset[@vocab="#genre"]/dbk:keyword
            )
            default return
                ()
};

declare function idx:get-genre($header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};

(: manual addition: get the genre of a note, i.e. if a note is primary or secondary content :)

declare function idx:get-text-context($elem as element()?, $header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        if ($target = "#edition") then
            ("Editionstext")
        else if ($target = "#apparatus") then
            ("Apparat")
        else if ($target = "#introduction") then
            ("Einleitung")
        else if ($target = "#index") then
            ("Index")
        else
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};

declare function idx:get-div-context($elem as element()?, $header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        if ($target = "#edition") then
            ("Editionstext", "Primärtext")
        else if ($target = "#apparatus") then
            ("Apparat", "Apparattext")
        else if ($target = "#introduction") then
            ("Einleitung")
        else if ($target = "#index") then
            ()
        else
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};

declare function idx:get-note-context($note as element()?, $header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        if ($note/@type = 'comment' and $target = "#edition") then
            ("Editionstext", "Kommentar (Edition)")
        else if ($note/@type = 'comment' and $target = "#apparatus") then
            ("Apparat", "Dokumente", "Kommentar (Dokumente)")
        else
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};

declare function idx:get-object-provenience($object as element()?) {
    let $noteElement := $object/tei:note

    let $termLevel :=
        if (exists($noteElement/tei:term)) then
            ('Objekte', 'Verschiedene Orte', $noteElement/tei:term)
        else
            ('Objekte')

    let $placeLevel :=
        if (exists($noteElement/tei:placeName[@type='settlement'])) then
            ($termLevel, ($noteElement/tei:placeName[@type='settlement']))
        else
            $termLevel

    let $museumLevel :=
        if (exists($noteElement/tei:placeName[@type='address'])) then
            ($placeLevel, ($noteElement/tei:placeName[@type='address']))
        else
            $placeLevel

    let $objectLevel :=
        if (exists($noteElement/tei:objectName)) then
            ($museumLevel, ($noteElement/tei:objectName))
        else
            $museumLevel

    return $objectLevel
};

declare function idx:occurrences($entryId as xs:string?) as xs:integer {
    let $occurrencesRef := collection($idx:app-root || '/data')//tei:rs[@ref=$entryId]
    let $occurrencesCorresp := collection($idx:app-root || '/data')//tei:bibl[@corresp=$entryId]

    (: This is ugly but conditional sorting is messy:)
    let $numberOfOccurrences := count($occurrencesRef) + count($occurrencesCorresp)
    return $numberOfOccurrences  
};

