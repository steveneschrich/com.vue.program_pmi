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
        label="PMID | PMCID"
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
    <StoreCitation
      :citation="citation"
      :zoteroSearchObj="zoteroSearchObj[0]"
      :pmid="pmid"
      :pmcid="pmcid"
      :newSearch="newSearch"
    />
    <div v-if="errorMessage !== ''" id="errorMessage">
      {{ errorMessage }}
    </div>
  </div>
</template>

<script>

  import axios from 'axios'
  import Citation from '../components/Citation'
  import StoreCitation from '../components/StoreCitation.vue'

  let ZOTERO_BASE_URL
  let CITEPROC_BASE_URL
  let ZOTERO_SEARCH_URL
  let ZOTERO_EXPORT_TO_CSLJSON
  let CITEPROC_GET_MLA_CITATIONS
  let RETRIEVE_PMCID_PMID_URL

  if (process.env.VUE_APP_PRODUCTION === 'true') {
    ZOTERO_BASE_URL = process.env.VUE_APP_ZOTERO_TRANSLATOR_HOST
    CITEPROC_BASE_URL = process.env.VUE_APP_CITEPROC_HOST
    ZOTERO_SEARCH_URL = `${ZOTERO_BASE_URL}/search`
    ZOTERO_EXPORT_TO_CSLJSON = `${ZOTERO_BASE_URL}/export?format=csljson`
    CITEPROC_GET_MLA_CITATIONS = `${CITEPROC_BASE_URL}?responseformat=html&style=modern-language-association&outputformat=text`
    RETRIEVE_PMCID_PMID_URL = `https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?tool=${process.env.VUE_APP_NCBI_TOOL_NAME}&email=${process.env.VUE_APP_NCBI_USER_EMAIL}&versions=no&format=json&ids=`
  } else {
    ZOTERO_BASE_URL = `${process.env.VUE_APP_ZOTERO_TRANSLATOR_HOST}:${process.env.VUE_APP_ZOTERO_TRANSLATOR_PORT}`
    CITEPROC_BASE_URL = `${process.env.VUE_APP_CITEPROC_HOST}:${process.env.VUE_APP_CITEPROC_PORT}`
    ZOTERO_SEARCH_URL = `${ZOTERO_BASE_URL}/search`
    ZOTERO_EXPORT_TO_CSLJSON = `${ZOTERO_BASE_URL}/export?format=csljson`
    CITEPROC_GET_MLA_CITATIONS = `${CITEPROC_BASE_URL}?responseformat=html&style=modern-language-association&outputformat=text`
    RETRIEVE_PMCID_PMID_URL = `https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?tool=${process.env.VUE_APP_NCBI_TOOL_NAME}&email=${process.env.VUE_APP_NCBI_USER_EMAIL}&versions=no&format=json&ids=`
  }

  export default {
    name: 'PmidQuery',
    components: { Citation, StoreCitation },
    data () {
      return {
        pmid: '',
        pmcid: '',
        citation: '',
        zoteroSearchObj: {},
        errorMessage: '',
        newSearch: false
      }
    },
    methods: {
      async onKeyPress (e) {
        if (e.key.toLowerCase() === 'enter') {
          await this.checkAndConvertPMCIDtoPMID()
          this.submit()
        }
      },
      async onClickSubmit () {
        await this.checkAndConvertPMCIDtoPMID()
        this.submit()
      },
      async submit () {

        this.citation = ''
        this.zoteroSearchObj = {}
        this.errorMessage = ''
        this.newSearch = !this.newSearch

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
      },
      async checkAndConvertPMCIDtoPMID () {
        this.pmcid = ''
        if (this.pmid.toLowerCase().includes('pmc')) {
          this.pmcid = this.pmid
          const response = await axios.get(RETRIEVE_PMCID_PMID_URL + this.pmid).catch(() => this.errorMessage = 'Unable to conver PMCID to PMID')
          const id = response.data.records[0].pmid
          if (id !== undefined && id !== null && id !== '') {
            this.pmid = id
          }
        } else {
          this.getPMCIDFromPMID()
        }
      },
      async getPMCIDFromPMID () {
        const response = await axios.get(RETRIEVE_PMCID_PMID_URL + this.pmid).catch(() => this.errorMessage = 'Unable to conver PMID to PMCID')
        const id = response.data.records[0].pmcid
        if (id !== undefined && id !== null && id !== '') {
          this.pmcid = id
        }
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