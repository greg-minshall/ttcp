# make sure a field in input looks correct
function chk(i, expected) {
    if (a[i] != expected) {
        print "expected " expected "; got " a[i] " in: " $0
        exit 1
    }
}

$2 ~ /buflen=.*/ {
    n = split($0, a, "[=:, ]+")
    if (n != 9) {
        print "bad number of fields (" n " s/b 9) in: " $0
        exit 1
    }
    chk(2, "buflen");
    chk(4, "nbuf");
    chk(6, "align");
    chk(8, "port");
}

$3 ~ /bytes/ && $4 ~ /in/ {
    bytes = $2
    rsecs = $5
    kbs = $9
    rrsecs = (bytes/kbs)/1000.0
    print "bytes", bytes, "rsecs", rsecs, "kbs", kbs, "rrsecs", rrsecs
}
