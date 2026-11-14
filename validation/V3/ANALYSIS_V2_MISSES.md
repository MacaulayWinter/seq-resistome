# Why V2 missed mdtB and msbA and called KpnG, acrA, IreK (analysis, 2026-11-14)

From V2 data on disk only (arg_long.tsv, the `core/` read statistics in the V2 work
folders, the RGI truth tables). No Docker, no V3 data, no mark changed. V2 is now seen
data: anything learned here is development, and only a fresh V3 draw can validate it.

## Missed loci (mark 1, truth identity 92.6% and 95.2%)

| Sample | Gene | f70g90 gene identity | core reads | core identity | core breadth ratio | Why not detected |
|---|---|---|---|---|---|---|
| wastewater 2x | mdtB | 0.863 | 25 | 0.941 | 0.76 | both routes fail |
| wastewater 8x | mdtB | 0.8994 | 99 | 0.948 | ok | 0.8994 is under 0.90 by 0.0006; core 0.948 under 0.95 |
| wastewater 2x | msbA | 0.815 | 21 | 0.948 | 0.98 | core 0.948 under 0.95 |

The same genes pass in the gut mixtures (mdtB 0.905-0.919, msbA through the core route at
0.952-0.960), where the background holds few homologs. In wastewater the background adds
many reads from related genes at 70-89% (msbA: 299-381 reads below 70% or in the 70-89%
band against 61-93 from the spike), which drags the pooled gene identity far under 0.90.
The core route should rescue it, but a gene whose own sequence is 92-95% identical to
CARD has core reads averaging 94-95%, and the core cut is 0.95.

**Cause: a rule flaw (the 0.95 core cut), not noise and not a mark flaw.** 0.95 was set on
rounds 3-4, where the genes lay at 95% or more. A real gene at 92-95% identity can pass
the pooled route only when the background is quiet. Genes in this band are exactly what
V3's mark 1 (92% or more) marks.

## Unexplained detections (mark 2)

- **IreK, *Enterococcus*, 0.5x and 2x gut mixtures (3 reads each, 9% covered):** the
  background alone has 2 reads (breadth 0.455, just under the 0.5 cut). With the spike added
  the same 3 high-identity reads pass (breadth 0.85, identity 0.953). The spike's own
  IreK is 59% (RGI Loose) and gives 46 reads at 88% in the pure genome, which fail. So these
  3 reads are the gut background's own, and the "detected in the background alone"
  explanation missed them because the background sample fell just short of 0.5.
  **Noise at 2-3 reads, plus a mark-2 explanation that is too strict.**
- **acrA (Kpne_acrA), *Citrobacter* wastewater 2x (2 reads, 21% covered):** 2 reads,
  the minimum. **Noise** at the read-count floor (`--min_arg_reads 2`).
- **KpnG (Kpne_KpnG), *Citrobacter* pure genome (36 reads, 64% covered, 0.909 identity):**
  a real, well-covered gene at 91% to CARD's KpnG, detected by f70g90. RGI `main` does not
  list it, probably because RGI names the open reading frame by a different best-hit ARO
  (KpnE and KpnF, the same pump family, are listed there as protein-only hits). **A
  truth flaw (RGI's one-name-per-gene assignment), not a pipeline error.** Not yet
  checked directly; a blastp of the genome's ORFs against CARD's KpnG, run natively, would settle it.

## Options

1. **Leave the rule and the marks as pre-registered; run V3.** V3 would very likely fail
   again on mark 1 (genes in the 92-95% band in wastewater), so this spends a draw to
   learn what is known.
2. **Raise mark 1's cut from 0.92 to 0.96, so these loci are not marked.** It hides the
   misses and makes V3 pass by narrowing the claim to genes the rule handles. The
   rule would still fail on real genes at 92-95%. Not recommended: it moves the goalposts.
3. **Change the rule: lower `--min_protein_core_gene_identity` from 0.95 toward 0.93**,
   chosen by an offline sweep on rounds 3, 4 and V2 (all seen, so development), with the
   specificity cost read off the same data, then pre-registered in V3 before any V3 data are
   touched. On V2 alone a cut of 0.94 would rescue msbA and mdtB at 8x; mdtB at 2x also
   fails the breadth ratio (0.76 < 0.8) and would stay missed, so it needs the breadth cut
   looked at in the same sweep. Marks stay as pre-registered.
4. **Option 3, plus two mark clarifications**, each a separate user decision before V3:
   (a) mark 3 only for loci that mark 1 marks (a gene not marked in mark 1 should
   not fail mark 3 with 0 copies); (b) mark 2's background explanation uses the
   background sample's reads at the same identity and read count, not only its own "detected" call.

Recommended: 3, with the sweep done offline on rounds 3, 4 and V2 first, and the
mark 3 coherence fix (4a) decided with it. No V3 data, no tag.
