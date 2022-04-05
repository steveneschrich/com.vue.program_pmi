<template>
    <div>
        <div id="topSpacer"/>
        <div class="textAlignCenter">
            <h4>Welcome to PROGRAM-PMI</h4>
        </div>
        <div class="row justify-center">
            <div class="col-xs-6 col-sm-4 col-md-3">
                <div class="row">
                    <q-input 
                        class="col-12"
                        color="amber-7"
                        label-color="amber-7"
                        rounded
                        filled
                        v-model="email"
                        label="Email"
                        dark
                        @keypress="onKeyPress"
                    />
                </div>
                <p/>
                <div class="row">
                    <q-input 
                        class="col-12"
                        color="amber-7"
                        label-color="amber-7"
                        rounded
                        filled
                        v-model="password"
                        label="Password"
                        dark
                        type="password"
                        @keypress="onKeyPress"
                    />
                </div>
                <p/>
                <div class="row justify-center">
                    <q-btn
                        outline
                        color="amber-7"
                        label="Submit"
                        @click="onClickSubmit"
                    />
                </div>
            </div>
        </div>
        <p/>
        <div v-if="errorMessage !== '' && errorMessage !== null && errorMessage !== undefined" class="textAlignCenter">
            {{errorMessage}}
        </div>
    </div>
</template>

<script>

    import axios from 'axios'
    import { SESSION_STORAGE_KEY_TOKEN } from '../assets/js/constants'

    let AUTH_URL

    if (process.env.VUE_APP_PRODUCTION === 'true') {
        AUTH_URL = `${process.env.VUE_APP_EXPRESS_API_HOST}/program-pmi/api/auth/authenticate`
    } else {
        AUTH_URL = `${process.env.VUE_APP_EXPRESS_API_HOST}:${process.env.VUE_APP_EXPRESS_API_PORT}/auth/authenticate`
    }

    export default {
        name: 'Login',
        data () {
            return {
                email: '',
                password: '',
                errorMessage: ''
            }
        },
        methods: {
            onClickSubmit () {
                this.submit()
            },
            onKeyPress (e) {
                if (e.key.toLowerCase() === 'enter') {
                    this.submit()
                }
            },
            submit () {
                this.errorMessage = ''
                
                let error = false

                if (this.email === '' || this.email === null || this.email === undefined) {
                    this.errorMessage = 'Please enter your email address'
                    error = true
                }

                if (this.password === '' || this.password === null || this.password === undefined) {
                    this.errorMessage = 'Please enter your password'
                    error = true
                }

                if (!error) {
                    axios.post(AUTH_URL, { email: this.email, password: this.password })
                        .then(res => {
                            if (!res.data.err) {
                                sessionStorage.setItem(SESSION_STORAGE_KEY_TOKEN, res.data.token)
                                this.$router.push('/citation')
                            } else {
                                this.errorMessage = 'User not authorized to access application'
                            }
                        })
                        .catch(err => {
                            this.errorMessage = err.response.data.message
                        })
                }
            }
        }
    }
</script>

<style>

    #topSpacer {
        margin-top: 20vh;
    }

</style>