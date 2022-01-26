<template>
    <div v-if="citation !== ''" class="row justify-center">
        <q-btn
            outline
            color="amber-7"
            label="Store Pubmed Record"
            @click="onClickStoreRecord"
        />
    </div>
</template>

<script>
    export default {
        name: 'StoreCitation',
        props: { 
            citation: String,
            zoteroSearchObj: Object,
            pmid: String,
            pmcid: String
        },
        methods: {
            onClickStoreRecord () {
                const body = []
                body.push({
                    record_id: this.zoteroSearchObj.key,
                    title: this.zoteroSearchObj.title,
                    journal: this.zoteroSearchObj.publicationTitle,
                    date_publication: this.zoteroSearchObj.date,
                    pub_citation_vol: this.zoteroSearchObj.volume,
                    pub_citation_issue: this.zoteroSearchObj.issue,
                    pub_citation_page: this.zoteroSearchObj.pages,
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

                console.log(body)
                // TODO post data to redcap
            }
        }
    }
</script>

<style>

</style>