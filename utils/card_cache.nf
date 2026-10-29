/*
 * CARD cache (CLAUDE.md D1, D5)
 *
 * CARD is downloaded once from card.mcmaster.ca into a cache folder outside
 * any run (default ~/.seq-resistome/card) and reused by every later run. It
 * is checked before every run: the archive's SHA-256 is compared with the
 * checksum pinned in assets/card_versions.csv (or, for a release this
 * version of the pipeline was not validated with, the checksum recorded
 * when it was first downloaded). A mismatch is reported and the archive
 * fetched again; a cache is never used without passing the check.
 *
 * This runs in Nextflow itself, before any task, so the download happens on
 * the machine that launches the run (on an HPC, the login node, which has
 * internet when compute nodes may not).
 */

def sha256(path) {
    def md = java.security.MessageDigest.getInstance('SHA-256')
    return md.digest(java.nio.file.Files.readAllBytes(path)).encodeHex().toString()
}

// The newest CARD release named on CARD's download page.
def latestCardVersion(String page) {
    def html
    try {
        html = java.net.URI.create(page).toURL().text
    } catch (Exception e) {
        error("Could not reach ${page} to find the latest CARD release (${e.message}). Use --card_version validated with a cache that already holds it, or try again online.")
    }
    def found = (html =~ /broadstreet-v(\d+)\.(\d+)\.(\d+)\.tar\.bz2/).collect { m -> [ m[1] as int, m[2] as int, m[3] as int ] }.unique()
    if (!found) {
        error("${page} names no CARD release (broadstreet-vX.Y.Z.tar.bz2): the page may have changed. Use --card_version validated.")
    }
    def newest = found.max { a, b -> a[0] <=> b[0] ?: a[1] <=> b[1] ?: a[2] <=> b[2] }
    return newest.join('.')
}

// Download url to target via a temporary file in the same folder, then
// rename: a run stopped part-way, or two runs at once, never leave a
// half-written archive under the real name.
def download(String url, target) {
    def tmp = target.resolveSibling("${target.name}.part-${java.util.UUID.randomUUID()}")
    try {
        java.net.URI.create(url).toURL().openStream().withCloseable { s ->
            java.nio.file.Files.copy(s, tmp, java.nio.file.StandardCopyOption.REPLACE_EXISTING)
        }
        java.nio.file.Files.move(tmp, target, java.nio.file.StandardCopyOption.REPLACE_EXISTING, java.nio.file.StandardCopyOption.ATOMIC_MOVE)
    } catch (Exception e) {
        java.nio.file.Files.deleteIfExists(tmp)
        error("Could not download CARD from ${url}: ${e.message}")
    }
}

/*
 * Returns [ archive, version, validated, sha256, action ] for the CARD
 * release asked for: 'validated' or 'latest'. downloadPage and downloadBase
 * are CARD's (main.nf); the tests point them at local files.
 */
def cardArchive(String which, String cacheDir, String versionsCsv, String downloadPage, String downloadBase) {
    def rows      = file(versionsCsv).splitCsv(header: true)
    def validated = rows.find { r -> r.status == 'validated' }
    if (!validated) {
        error("${versionsCsv} has no row with status 'validated'.")
    }
    def version  = which == 'latest' ? latestCardVersion(downloadPage) : validated.version
    def pinned   = rows.find { r -> r.version == version && r.status == 'validated' }
    def url      = pinned ? pinned.url : "${downloadBase}broadstreet-v${version}.tar.bz2"
    def cache    = file(cacheDir)
    cache.mkdirs()
    def archive  = cache.resolve("broadstreet-v${version}.tar.bz2")
    // A release we have not validated has no pinned checksum: the one
    // recorded at its first download stands in, so damage is still caught.
    def sidecar  = cache.resolve("broadstreet-v${version}.tar.bz2.sha256")
    def expected = pinned ? pinned.sha256 : (sidecar.exists() ? sidecar.text.trim() : null)

    def action
    if (archive.exists() && expected && sha256(archive) == expected) {
        action = 'reused from the cache (checksum matches; nothing downloaded)'
    } else {
        if (archive.exists()) {
            def why = expected ? "its SHA-256 does not match the recorded ${expected}" : 'it has no recorded checksum to check it against'
            log.warn("CARD ${version} in ${cache}: ${why}. The cached copy is not used; fetching it again from ${url}.")
            action = 'fetched again (the cached copy failed its checksum)'
        } else {
            action = 'downloaded into the cache (first use)'
        }
        download(url, archive)
        def got = sha256(archive)
        if (pinned && got != pinned.sha256) {
            error("CARD ${version} downloaded from ${url} has SHA-256 ${got}, not the pinned ${pinned.sha256}. CARD may have replaced the file, or the download was damaged. Nothing was run.")
        }
        if (!pinned) {
            sidecar.text = got + '\n'
        }
    }
    return [ archive, version, pinned != null, sha256(archive), action ]
}
