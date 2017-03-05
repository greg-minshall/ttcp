BEGIN {
    FS = "[=:, ]+"
}

# make sure the name of a field in input looks correct, then return value
function get(name, nwhere, vwhere) {
    if ($nwhere != name) {
        print "expected " name "; got " $nwhere " in: " $0
        exit 1
    }
    return $vwhere
}

function nfields(expected) {
    if (NF != expected) {
        print "bad number of fields (" NF " s/b " expected ") in: " $0
        exit 1
    }
}
        

# look at, e.g., "KB/s" to determine actual number of bytes
function nbytes(str) {
    if (str ~ /^G/) {
        val = 1000000000
    } else if (str ~/^M/) {
        val =    1000000
    } else if (str ~ /^K/) {
        val =       1000
    }
    # are we dealing with bits?  if so, convert to bytes
    if (str ~/^.bit/) {
        val /= 8;
    }
    return val
}

$2 ~ /buflen/ {
    nfields(12)
    ttcp = $1                   # "ttcp-t" or "ttcp-r"
    buflen = get("buflen", 2, 3)
    nbuf = get("nbuf", 4, 5)
    align = get("align", 6, 7)
    port = get("port", 8, 9)
    proto = $10                 # no tag
    remote = get("->", 11, 12)
}

$3 ~ /bytes/ && $4 ~ /in/ {
    nfields(10)
    bytes = get("bytes", 3, 2)
    realsecs = get("real", 6, 5)
    bps = get("seconds", 7, 8) * nbytes(get("+++", 10, 9))
    kbps = bps/1000
    rrealsecs = (bytes/bps) # we seem to get better accuracy from this, imputed
}

$3 ~ /I\/O/ && $4 ~ /calls/ {
    nfields(8)
    ioc = get("I/O", 3, 2)
    mspc = get("msec/call", 5, 6)
    cps = get("calls/sec", 7, 8)
    rcpusecs = ioc/cps
}

END {
    print "ttcp", ttcp, \
        "buflen", buflen, "nbuf", nbuf, "align", align, "port", port,   \
        "proto", proto, "remote", remote, \
        "bytes", bytes, "realsecs", realsecs, "kbps", kbps, "rrealsecs", rrealsecs, \
        "ioc", ioc, "mspc", mspc, "cps", cps, "rcpusecs", rcpusecs
}
