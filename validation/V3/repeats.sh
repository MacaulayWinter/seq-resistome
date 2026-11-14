#!/usr/bin/env bash
#*******************************************************************************
# repeats.sh: which truth loci have another copy in their own genome (V3
# pre-registration, section 2, mark 3; V2 result, D35)
#
# For each genome, each RGI main Perfect/Strict protein-homolog locus
# (<g>.strict.txt) is cut from the genome and searched against the whole
# genome with blastn. A locus has another copy if some hit that does not
# overlap the locus itself (under half of the hit inside it) has at least 95%
# identity over at least 500 bp, or over at least half the locus length when
# the locus is shorter than 1,000 bp. Output: <truth dir>/<g>.repeats.tsv with
# columns locus, n_other_copies, other_copies (contig:start-end of each).
#
# Usage: bash validation/V3/repeats.sh <genomes dir> <truth dir> <genome> [genome ...]
# Needs blastn (BLAST+) on PATH.
#*******************************************************************************
set -euo pipefail
gdir=$(cd "$1" && pwd); tdir=$(cd "$2" && pwd); shift 2
command -v blastn > /dev/null || { echo "repeats.sh: blastn not on PATH" >&2; exit 1; }
for g in "$@"; do
    python3 -I - "$gdir/$g.fna" "$tdir/$g.strict.txt" "$tdir/$g.repeats.tsv" "$g" <<'PY'
import sys, subprocess, csv, tempfile, os
fna, strict, out, g = sys.argv[1:5]
seqs, name = {}, None
for l in open(fna):
    if l[0] == ">": name = l[1:].split()[0]; seqs[name] = []
    else: seqs[name].append(l.strip())
seqs = {k: "".join(v) for k, v in seqs.items()}
rows = list(csv.DictReader(open(strict), delimiter="\t"))
loci = []
for r in rows:
    if r["Model_type"] != "protein homolog model" or r["Cut_Off"] not in ("Perfect", "Strict"): continue
    contig = r["Contig"]
    a, b = sorted((int(r["Start"]), int(r["Stop"])))
    loci.append((contig, a, b))
res = []
for contig, a, b in loci:
    L = b - a + 1
    with tempfile.NamedTemporaryFile("w", suffix=".fa", delete=False) as t:
        t.write(">q\n" + seqs[contig][a - 1:b] + "\n"); q = t.name
    o = subprocess.run(["blastn", "-query", q, "-subject", fna, "-outfmt", "6 sseqid pident length sstart send",
                        "-evalue", "1e-10", "-dust", "no"], capture_output=True, text=True, check=True).stdout
    os.unlink(q)
    need = 500 if L >= 1000 else 0.5 * L
    others = set()
    for line in o.splitlines():
        s, pid, ln, ss, se = line.split("\t"); pid = float(pid); ln = int(ln); lo, hi = sorted((int(ss), int(se)))
        if pid < 95 or ln < need: continue
        inside = max(0, min(hi, b) - max(lo, a) + 1) if s == contig else 0
        if inside >= 0.5 * (hi - lo + 1): continue
        others.add("%s:%d-%d" % (s, lo, hi))
    res.append(("%s:%s:%d-%d" % (g, contig, a, b), len(others), ";".join(sorted(others))))
with open(out, "w") as f:
    f.write("locus\tn_other_copies\tother_copies\n")
    for r in res: f.write("%s\t%d\t%s\n" % r)
print("repeats.sh: %s: %d loci, %d with another copy" % (g, len(res), sum(1 for r in res if r[1] > 0)))
PY
done
