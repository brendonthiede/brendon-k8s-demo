<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <div></div>
    <div v-if="users && users.length > 0">
      <h2>Users</h2>
      <div v-for="user in users" :key="user.id">
        {{ user.name }}
      </div>
    </div>
  </div>
</template>

<script>
import config from "../../config.json";

export default {
  name: "HelloWorld",
  props: {
    msg: String,
  },
  data() {
    return {
      usersExist: false,
      users: [],
    };
  },
  methods: {
    getUsers() {
      this.usersExist = false;

      fetch(config.usersUrl, {
        method: "GET",
      })
        .then((response) => {
          if (response.ok) {
            return response.json();
          } else {
            alert(
              "Server returned " + response.status + " : " + response.statusText
            );
          }
        })
        .then((response) => {
          response.sort((a, b) => {
            let fa = a.name.toLowerCase(),
              fb = b.name.toLowerCase();

            if (fa < fb) {
              return -1;
            }
            if (fa > fb) {
              return 1;
            }
            return a.id - b.id;
          });
          this.users = response;
          this.usersExist = true;
        })
        .catch((err) => {
          console.log(err);
        });
    },
  },
  created() {
    this.getUsers();
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
