<template>
    <div v-if="toggle" id="helpModal">
        <div id="closeBtn">
            <span style="cursor: pointer" @click="onClickClose">[Close]</span>
        </div>
        <div class="textAlignCenter">
            <h5>Help Locating PMID or PMCID for PubMed Article</h5>
        </div>
        <div id="divLine"/>
        <img id="pubmedPng" :src="PubmedTitlePNG" alt="pubmed_title.png"/>
        <div id="divLine"/>
        <p/>
        <div class="row justify-center">
            <div class="col-10">
                <ol>
                    <li>The PMID or PMCID can be obtained from article publications on PubMed</li>
                    <li>They can be located on the article's main page right under the title and authors</li>
                </ol>
            </div>
        </div>
    </div>
</template>

<script>

    import PubmedTitlePNG from '../assets/png/pubmed_title.png'

    export default {
        name: 'Help',
        emits: ['closeHelp'],
        props: {
            toggle: Boolean
        },
        created () {
            this.PubmedTitlePNG = PubmedTitlePNG
        },
        methods: {
            onClickClose () {
                this.$emit('closeHelp', false)
            }
        }
    }
</script>

<style>

    #helpModal {
        background-color: #fff;
        box-shadow: 2px 5px 5px 2px #000;
        position: absolute;
        z-index: 15;
        width: 80vw;
        margin-left: 10vw;
    }

    #pubmedPng {
        width: 50%;
        margin-left: 25%;
    }

    #divLine {
        border-bottom: 1px solid #838383;
        width: 80%;
        margin-left: 10%;
    }

    #closeBtn {
        text-align: end;
        padding-right: 10px;
        padding-top: 5px;
        color: var(--primary-text);
    }

</style>