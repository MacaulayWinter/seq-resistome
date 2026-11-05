// Calls the CARD cache exactly as main.nf does, with CARD's site replaced by
// local files (tests/card_cache/test_card_cache.sh). Prints one result line.
include { cardArchive } from '../../utils/card_cache'

params.which = 'validated'
params.cache = null
params.csv   = null
params.page  = null
params.base  = null

workflow {
    def (archive, version, validated, sha, action) = cardArchive(params.which, params.cache, params.csv, params.page, params.base)
    println "RESULT\t${version}\t${validated}\t${sha}\t${action}\t${archive}"
}
