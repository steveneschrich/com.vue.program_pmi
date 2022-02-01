<template>
  <div>
    <router-view/>
  </div>
</template>

<script>
  export default {
    name: 'App'
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