<template>
    <div>
        <div v-if="citation !== ''" class="row justify-center">
            <q-btn
                outline
                color="light-blue-14"
                label="Store Pubmed Record"
                @click="onClickStoreRecord"
            />
        </div>
        <p/>
        <div v-if="successMessage != ''" class="success textAlignCenter">{{this.successMessage}}</div>
        <div v-if="errorMessage != ''" class="error textAlignCenter">{{this.errorMessage}}</div>
    </div>
</template>

<script>

    import axios from 'axios'
    import { SESSION_STORAGE_KEY_TOKEN } from '../assets/js/constants'

    let EXPRESS_API_REDCAP_CITATION
    
    if (process.env.VUE_APP_PRODUCTION === 'true') {
        EXPRESS_API_REDCAP_CITATION = `${process.env.VUE_APP_EXPRESS_API_HOST}/redcap/citation/api/import`
    } else {
        EXPRESS_API_REDCAP_CITATION = `${process.env.VUE_APP_EXPRESS_API_HOST}:${process.env.VUE_APP_EXPRESS_API_PORT}/redcap/citation/api/import`
    }

    export default {
        name: 'StoreCitation',
        props: { 
            citation: String,
            zoteroSearchObj: Object,
            pmid: String,
            pmcid: String,
            newSearch: Boolean
        },
        data () {
            return {
                successMessage: '',
                errorMessage: ''
            }
        },
        watch: {
            newSearch (nVal, oVal) {
                if (nVal !== oVal) {
                    this.successMessage = ''
                    this.errorMessage = ''
                }
            }
        },
        methods: {
            onClickStoreRecord () {

                this.successMessage = ''
                this.errorMessage = ''

                const body = []
                body.push({
                    record_id: this.zoteroSearchObj.key,
                    title: this.zoteroSearchObj.title,
                    journal: this.zoteroSearchObj.publicationTitle,
                    date_publication: this.zoteroSearchObj.date,
                    pub_citation_vol: this.zoteroSearchObj.volume,
                    pub_citation_issue: this.zoteroSearchObj.issue,
                    pub_citation_pg: this.zoteroSearchObj.pages,
                    pmid: this.pmid,
                    pmcid: this.pmcid
                })

                this.zoteroSearchObj.creators.forEach((creator, index) => {
                    body.push({
                        record_id: this.zoteroSearchObj.key,
                        redcap_repeat_instrument: 'authors',
                        redcap_repeat_instance: index+1,
                        author_name: `${creator.firstName} ${creator.lastName}`
                    })
                })

                axios.post(EXPRESS_API_REDCAP_CITATION, body, { headers: { Authorization: `Bearer ${sessionStorage.getItem(SESSION_STORAGE_KEY_TOKEN)}` }}).then(res => {
                    if (res.data.err) {
                        this.errorMessage = res.data.message
                    } else {
                        this.successMessage = res.data.message
                    }

                })
                .catch(err => {
                    if (err.response.data.err) {
                        this.errorMessage = err.response.data.message
                        if (err.response.data.message.toLowerCase() === 'invalid token') {
                            this.errorMessage += ' - redirecting to login in 5 seconds...'
                            setTimeout(() => {
                                this.$router.push('/')
                            }, 5000)
                        }
                    }
                })
            }
        }
    }
</script>

<style>

</style>