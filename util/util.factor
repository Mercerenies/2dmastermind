
USING: fry kernel sequences math assocs locals ;
IN: 2dmastermind.util

<PRIVATE

SINGLETON: empty-identity

PRIVATE>

ERROR: empty-sequence ;

: reduce-nonempty ( ... seq quot: ( ... prev elt -- ... next ) -- ... result )
    [ empty-identity ] dip
    '[ over empty-identity = [ nip ] [ @ ] if ] reduce
    dup empty-identity =
    [ empty-sequence ] [ ] if ; inline

: maximum-by ( seq quot: ( x -- n ) -- x )
    '[ 2dup [ @ ] bi@ > [ drop ] [ nip ] if ] reduce-nonempty ; inline

:: assoc-intersect-with ( assoc1 assoc2 quot: ( x y -- z ) -- assoc )
    assoc1 [ drop assoc2 key? ] assoc-filter [ over assoc2 at quot call ] assoc-map ; inline
