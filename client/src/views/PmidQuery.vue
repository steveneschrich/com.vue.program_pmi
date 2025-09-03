<template>
  <div>
    <Help :toggle="toggleHelp" @closeHelp="onCloseHelp"/>
    <div id="title">
      PROGRAM-PMI
    </div>
    <div class="row justify-center">
      <div id="helpBtn" class="col-3">
        <span @click="onClickHelp" style="cursor: pointer">Help</span>
      </div>
    </div>
    <div id="inputPmid" class="row justify-center">
      <q-input 
        class="col-3"
        color="light-blue-14"
        label-color="light-blue-14"
        rounded
        filled
        v-model="pmid"
        label="PMID | PMCID"
        @keypress="onKeyPress"
      />
    </div>
    <p/>
    <div class="row justify-center">
      <q-btn
        outline
        color="light-blue-14"
        label="Retrieve Pubmed Record"
        @click="onClickSubmit"
      />
    </div>
    <p/>
    <Citation :citation="citation" :affiliations="affiliations"/>
    <p/>
    <StoreCitation
      :citation="citation"
      :zoteroSearchObj="zoteroSearchObj[0]"
      :pmid="pmid"
      :pmcid="pmcid"
      :newSearch="newSearch"
      :affiliations="affiliations"
    />
    <div v-if="errorMessage !== ''" id="errorMessage">
      {{ errorMessage }}
    </div>
  </div>
</template>

<script>

  import axios from 'axios'
  import Citation from '../components/Citation'
  import StoreCitation from '../components/StoreCitation'
  import Help from '../components/Help'
  import xml2js from 'xml2js'

  let ZOTERO_BASE_URL
  let CITEPROC_BASE_URL
  let ZOTERO_SEARCH_URL
  let ZOTERO_EXPORT_TO_CSLJSON
  let CITEPROC_GET_MLA_CITATIONS
  let RETRIEVE_PMCID_PMID_URL

  RETRIEVE_PMCID_PMID_URL = '/api/idconv'

  if (process.env.VUE_APP_PRODUCTION === 'true') {
    ZOTERO_BASE_URL = process.env.VUE_APP_ZOTERO_TRANSLATOR_HOST
    CITEPROC_BASE_URL = process.env.VUE_APP_CITEPROC_HOST
    ZOTERO_SEARCH_URL = `${ZOTERO_BASE_URL}/search`
    ZOTERO_EXPORT_TO_CSLJSON = `${ZOTERO_BASE_URL}/export?format=csljson`
    CITEPROC_GET_MLA_CITATIONS = `${CITEPROC_BASE_URL}?responseformat=html&style=modern-language-association&outputformat=text`
    RETRIEVE_PMCID_PMID_URL = `${process.env.VUE_APP_EXPRESS_API_HOST}/api/idconv`
   } else {
    ZOTERO_BASE_URL = `${process.env.VUE_APP_ZOTERO_TRANSLATOR_HOST}:${process.env.VUE_APP_ZOTERO_TRANSLATOR_PORT}`
    CITEPROC_BASE_URL = `${process.env.VUE_APP_CITEPROC_HOST}:${process.env.VUE_APP_CITEPROC_PORT}`
    ZOTERO_SEARCH_URL = `${ZOTERO_BASE_URL}/search`
    ZOTERO_EXPORT_TO_CSLJSON = `${ZOTERO_BASE_URL}/export?format=csljson`
    CITEPROC_GET_MLA_CITATIONS = `${CITEPROC_BASE_URL}?responseformat=html&style=modern-language-association&outputformat=text`
    RETRIEVE_PMCID_PMID_URL = `${process.env.VUE_APP_EXPRESS_API_HOST}:${process.env.VUE_APP_EXPRESS_API_PORT}/api/idconv`
   }

  export default {
    name: 'PmidQuery',
    components: { Citation, StoreCitation, Help },
    data () {
      return {
        pmid: '',
        pmcid: '',
        citation: '',
        zoteroSearchObj: {},
        affiliations: [],
        errorMessage: '',
        newSearch: false,
        toggleHelp: false
      }
    },
    watch: {
      pmid (nPmid, oPmid) {
        if (nPmid !== oPmid) {
          this.pmid = nPmid.replace(/\s/g, '')
        }
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

        const regexPMC = new RegExp(/^(?:PMC)\d+/g)
        const regexPMI = new RegExp(/^\d+$/g)

        let error = false

        if (this.pmid === '' || this.pmid === null || this.pmid === undefined) {
          error = true
          this.errorMessage = 'PMID cannot be empty'
        }

        if (!regexPMC.test(this.pmid) && !regexPMI.test(this.pmid)) {
          error = true
          this.errorMessage = 'ID entered is not a valid PMID or PMCID'
        }

        if (!error) {
          const resZoteroSearch = await this.search().catch(() => this.errorMessage = 'Zotero search failed and returned no results')
          const resZoteroExport = await this.zoteroToCslJson(resZoteroSearch.data).catch(() => this.errorMessage = 'Unable to convert Zotero to CSL JSON')
          const resCiteprocMla = await this.citeProcGetCitation(resZoteroExport.data).catch(() => this.errorMessage = 'Cannot retrieve citation')
          const pubmedResponse = await axios.get('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi', {
            params: {
              db: 'pubmed',
              id: this.pmid,
              retmode: 'xml'
            }
          });

          const xml = pubmedResponse.data
          const parsed = await xml2js.parseStringPromise(xml);
          const authors = parsed.PubmedArticleSet.PubmedArticle[0].MedlineCitation[0].Article[0].AuthorList[0].Author;
          this.affiliations = authors.map(author => ({
            name: `${author.ForeName[0]} ${author.LastName[0]}`,
            affiliation: author.AffiliationInfo ? author.AffiliationInfo[0].Affiliation[0] : null
          }));
          
          if (resCiteprocMla.data !== '' && resCiteprocMla.data !== null && resCiteprocMla.data !== undefined) {
            this.citation = resCiteprocMla.data
            this.zoteroSearchObj = resZoteroSearch.data
          } else {
            this.errorMessage = 'Cannot retrieve citation.  Please check PMID'
          }
        }
      },
      buildIdConvUrl (id) {
        // Only send the ID to server endpoint
        const params = new URLSearchParams({ id });
        return `${RETRIEVE_PMCID_PMID_URL}?${params.toString()}`;
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
          try {
            const response = await axios.get(this.buildIdConvUrl(this.pmid))
            if (response && response.data && Array.isArray(response.data.records) && response.data.records.length > 0) {
              const id = response.data.records[0].pmid
              if (id) this.pmid = id
              else this.errorMessage = 'PMCID found but no PMID returned'
            } else {
              this.errorMessage = 'No records returned when converting PMCID to PMID'
            }
          } catch (err) {
            console.error('error converting PMCID to PMID', err)
            this.errorMessage = 'Unable to convert PMCID to PMID'
          }
        } else {
          this.getPMCIDFromPMID()
        }
      },
      async getPMCIDFromPMID () {
        try {
          const response = await axios.get(this.buildIdConvUrl(this.pmid))
          if (response && response.data && Array.isArray(response.data.records) && response.data.records.length > 0) {
            const id = response.data.records[0].pmcid
            if (id) this.pmcid = id
            else {
              this.pmcid = ''
              this.errorMessage = 'No PMCID found for this PMID'
            }
          } else {
            this.errorMessage = 'No records returned when converting PMID to PMCID'
          }
        } catch (e) {
          console.log('error retrieving pmcid from pmid:', e)
          this.errorMessage = 'Unable to convert PMID to PMCID'
        }
      },
      onClickHelp () {
        this.toggleHelp = !this.toggleHelp
      },
      onCloseHelp (val) {
        this.toggleHelp = val
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
  }

  #errorMessage {
    color: #ff3187;
    font-style: italic;
    text-align: center;
    font-weight: 500;
  }

  #helpBtn {
    margin-top: 10vh;
    text-align: end;
    padding-right: 20px;
    color: var(--primary-text);
  }

</style>