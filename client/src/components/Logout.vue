<template>
    <div v-if="show" id="logout">
        <span id="logoutContainer" @click="onClickLogout">Logout</span>
    </div>
</template>

<script>

    import { SESSION_STORAGE_KEY_TOKEN } from '../assets/js/constants'

    export default {
        name: 'Logout',
        data () {
            return {
                show: false
            }
        },
        watch: {
            $route (r) {
                if (r.path === '/' || r.path.toLowerCase() === '/login') {
                    this.show = false
                } else {
                    this.show = true
                }
            }
        },
        methods: {
            onClickLogout () {
                sessionStorage.removeItem(SESSION_STORAGE_KEY_TOKEN)
                this.show = false
                this.$router.push('/')
            }
        }
    }
</script>

<style>

    #logout {
        text-align: end;
        padding-right: 20px;
        padding-top: 5px;
        font-style: italic;
    }

    #logoutContainer {
        cursor: pointer;
        color: var(--primary-text);
    }

</style>