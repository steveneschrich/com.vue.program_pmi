<template>
  <div>
    <div id="title">
      PROGRAM-PMI
    </div>
    <div id="inputPmid" class="row justify-center">
      <q-input 
        class="col-3"
        color="amber-7"
        label-color="amber-7"
        rounded
        filled
        v-model="pmid"
        label="PMID"
        dark
        @keypress="onKeyPress"
      />
    </div>
    <p/>
    <div class="row justify-center">
      <q-btn
        outline
        color="amber-7"
        label="Retrieve Pubmed Record"
        @click="onClickSubmit"
      />
    </div>
    <p/>
    <Citation :citation="citation"/>
    <p/>
    <StoreCitation :citation="citation" :zoteroSearchObj="zoteroSearchObj"/>
    <div v-if="errorMessage !== ''" id="errorMessage">
      {{ errorMessage }}
    </div>
  </div>
</template>

<script>

  import axios from 'axios'
  import Citation from '../components/Citation'
  import StoreCitation from '../components/StoreCitation.vue'

  const ZOTERO_BASE_URL = `${process.env.VUE_APP_ZOTERO_TRANSLATOR_HOST}:${process.env.VUE_APP_ZOTERO_TRANSLATOR_PORT}`
  const CITEPROC_BASE_URL = `${process.env.VUE_APP_CITEPROC_HOST}:${process.env.VUE_APP_CITEPROC_PORT}`
  const ZOTERO_SEARCH_URL = `${ZOTERO_BASE_URL}/search`
  const ZOTERO_EXPORT_TO_CSLJSON = `${ZOTERO_BASE_URL}/export?format=csljson`
  const CITEPROC_GET_MLA_CITATIONS = `${CITEPROC_BASE_URL}?responseformat=html&style=modern-language-association&outputformat=text`

  export default {
    name: 'PmidQuery',
    components: { Citation, StoreCitation },
    data () {
      return {
        pmid: '',
        citation: '',
        zoteroSearchObj: [],
        errorMessage: ''
      }
    },
    methods: {
      onKeyPress (e) {
        if (e.key.toLowerCase() === 'enter') {
          this.submit()
        }
      },
      onClickSubmit () {
        this.submit()
      },
      async submit () {

        this.citation = ''
        this.zoteroSearchObj = ''
        this.errorMessage = ''
        
        let error = false

        if (this.pmid === '' || this.pmid === null || this.pmid === undefined) {
          error = true
          this.errorMessage = 'PMID cannot be empty'
        }

        if (!error) {
          const resZoteroSearch = await this.search().catch(() => this.errorMessage = 'Zotero search failed and returned no results')
          const resZoteroExport = await this.zoteroToCslJson(resZoteroSearch.data).catch(() => this.errorMessage = 'Unable to convert Zotero to CSL JSON')
          const resCiteprocMla = await this.citeProcGetCitation(resZoteroExport.data).catch(() => this.errorMessage = 'Cannot retrieve citation')

          if (resCiteprocMla.data !== '' && resCiteprocMla.data !== null && resCiteprocMla.data !== undefined) {
            this.citation = resCiteprocMla.data
            this.zoteroSearchObj = resZoteroSearch.data
          } else {
            this.errorMessage = 'Cannot retrieve citation.  Please check PMID'
          }
        }
      },
      search () {
        const options = {
          headers: { 'Content-Type': 'text/plain' }
        }
        return axios.post(ZOTERO_SEARCH_URL, this.pmid, options)
      },
      zoteroToCslJson (items) {
        return axios.post(ZOTERO_EXPORT_TO_CSLJSON, items)
      },
      citeProcGetCitation (items) {
        let itemsBody = {}

        items.forEach(item => {
          itemsBody = { ...itemsBody, [item.id]: item }
        })

        const cslItems = { items: { ...itemsBody } }
        
        return axios.post(CITEPROC_GET_MLA_CITATIONS, cslItems)
      }
    }
  }
</script>

<style>

  #title {
    margin-top: 15vh;
    text-align: center;
    font-size: 2em;;
  }

  #inputPmid {
    margin-top: 10vh;
  }

  #errorMessage {
    color: #ff3187;
    font-style: italic;
    text-align: center;
    font-weight: 500;
  }

</style>