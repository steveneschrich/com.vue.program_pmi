<template>
    <div v-if="citation !== ''">
        <div id="textCopiedContainer">
                <span id="textCopiedMessage">Citation copied to clipboard</span>
        </div>
        <div v-if="citation !== ''" class="row justify-center">
            <q-input 
                class="col-10"
                color="amber-7"
                label-color="amber-7"
                standout
                v-model="citationModel"
                label="Citation"
                dark
                readonly
            >
                <template v-slot:append>
                    <q-icon
                        id="copyIcon"
                        name="content_copy"
                        @click="onClickCopyCitation"
                        class="cursor-pointer"
                    />
                </template>
            </q-input>
            <p/>
        </div>
    </div>
</template>

<script>
    export default {
        name: 'Citation',
        props: { citation: String },
        data () {
            return {
                citationModel: ''
            }
        },
        watch:{
            citation () {
                this.citationModel = this.citation
            }
        },
        methods: {
            onClickCopyCitation () {
                navigator.clipboard.writeText(this.citation)
                this.textCopied()
            },
            textCopied () {
                let opacity = 1;
                document.getElementById('textCopiedMessage').style.opacity = opacity
                setTimeout(() => {
                    let interval = setInterval(() => {
                        opacity -= 0.1
                        document.getElementById('textCopiedMessage').style.opacity = opacity
                        if (opacity <= 0) {
                            clearInterval(interval)
                        }
                    }, 50)
                }, 2000)
            }
        }
    }
</script>

<style>

    .q-field--standout.q-field--readonly .q-field__control::before {
        opacity: 0 !important;
        border: 0px !important;
    }

    #textCopiedContainer {
        text-align: center;
    }

    #textCopiedMessage {
        opacity: 0;
        color: #ffb300;
    }

</style>