
module.exports = {

  networks: {
    development: {
     host: "172.18.32.1",     // Localhost (default: none)
     port: 7545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.13",
    }
  },
};
