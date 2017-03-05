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
    if (n != 9) {
        print "bad number of fields (" n " s/b 9) in: " $0
        exit 1
    }
    get(2, "buflen");
    get(4, "nbuf");
    get(6, "align");
    get(8, "port");
}

$3 ~ /bytes/ && $4 ~ /in/ {
    bytes = $2
    rsecs = $5
    bps = $9 * nbytes($10)
    rrsecs = (bytes/bps)/1000.0
    if (debug) {
        print "bytes", bytes, "rsecs", rsecs, "kbs", kbs, "rrsecs", \
            rrsecs, "nbytes", nbytes($10)
    }
}

$3 ~ /I\/O/ && $4 ~ /calls/ {
    ioc = $2
    mspc = $7
    cps = $10
}

END {
    print 
