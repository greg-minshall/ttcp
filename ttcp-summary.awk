# make sure a field in input looks correct
function get(i, expected) {
    if (a[i] != expected) {
        print "expected " expected "; got " a[i] " in: " $0
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

$2 ~ /buflen=.*/ {
    n = split($0, a, "[=:, ]+")
    if (n != 13) {
        print "bad number of fields (" n " s/b 9) in: " $0
        exit 1
    }
    get(2, "buflen");
    buflen = a[3]
    get(4, "nbuf");
    nbuf = a[5]
    get(6, "align");
    align = a[7]
    get(8, "port");
    port = a[9]
    proto = a[10]
    remote = a[13]
}

$3 ~ /bytes/ && $4 ~ /in/ {
    bytes = $2
    bsecs = $5
    bps = $9 * nbytes($10)
    kbps = bps/1000
    rbsecs = (bytes/bps) # we get better accuracy from this, imputed
    if (debug) {
        print "bytes", bytes, "bsecs", bsecs, "kbps", kbps, \
            "rbsecs", rbsecs, "nbytes", nbytes($10)
    }
}

$3 ~ /I\/O/ && $4 ~ /calls/ {
    ioc = $2
    mspc = $7
    cps = $10
    rcsecs = ioc/cps
}

END {
    print "buflen", buflen, "nbuf", nbuf, "align", align, "port", port, \
        "proto", proto, "remote", remote, \
        "bytes", bytes, "bsecs", bsecs, "kbps", kbps, "rbsecs", rbsecs, \
        "ioc", ioc, "mspc", mspc, "cps", cps, "rcsecs", rcsecs
}
