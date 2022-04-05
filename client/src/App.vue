<template>
  <div>
    <Logout/>
    <router-view/>
  </div>
</template>

<script>

  import Logout from './components/Logout'

  export default {
    name: 'App',
    components: { Logout }
  }
</script>

<style>

  .success {
    color: #4fffbb;
    font-weight: 600;
    font-style: italic;
  }

  .error {
    color: #f73959;
    font-weight: 600;
    font-style: italic;
  }

  .textAlignCenter {
    text-align: center;
  }

</style>