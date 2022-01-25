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
            zoteroSearchObj: Array
        },
        methods: {
            onClickStoreRecord () {
                console.log('store')
                console.log(this.citation)
                console.log(this.zoteroSearchObj)
            }
        }
    }
</script>

<style>

</style>